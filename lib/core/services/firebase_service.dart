import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_helper.dart';
import '../../features/shared/data/sample_data.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchWhatsAppPremiumRequest() async {
  final userMail = currentUser?.email ?? 'non_renseigne';
  final phoneNumber = await DatabaseHelper.instance.getWhatsappNumber();
  final message = "Bonjour je souhaiterai activer mon abonnement premium! Mon mail est : $userMail";
  final whatsappUrl = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

  try {
    await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint("Erreur d'ouverture WhatsApp: $e");
  }
}

Future<void> supportRequest() async {
  final userMail = currentUser?.email ?? 'non_renseigne';
  final userName = currentUser?.name ?? 'Étudiant';
  final userFiliere = currentUser?.filiere ?? '';
  final userLevel = currentUser?.level ?? '';
  final phoneNumber = await DatabaseHelper.instance.getWhatsappNumber();
  final message = "Bonjour l'équipe Support DS REVIS, je sollicite votre assistance.\nNom : $userName\nEmail : $userMail\nFilière : $userFiliere ($userLevel)";
  final whatsappUrl = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

  try {
    await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint("Erreur d'ouverture WhatsApp Support: $e");
  }
}

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  static StreamSubscription? _premiumSubscription;
  static StreamSubscription? _emailSubscription;

  static void observeNetworkConnectivity() {
    Timer.periodic(const Duration(seconds: 4), (timer) async {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          globalIsOnline.value = true;
        }
      } catch (_) {
        globalIsOnline.value = false;
      }
    });
  }

  void startLivePremiumObserver() {
    final targetUid = currentUser?.id ?? _auth.currentUser?.uid;
    final targetEmail = (currentUser?.email ?? _auth.currentUser?.email)?.trim().toLowerCase();

    if ((targetUid == null || targetUid.isEmpty) && (targetEmail == null || targetEmail.isEmpty)) {
      debugPrint("startLivePremiumObserver: Aucun identifiant utilisateur détecté.");
      return;
    }

    _premiumSubscription?.cancel();
    _emailSubscription?.cancel();

    void updateFromUserData(String docId, Map<String, dynamic> data) async {
      final bool isPremiumOnServer = data['premium'] == true;
      final bool isActiveOnServer = data['isActive'] != false;

      // Évite les notifications redondantes si aucune modification
      if (currentUser != null &&
          currentUser!.id == docId &&
          currentUser!.premium == isPremiumOnServer &&
          currentUser!.isActive == isActiveOnServer &&
          currentUser!.name == (data['name'] ?? currentUser!.name) &&
          currentUser!.level == (data['level'] ?? currentUser!.level) &&
          currentUser!.filiere == (data['filiere'] ?? currentUser!.filiere)) {
        return;
      }

      final freshProfile = {
        'id': docId,
        'name': data['name'] ?? currentUser?.name ?? '',
        'email': data['email'] ?? currentUser?.email ?? targetEmail ?? '',
        'level': data['level'] ?? currentUser?.level ?? 'Licence 1',
        'filiere': data['filiere'] ?? currentUser?.filiere ?? 'IDE',
        'premium': isPremiumOnServer,
        'isActive': isActiveOnServer,
        'country': data['country'] ?? currentUser?.country ?? "Côte d'Ivoire",
        'antenne': data['antenne'] ?? currentUser?.antenne ?? 'Antenne Bouaké',
      };

      await _dbHelper.saveUserSession(freshProfile);

      currentUser = AppUser(
        id: docId,
        name: freshProfile['name'] as String,
        email: freshProfile['email'] as String,
        level: freshProfile['level'] as String,
        filiere: freshProfile['filiere'] as String,
        premium: isPremiumOnServer,
        isActive: isActiveOnServer,
        country: freshProfile['country'] as String,
        antenne: freshProfile['antenne'] as String,
      );

      currentSessionUserNotifier.value = currentUser;
      debugPrint("✨ [Live Observer] Statut utilisateur actualisé en direct : ${currentUser?.name} | Premium = $isPremiumOnServer | Actif = $isActiveOnServer");
    }

    // 1. Écoute directe par document ID si disponible
    if (targetUid != null && targetUid.isNotEmpty) {
      _premiumSubscription = _firestore
          .collection('users')
          .doc(targetUid)
          .snapshots()
          .listen((doc) {
        if (doc.exists && doc.data() != null) {
          updateFromUserData(doc.id, doc.data() as Map<String, dynamic>);
        }
      }, onError: (e) {
        debugPrint("Erreur écoute live docId : $e");
      });
    }

    // 2. Écoute par email pour garantir la synchronisation même si docId diffère
    if (targetEmail != null && targetEmail.isNotEmpty) {
      _emailSubscription = _firestore
          .collection('users')
          .where('email', isEqualTo: targetEmail)
          .snapshots()
          .listen((query) {
        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          updateFromUserData(doc.id, doc.data());
        }
      }, onError: (e) {
        debugPrint("Erreur écoute live email : $e");
      });
    }
  }

  Future<List<String>> fetchLiveLevelsFromServer() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('years').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      debugPrint("Erreur récupération niveaux Cloud: $e");
      return ['Licence 1', 'Licence 2', 'Licence 3', 'AS L1', 'AS L2'];
    }
  }

  Future<List<Map<String, dynamic>>> fetchLiveFilieresWithYearsFromServer() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('filieres').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? '',
          'years': List<String>.from(data['years'] ?? []),
        };
      }).toList();
    } catch (e) {
      debugPrint("Erreur récupération filières Cloud: $e");
      return [
        {'name': 'IDE', 'years': ['Licence 1', 'Licence 2', 'Licence 3']},
        {'name': 'SF', 'years': ['Licence 1', 'Licence 2', 'Licence 3']},
        {'name': 'AS', 'years': ['AS L1', 'AS L2']},
      ];
    }
  }

  Future<AppUser?> registerStudent({
    required String name,
    required String email,
    required String password,
    required String level,
    required String filiere,
    required String country,
    required String antenne,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      User? firebaseUser = result.user;
      if (firebaseUser == null) return null;

      Map<String, dynamic> userData = {
        'id': firebaseUser.uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'level': level,
        'filiere': filiere,
        'premium': false,
        'isActive': true,
        'country': country,
        'antenne': antenne,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('users').doc(firebaseUser.uid).set(userData);
      await _dbHelper.saveUserSession(userData);

      currentUser = AppUser(
        id: firebaseUser.uid,
        name: name,
        email: email,
        level: level,
        filiere: filiere,
        premium: false,
        isActive: true,
        country: country,
        antenne: antenne,
      );
      currentSessionUserNotifier.value = currentUser;

      startLivePremiumObserver();

      await synchronizeDataFromServer();

      return currentUser;
    } catch (e) {
      debugPrint("Erreur lors de l'inscription et initialisation : $e");
      rethrow;
    }
  }

    Future<AppUser?> loginStudent(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password;

    try {
      String? uid;
      Map<String, dynamic>? data;

      // 1. Tentative de connexion via Firebase Auth standard
      try {
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: cleanEmail,
          password: cleanPassword,
        );
        User? firebaseUser = result.user;
        if (firebaseUser != null) {
          uid = firebaseUser.uid;
          DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
          if (doc.exists && doc.data() != null) {
            data = doc.data() as Map<String, dynamic>;
          }
        }
      } catch (authError) {
        debugPrint("Tentative Firebase Auth standard non aboutie, vérification Firestore : $authError");
      }

      // 2. Si Firebase Auth a échoué (ex: mot de passe modifié par Admin dans le Dashboard ou via 'Mot de passe oublié')
      if (data == null) {
        final query = await _firestore
            .collection('users')
            .where('email', isEqualTo: cleanEmail)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          final docData = doc.data();
          final storedPassword = docData['password'];

          // Vérification si le mot de passe correspond à celui mis à jour dans Firestore
          if (storedPassword != null && storedPassword.toString() == cleanPassword) {
            uid = doc.id;
            data = docData;
          }
        }
      }

      // Si aucune des méthodes n'a trouvé l'utilisateur avec ce mot de passe
      if (data == null || uid == null) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Adresse email ou mot de passe incorrect.',
        );
      }

      final profileMap = {
        'id': uid,
        'name': data['name'] ?? '',
        'email': data['email'] ?? cleanEmail,
        'level': data['level'] ?? 'Licence 1',
        'filiere': data['filiere'] ?? 'IDE',
        'premium': data['premium'] ?? false,
        'isActive': data['isActive'] ?? true,
        'country': data['country'] ?? "Côte d'Ivoire",
        'antenne': data['antenne'] ?? 'Antenne Bouaké',
      };

      await _dbHelper.saveUserSession(profileMap);

      currentUser = AppUser(
        id: uid,
        name: profileMap['name'] as String,
        email: profileMap['email'] as String,
        level: profileMap['level'] as String,
        filiere: profileMap['filiere'] as String,
        premium: profileMap['premium'] as bool,
        isActive: profileMap['isActive'] as bool,
        country: profileMap['country'] as String,
        antenne: profileMap['antenne'] as String,
      );
      currentSessionUserNotifier.value = currentUser;

      startLivePremiumObserver();
      await synchronizeDataFromServer();

      return currentUser;
    } catch (e) {
      rethrow;
    }
  }

  /// Vérifie si une adresse email existe dans la base Firestore
  Future<bool> checkEmailExists(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: cleanEmail)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint("Erreur checkEmailExists : $e");
      return false;
    }
  }

  /// Récupère le nom de l'étudiant pour une adresse email donnée
  Future<String?> getUserNameByEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: cleanEmail)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first.data()['name'] as String?;
      }
    } catch (e) {
      debugPrint("Erreur getUserNameByEmail : $e");
    }
    return null;
  }

  /// Réinitialise le mot de passe d'un étudiant dans Firestore
  Future<bool> resetStudentPassword({
    required String email,
    required String newPassword,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: cleanEmail)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return false;
      }

      final docId = query.docs.first.id;
      await _firestore.collection('users').doc(docId).update({
        'password': newPassword,
        'passwordUpdatedAt': DateTime.now().toIso8601String(),
      });

      // Tenter également de mettre à jour le mot de passe Firebase Auth si possible
      try {
        await _auth.sendPasswordResetEmail(email: cleanEmail);
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint("Erreur resetStudentPassword : $e");
      return false;
    }
  }

  Future<bool> synchronizeDataFromServer() async {
    if (currentUser == null) return false;

    try {
      final whatsappNum = await fetchWhatsappNumberFromServer();
      await _dbHelper.saveWhatsappNumber(whatsappNum);

      final serverUpdate = await fetchLastDatabaseUpdateFromServer();
      await _dbHelper.saveLastDatabaseUpdate(serverUpdate);
      await _dbHelper.saveLastSyncTimestamp(serverUpdate);

      // Récupération complète sans limitation whereIn de Firestore
      QuerySnapshot coursesSnapshot = await _firestore.collection('courses').get();

      final Map<String, Map<String, dynamic>> uniqueCourses = {};
      for (final doc in coursesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final category = (data['category'] ?? '').toString();
        final filiere = (data['filiere'] ?? '').toString();
        if (isCourseAccessibleForUser(
          courseCategory: category,
          courseFiliere: filiere,
          user: currentUser!,
        )) {
          uniqueCourses[doc.id] = {
            'id': doc.id,
            'title': data['title'] ?? '',
            'category': data['category'] ?? '',
            'filiere': data['filiere'] ?? '',
            'summary': data['summary'] ?? '',
            'driveLink': data['driveLink'] ?? '',
            'premiumOnly': (data['premiumOnly'] ?? false) == true ? 1 : 0,
          };
        }
      }
      List<Map<String, dynamic>> coursesList = uniqueCourses.values.toList();

      await _dbHelper.saveCourses(coursesList, currentUser?.id ?? 'guest');

      List<String> downloadedCourseTitles = coursesList.map((c) => c['title'] as String).toSet().toList();
      if (downloadedCourseTitles.isEmpty) {
        await _dbHelper.saveQuizQuestions([], currentUser?.id ?? 'guest');
        currentSessionUserNotifier.value = currentUser;
        return true;
      }

      Iterable<List<String>> chunkedCourseTitles(List<String> titles, int chunkSize) sync* {
        for (var i = 0; i < titles.length; i += chunkSize) {
          yield titles.sublist(i, i + chunkSize > titles.length ? titles.length : i + chunkSize);
        }
      }

      final Map<String, Map<String, dynamic>> uniqueQuizQuestions = {};
      const int chunkSize = 30;
      for (final titleBatch in chunkedCourseTitles(downloadedCourseTitles, chunkSize)) {
        final quizSnapshot = await _firestore
            .collection('quizQuestions')
            .where('courseTitle', whereIn: titleBatch)
            .get();

        for (final doc in quizSnapshot.docs) {
          final data = doc.data();
          String optionsJson = jsonEncode(data['options'] ?? []);
          uniqueQuizQuestions[doc.id] = {
            'id': doc.id,
            'courseTitle': data['courseTitle'] ?? '',
            'subjectLevel': data['subjectLevel'] ?? 'Sujet 1',
            'subjectTitle': data['subjectTitle'] ?? 'Généralités',
            'prompt': data['prompt'] ?? '',
            'type': data['type'] ?? 'QCM',
            'options': optionsJson,
            'correctAnswer': data['correctAnswer'] ?? '',
            'explanation': data['explanation'] ?? '',
          };
        }
      }

      await _dbHelper.saveQuizQuestions(uniqueQuizQuestions.values.toList(), currentUser?.id ?? 'guest');

      currentSessionUserNotifier.value = currentUser;

      return true;
    } catch (e) {
      debugPrint("Erreur lors de la synchronisation : $e");
      return false;
    }
  }

  Future<void> checkAndSyncPremiumStatusInBackground() async {
    final targetUid = currentUser?.id ?? _auth.currentUser?.uid;
    final targetEmail = (currentUser?.email ?? _auth.currentUser?.email)?.trim().toLowerCase();

    if ((targetUid == null || targetUid.isEmpty) && (targetEmail == null || targetEmail.isEmpty)) {
      return;
    }

    try {
      Map<String, dynamic>? data;
      String? foundUid;

      if (targetUid != null && targetUid.isNotEmpty) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(targetUid).get();
        if (doc.exists && doc.data() != null) {
          data = doc.data() as Map<String, dynamic>;
          foundUid = doc.id;
        }
      }

      if (data == null && targetEmail != null && targetEmail.isNotEmpty) {
        final query = await _firestore
            .collection('users')
            .where('email', isEqualTo: targetEmail)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          data = query.docs.first.data();
          foundUid = query.docs.first.id;
        }
      }

      if (data != null && foundUid != null) {
        final bool isPremiumOnServer = data['premium'] == true;
        final bool isActiveOnServer = data['isActive'] != false;

        final freshProfile = {
          'id': foundUid,
          'name': data['name'] ?? currentUser?.name ?? '',
          'email': data['email'] ?? currentUser?.email ?? targetEmail ?? '',
          'level': data['level'] ?? currentUser?.level ?? 'Licence 1',
          'filiere': data['filiere'] ?? currentUser?.filiere ?? 'IDE',
          'premium': isPremiumOnServer,
          'isActive': isActiveOnServer,
          'country': data['country'] ?? currentUser?.country ?? "Côte d'Ivoire",
          'antenne': data['antenne'] ?? currentUser?.antenne ?? 'Antenne Bouaké',
        };

        await _dbHelper.saveUserSession(freshProfile);

        currentUser = AppUser(
          id: foundUid,
          name: freshProfile['name'] as String,
          email: freshProfile['email'] as String,
          level: freshProfile['level'] as String,
          filiere: freshProfile['filiere'] as String,
          premium: isPremiumOnServer,
          isActive: isActiveOnServer,
          country: freshProfile['country'] as String,
          antenne: freshProfile['antenne'] as String,
        );

        currentSessionUserNotifier.value = currentUser;
      }
    } catch (e) {
      debugPrint("Vérification Premium en tâche de fond ignorée : $e");
    }
  }

  Future<String> fetchWhatsappNumberFromServer() async {
    try {
      final doc = await _firestore.collection('settings').doc('app').get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['whatsappNumber'] as String? ?? '2250798646697';
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération du numéro WhatsApp : $e");
    }
    return '2250798646697';
  }

  Future<String> fetchLastDatabaseUpdateFromServer() async {
    try {
      final doc = await _firestore.collection('settings').doc('app').get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['lastDatabaseUpdate'] as String? ?? '';
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération de lastDatabaseUpdate : $e");
    }
    return '';
  }

  Future<void> signOut() async {
    await _premiumSubscription?.cancel();
    _premiumSubscription = null;
    await _emailSubscription?.cancel();
    _emailSubscription = null;
    await _dbHelper.clearUserSession();
    currentUser = null;
    currentSessionUserNotifier.value = null;
    await _auth.signOut();
  }
}
