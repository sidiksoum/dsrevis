import 'package:flutter/material.dart';

class CourseItem {
  CourseItem({
    required this.title,
    required this.category,
    required this.filiere,
    required this.summary,
    required this.driveLink,
    required this.premiumOnly,
  });

  String title;
  String category;
  String summary;
  String filiere;
  String driveLink;
  bool premiumOnly;
}

class QuizQuestion {
  QuizQuestion({
    required this.id,
    required this.prompt,
    required this.courseTitle,
    required this.subjectLevel,
    required this.subjectTitle,
    required this.type,
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
    this.id = 'guest',
    required this.name,
    required this.email,
    required this.level,
    required this.filiere,
    required this.premium,
    required this.isActive,
    this.country = 'Côte d\'Ivoire',
    this.antenne = 'Antenne Bouaké',
  });

  String id;
  String name;
  String email;
  String level;
  String filiere;
  String country;
  String antenne;
  bool premium;
  bool isActive;
}

final ValueNotifier<bool> globalIsOnline = ValueNotifier<bool>(true);
final ValueNotifier<bool> globalIsQuizActive = ValueNotifier<bool>(false);
final ValueNotifier<AppUser?> currentSessionUserNotifier = ValueNotifier<AppUser?>(null);

AppUser? currentUser;

String _normalizeStr(String s) {
  return s.trim().toLowerCase().replaceAll(' ', '').replaceAll('-', '').replaceAll('_', '');
}

bool _isL1Category(String cat) {
  final c = _normalizeStr(cat);
  return c.contains('licence1') || c == 'l1' || c.contains('l1') || c.contains('tronccommun') || c == '1';
}

bool _isL2Category(String cat) {
  final c = _normalizeStr(cat);
  return (c.contains('licence2') || c == 'l2' || c.contains('l2') || c == '2') && !_isL1Category(cat);
}

bool _isL3Category(String cat) {
  final c = _normalizeStr(cat);
  return (c.contains('licence3') || c == 'l3' || c.contains('l3') || c == '3') && !_isL1Category(cat) && !_isL2Category(cat);
}

bool _isL3User(String userLevel) {
  final ul = _normalizeStr(userLevel);
  return ul.contains('licence3') || ul.contains('l3') || ul == '3';
}

bool _isL2User(String userLevel) {
  final ul = _normalizeStr(userLevel);
  return (ul.contains('licence2') || ul.contains('l2') || ul == '2') && !_isL3User(userLevel);
}

bool _isL1User(String userLevel) {
  final ul = _normalizeStr(userLevel);
  return (ul.contains('licence1') || ul.contains('l1') || ul == '1') && !_isL3User(userLevel) && !_isL2User(userLevel);
}

bool _isIdeFiliere(String fil) {
  final f = _normalizeStr(fil);
  return f.contains('ide') || f.contains('infirmier');
}

bool _isSfmFiliere(String fil) {
  final f = _normalizeStr(fil);
  return f.contains('sfm') || f.contains('sf') || f.contains('sagefemme') || f.contains('maieuticien');
}

bool _filiereMatches(String courseFiliere, String userFiliere) {
  final cf = _normalizeStr(courseFiliere);
  final uf = _normalizeStr(userFiliere);
  if (cf.isEmpty || cf == 'tous' || cf == 'tout' || cf == 'tronccommun' || cf == 'commun') {
    return true;
  }
  if (uf.contains(cf) || cf.contains(uf)) {
    return true;
  }
  if (_isIdeFiliere(userFiliere) && (cf.contains('ide') || cf.contains('infirmier'))) {
    return true;
  }
  if (_isSfmFiliere(userFiliere) && (cf.contains('sfm') || cf.contains('sf') || cf.contains('sagefemme'))) {
    return true;
  }
  return false;
}


bool isL3User(String? userLevel) {
  if (userLevel == null) return false;
  return _isL3User(userLevel);
}

bool isL2User(String? userLevel) {
  if (userLevel == null) return false;
  return _isL2User(userLevel);
}

bool isL1User(String? userLevel) {
  if (userLevel == null) return false;
  return _isL1User(userLevel);
}

bool isCourseMatchingLevelCategory(String courseCategory, String levelName) {
  if (levelName == 'Licence 1') return _isL1Category(courseCategory);
  if (levelName == 'Licence 2') return _isL2Category(courseCategory);
  if (levelName == 'Licence 3') return _isL3Category(courseCategory);
  return _normalizeStr(courseCategory) == _normalizeStr(levelName);
}

/// Règle d'accès académique pour la Licence 3 (L1, L2, L3) et autres niveaux.
///
/// Pour un étudiant avec profil Licence 3 + Filière IDE :
/// - Licence 1 : Accès à l'ensemble des cours et quiz de L1 (filières IDE et SFM / tronc commun).
/// - Licence 2 : Accès aux cours et quiz de L2 filière IDE.
/// - Licence 3 : Accès aux cours et quiz de L3 filière IDE.
///
/// Pour un étudiant avec profil Licence 3 + Filière SFM :
/// - Licence 1 : Accès à l'ensemble des cours et quiz de L1 (filières IDE et SFM / tronc commun).
/// - Licence 2 : Accès aux cours et quiz de L2 filière SFM.
/// - Licence 3 : Accès aux cours et quiz de L3 filière SFM.
bool isCourseAccessibleForUser({
  required String courseCategory,
  required String courseFiliere,
  required AppUser user,
}) {
  final userLevel = user.level;
  final userFiliere = user.filiere;

  // 1. Profil Licence 3
  if (_isL3User(userLevel)) {
    // Licence 1 : tous les cours L1 pour IDE, SFM, Tronc Commun
    if (_isL1Category(courseCategory)) {
      if (_isIdeFiliere(userFiliere) || _isSfmFiliere(userFiliere)) {
        final cf = _normalizeStr(courseFiliere);
        return cf.contains('ide') ||
            cf.contains('sf') ||
            cf.contains('sfm') ||
            cf.contains('tronccommun') ||
            cf.isEmpty ||
            cf == 'tous' ||
            cf == 'tout' ||
            _filiereMatches(courseFiliere, userFiliere);
      }
      return _filiereMatches(courseFiliere, userFiliere);
    }

    // Licence 2 : uniquement la filière de l'étudiant
    if (_isL2Category(courseCategory)) {
      return _filiereMatches(courseFiliere, userFiliere);
    }

    // Licence 3 : uniquement la filière de l'étudiant
    if (_isL3Category(courseCategory)) {
      return _filiereMatches(courseFiliere, userFiliere);
    }

    return _filiereMatches(courseFiliere, userFiliere) && _normalizeStr(courseCategory) == _normalizeStr(userLevel);
  }

  // 2. Profil Licence 2
  if (_isL2User(userLevel)) {
    if (_isL2Category(courseCategory)) {
      return _filiereMatches(courseFiliere, userFiliere);
    }
    return false;
  }

  // 3. Profil Licence 1
  if (_isL1User(userLevel)) {
    if (_isL1Category(courseCategory)) {
      if (_isIdeFiliere(userFiliere) || _isSfmFiliere(userFiliere)) {
        final cf = _normalizeStr(courseFiliere);
        return cf.contains('ide') ||
            cf.contains('sf') ||
            cf.contains('sfm') ||
            cf.contains('tronccommun') ||
            cf.isEmpty ||
            cf == 'tous' ||
            cf == 'tout' ||
            _filiereMatches(courseFiliere, userFiliere);
      }
      return _filiereMatches(courseFiliere, userFiliere);
    }
    return false;
  }

  // Autres profils
  return _normalizeStr(courseCategory) == _normalizeStr(userLevel) && _filiereMatches(courseFiliere, userFiliere);
}

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
