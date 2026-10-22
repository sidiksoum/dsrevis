import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/data/sample_data.dart';

class SelectingCourseView extends StatefulWidget {
  const SelectingCourseView({
    super.key,
    required this.user,
    required this.localCourses,
    required this.allLocalQuestions,
    required this.bestQuizScores,
    required this.courseSearchQuery,
    required this.onSearchQueryChanged,
    required this.onCourseSelected,
    required this.onShowPremiumLockDialog,
  });

  final AppUser user;
  final List<CourseItem> localCourses;
  final List<QuizQuestion> allLocalQuestions;
  final Map<String, int> bestQuizScores;
  final String courseSearchQuery;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<CourseItem> onCourseSelected;
  final VoidCallback onShowPremiumLockDialog;

  @override
  State<SelectingCourseView> createState() => _SelectingCourseViewState();
}

class _SelectingCourseViewState extends State<SelectingCourseView> {
  String? _selectedLevelForL3; // 'Licence 1', 'Licence 2', 'Licence 3' ou null

  List<CourseItem> _getAccessibleCourses() {
    return widget.localCourses.where((c) {
      return isCourseAccessibleForUser(
        courseCategory: c.category,
        courseFiliere: c.filiere,
        user: widget.user,
      );
    }).toList();
  }

  List<CourseItem> _getFilteredCourses() {
    List<CourseItem> base = _getAccessibleCourses();

    if (isL3User(widget.user.level) && _selectedLevelForL3 != null) {
      base = base.where((c) => isCourseMatchingLevelCategory(c.category, _selectedLevelForL3!)).toList();
    }

    if (widget.courseSearchQuery.isNotEmpty) {
      final q = widget.courseSearchQuery.toLowerCase();
      base = base.where((c) =>
          c.title.toLowerCase().contains(q) ||
          c.summary.toLowerCase().contains(q) ||
          c.filiere.toLowerCase().contains(q)).toList();
    }
    return base;
  }

  int _countQuestionsForCourses(List<CourseItem> courses) {
    final titles = courses.map((c) => c.title.toLowerCase().trim()).toSet();
    return widget.allLocalQuestions
        .where((q) => titles.contains(q.courseTitle.toLowerCase().trim()))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final isL3 = isL3User(widget.user.level);

    // Si Licence 3 et aucun niveau sélectionné -> Hub intermédiaire de choix
    if (isL3 && _selectedLevelForL3 == null) {
      return _buildL3QuizHub(context);
    }

    // Vue de la liste des cours/quiz (avec retour possible au hub si L3)
    return PopScope(
      canPop: !isL3 || _selectedLevelForL3 == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedLevelForL3 != null) {
          setState(() {
            _selectedLevelForL3 = null;
            widget.onSearchQueryChanged('');
          });
        }
      },
      child: _buildQuizCourseListView(context),
    );
  }

  /// Hub intermédiaire de sélection pour les Quiz Licence 3
  Widget _buildL3QuizHub(BuildContext context) {
    final accessibleCourses = _getAccessibleCourses();
    final l1Courses = accessibleCourses.where((c) => isCourseMatchingLevelCategory(c.category, 'Licence 1')).toList();
    final l2Courses = accessibleCourses.where((c) => isCourseMatchingLevelCategory(c.category, 'Licence 2')).toList();
    final l3Courses = accessibleCourses.where((c) => isCourseMatchingLevelCategory(c.category, 'Licence 3')).toList();

    final l1QCount = _countQuestionsForCourses(l1Courses);
    final l2QCount = _countQuestionsForCourses(l2Courses);
    final l3QCount = _countQuestionsForCourses(l3Courses);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // En-tête Gradient
          Container(
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Espace Entraînement',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bonjour, ${widget.user.name} 👋',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.psychology_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.user.level} • ${widget.user.filiere}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.military_tech_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Choisissez la promotion académique pour passer vos séries de QCM / QCD d\'évaluation :',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste des 3 cartes de sélection de quiz
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                // Carte Quiz Licence 1
                _buildQuizLevelCard(
                  context: context,
                  levelTitle: 'Quiz Licence 1',
                  levelBadge: 'L1 • Tronc Commun',
                  levelDescription: 'QCM & QCD Fondamentaux (IDE & SFM)',
                  courseCount: l1Courses.length,
                  questionCount: l1QCount,
                  gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  accentColor: const Color(0xFF3B82F6),
                  icon: Icons.psychology_rounded,
                  onTap: () {
                    setState(() {
                      _selectedLevelForL3 = 'Licence 1';
                      widget.onSearchQueryChanged('');
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Carte Quiz Licence 2
                _buildQuizLevelCard(
                  context: context,
                  levelTitle: 'Quiz Licence 2',
                  levelBadge: 'L2 • Spécialité ${widget.user.filiere}',
                  levelDescription: 'Cas cliniques, pathologies & pharmacologie appliquée',
                  courseCount: l2Courses.length,
                  questionCount: l2QCount,
                  gradientColors: const [Color(0xFF0D9488), Color(0xFF0F766E)],
                  accentColor: const Color(0xFF14B8A6),
                  icon: Icons.quiz_rounded,
                  onTap: () {
                    setState(() {
                      _selectedLevelForL3 = 'Licence 2';
                      widget.onSearchQueryChanged('');
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Carte Quiz Licence 3
                _buildQuizLevelCard(
                  context: context,
                  levelTitle: 'Quiz Licence 3',
                  levelBadge: 'L3 • Promotion active (${widget.user.filiere})',
                  levelDescription: 'Sujets d\'examen d\'État & Entraînements intensifs de fin de cycle',
                  courseCount: l3Courses.length,
                  questionCount: l3QCount,
                  gradientColors: const [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                  accentColor: const Color(0xFF8B5CF6),
                  icon: Icons.workspace_premium_rounded,
                  onTap: () {
                    setState(() {
                      _selectedLevelForL3 = 'Licence 3';
                      widget.onSearchQueryChanged('');
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Carte interactive de sélection d'un niveau de quiz
  Widget _buildQuizLevelCard({
    required BuildContext context,
    required String levelTitle,
    required String levelBadge,
    required String levelDescription,
    required int courseCount,
    required int questionCount,
    required List<Color> gradientColors,
    required Color accentColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors.first.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              levelBadge,
                              style: TextStyle(
                                color: gradientColors.first,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            levelTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.muted, size: 16),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  levelDescription,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.library_books_rounded, size: 15, color: gradientColors.first),
                        const SizedBox(width: 5),
                        Text(
                          '$courseCount ${courseCount > 1 ? "matières" : "matière"}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: gradientColors.first,
                          ),
                        ),
                        if (questionCount > 0) ...[
                          const SizedBox(width: 8),
                          Text('•', style: TextStyle(color: Colors.grey.shade400)),
                          const SizedBox(width: 8),
                          Icon(Icons.help_outline_rounded, size: 15, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text(
                            '$questionCount QCM',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'S\'entraîner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Vue de liste des cours / matières de quiz pour un niveau
  Widget _buildQuizCourseListView(BuildContext context) {
    final filteredCourses = _getFilteredCourses();
    final isL3 = isL3User(widget.user.level);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // En-tête
          Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isL3 && _selectedLevelForL3 != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedLevelForL3 = null;
                            widget.onSearchQueryChanged('');
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Changer de niveau',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedLevelForL3!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  isL3 && _selectedLevelForL3 != null ? 'Quiz ${_selectedLevelForL3!}' : 'Quiz d\'Évaluation',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: widget.onSearchQueryChanged,
                  decoration: InputDecoration(
                    hintText: isL3 && _selectedLevelForL3 != null
                        ? 'Rechercher un quiz en ${_selectedLevelForL3!}...'
                        : 'Rechercher une matière de quiz...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des cours pour le quiz
          Expanded(
            child: filteredCourses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.quiz_rounded, size: 64, color: AppColors.muted),
                          const SizedBox(height: 12),
                          Text(
                            widget.courseSearchQuery.isNotEmpty
                                ? 'Aucune matière de quiz ne correspond à votre recherche.'
                                : 'Aucun quiz disponible pour ce niveau.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.muted,
                            ),
                          ),
                          if (isL3 && _selectedLevelForL3 != null) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedLevelForL3 = null;
                                  widget.onSearchQueryChanged('');
                                });
                              },
                              icon: const Icon(Icons.arrow_back_rounded, size: 16),
                              label: const Text('Retour aux niveaux'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.035,
                      vertical: 14,
                    ),
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      final isLocked = course.premiumOnly && !widget.user.premium;

                      final questionsForThisCourse = widget.allLocalQuestions
                          .where((q) => q.courseTitle.trim().toLowerCase() == course.title.trim().toLowerCase())
                          .toList();

                      final subjectsForThisCourse = questionsForThisCourse
                          .map((q) => q.subjectTitle.trim())
                          .where((s) => s.isNotEmpty)
                          .toSet()
                          .toList();

                      final totalSubjects = subjectsForThisCourse.length;
                      int validatedCount = 0;
                      for (final s in subjectsForThisCourse) {
                        final key = '${course.title}_$s';
                        if ((widget.bestQuizScores[key] ?? 0) >= 80) {
                          validatedCount++;
                        }
                      }

                      Color badgeBgColor;
                      Color badgeTextColor;
                      final filiereUpper = course.filiere.toUpperCase();
                      if (filiereUpper.contains('IDE')) {
                        badgeBgColor = const Color(0xFFF5F3FF);
                        badgeTextColor = const Color(0xFF7C3AED);
                      } else if (filiereUpper.contains('SF')) {
                        badgeBgColor = const Color(0xFFFDF2F8);
                        badgeTextColor = const Color(0xFFDB2777);
                      } else if (filiereUpper.contains('AS')) {
                        badgeBgColor = const Color(0xFFF0FDF4);
                        badgeTextColor = const Color(0xFF16A34A);
                      } else {
                        badgeBgColor = const Color(0xFFEFF6FF);
                        badgeTextColor = const Color(0xFF2563EB);
                      }

                      final String progressText = totalSubjects > 0
                          ? '$validatedCount/$totalSubjects sujets validés'
                          : 'Pas de sujet disponible';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              if (isLocked) {
                                widget.onShowPremiumLockDialog();
                              } else {
                                widget.onCourseSelected(course);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: badgeBgColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${course.category} • ${course.filiere}',
                                          style: TextStyle(
                                            color: badgeTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      if (course.premiumOnly)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isLocked ? Icons.lock_rounded : Icons.workspace_premium_rounded,
                                                color: const Color(0xFFD97706),
                                                size: 13,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isLocked ? 'Verrouillé' : 'Premium',
                                                style: const TextStyle(
                                                  color: Color(0xFFD97706),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    course.title,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.text,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (totalSubjects > 0) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: validatedCount / totalSubjects,
                                        minHeight: 6,
                                        color: AppColors.success,
                                        backgroundColor: AppColors.successLight,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        progressText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: totalSubjects > 0 ? AppColors.muted : AppColors.error,
                                        ),
                                      ),
                                      if (totalSubjects > 0)
                                        Text(
                                          '${((validatedCount / totalSubjects) * 100).toInt()}%',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.success,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
