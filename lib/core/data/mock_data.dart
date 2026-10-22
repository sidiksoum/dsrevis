import 'package:flutter/material.dart';

/// Représente une fiche de cours avec un système de verrouillage premium granulaire.
/// 
/// Logique de verrouillage:
/// - Si [premiumOnly] = false : Le cours est gratuit et accessible à TOUS les utilisateurs
/// - Si [premiumOnly] = true : Le cours est verrouillé et n'est accessible que si l'utilisateur a [AppUser.premium] = true
/// 
/// Cette approche permet un contenu pédagogique mixte: certains cours gratuits (onboarding),
/// d'autres réservés aux abonnés premium pour monétisation.
class CourseItem {
  CourseItem({
    required this.title,
    required this.category, 
    required this.summary,
    required this.driveLink,
    required this.premiumOnly,
  });

  String title;
  String category;
  String summary;
  String driveLink;
  
  /// Si true: cette fiche est réservée aux comptes premium
  /// Si false: cette fiche est gratuite et accessible à tous
  bool premiumOnly;
}

class QuizQuestion {
  QuizQuestion({
    required this.id,
    required this.prompt,
    required this.courseTitle,
    required this.subjectLevel,
    required this.subjectTitle,
    required this.type, // 'QCM' ou 'QCD'
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  String id;
  String prompt;
  String courseTitle;
  String subjectLevel;
  String subjectTitle;
  String type;
  List<String> options;
  String correctAnswer;
  String explanation;
}

class UserProgressItem {
  UserProgressItem({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final String label;
  final double value;
  final String subtitle;
}

class AppUser {
  AppUser({
    required this.name,
    required this.email,
    required this.level, 
    required this.filiere, 
    required this.premium,
    required this.isActive,
  });

  String name;
  String email;
  String level;
  String filiere;
  
  /// Statut d'activation premium du compte:
  /// - true: L'étudiant a activé son abonnement premium (accès à tous contenus avec premiumOnly=true)
  /// - false: L'étudiant est en version gratuite (accès limité aux contenus avec premiumOnly=false)
  /// 
  /// Ce booléen est géré par les administrateurs dans Firestore et synchronisé en temps réel
  /// via un écouteur StreamSubscription. Les modifications se propagent instantanément dans l'app.
  bool premium;
  bool isActive;
}

// Gestionnaires d'état système globaux
final ValueNotifier<bool> globalIsOnline = ValueNotifier<bool>(true);
final ValueNotifier<bool> globalIsQuizActive = ValueNotifier<bool>(false);

// État de l'étudiant connecté
AppUser? currentUser;

List<UserProgressItem> getSampleProgressItems() {
  return [
    UserProgressItem(
      label: 'Quiz Validés',
      value: 0.0,
      subtitle: 'Entraînez-vous pour faire grimper votre score',
    ),
    UserProgressItem(
      label: 'Fiches de Cours lues',
      value: 0.0,
      subtitle: 'Aucune fiche lue pour le moment',
    ),
    UserProgressItem(
      label: 'Séances de révision hebdomadaires',
      value: 0.15,
      subtitle: '1 jour actif cette semaine',
    ),
  ];
}