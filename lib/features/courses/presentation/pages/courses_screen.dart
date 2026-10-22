import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/data/sample_data.dart';
import '../../../../core/services/database_helper.dart';
import '../../../../core/services/firebase_service.dart';
import 'course_details_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _searchQuery = '';
  String? _selectedLevelForL3; // 'Licence 1', 'Licence 2', 'Licence 3' ou null (affiche le Hub)
  List<CourseItem> _allLocalCourses = [];
  Map<String, int> _readingProgress = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    currentSessionUserNotifier.addListener(_loadCourses);
  }

  @override
  void dispose() {
    currentSessionUserNotifier.removeListener(_loadCourses);
    super.dispose();
  }

  void _loadCourses() async {
    final courses = await DatabaseHelper.instance.getLocalCourses();
    final progressMap = <String, int>{};
    final userId = currentUser?.id ?? 'guest';
    for (var c in courses) {
      final pct = await DatabaseHelper.instance.getReadingProgressPercentage(c.title, userId);
      progressMap[c.title] = pct;
    }
    if (mounted) {
      setState(() {
        _allLocalCourses = courses;
        _readingProgress = progressMap;
        _isLoading = false;
      });
    }
  }

  List<CourseItem> _getAccessibleCoursesForUser(AppUser user) {
    return _allLocalCourses.where((c) {
      return isCourseAccessibleForUser(
        courseCategory: c.category,
        courseFiliere: c.filiere,
        user: user,
      );
    }).toList();
  }

  List<CourseItem> _getFilteredCourses(AppUser user) {
    List<CourseItem> baseList = _getAccessibleCoursesForUser(user);

    // Si utilisateur L3 et qu'un niveau est sélectionné, on filtre par ce niveau
    if (isL3User(user.level) && _selectedLevelForL3 != null) {
      baseList = baseList.where((c) {
        return isCourseMatchingLevelCategory(c.category, _selectedLevelForL3!);
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      baseList = baseList.where((c) =>
          c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.summary.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.filiere.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return baseList;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: currentSessionUserNotifier,
      builder: (context, liveUser, _) {
        final user = liveUser ??
            currentUser ??
            AppUser(
              name: 'Étudiant',
              email: '',
              level: 'Licence 1',
              filiere: 'IDE',
              premium: false,
              isActive: true,
            );

        // Si l'utilisateur est en Licence 3 et n'a pas encore sélectionné de niveau
        if (isL3User(user.level) && _selectedLevelForL3 == null) {
          return _buildL3LevelHub(context, user);
        }

        // Vue normale de la liste des cours (pour L1, L2 ou pour L3 ayant sélectionné un niveau)
        return PopScope(
          canPop: !isL3User(user.level) || _selectedLevelForL3 == null,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (_selectedLevelForL3 != null) {
              setState(() {
                _selectedLevelForL3 = null;
                _searchQuery = '';
              });
            }
          },
          child: _buildCourseListView(context, user),
        );
      },
    );
  }

  /// Interface Intermédiaire de sélection de niveau pour les étudiants Licence 3
  Widget _buildL3LevelHub(BuildContext context, AppUser user) {
    final accessibleCourses = _getAccessibleCoursesForUser(user);
    final l1Courses = accessibleCourses.where((c) => isCourseMatchingLevelCategory(c.category, 'Licence 1')).toList();
    final l2Courses = accessibleCourses.where((c) => isCourseMatchingLevelCategory(c.category, 'Licence 2')).toList();
    final l3Courses = accessibleCourses.where((c) => isCourseMatchingLevelCategory(c.category, 'Licence 3')).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // En-tête avec dégradé moderne
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
                          'Fiches de Révision',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bonjour, ${user.name} 👋',
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
                        border: Border.all(color: Colors.white30, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.school_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${user.level} • ${user.filiere}',
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
                      Icon(Icons.layers_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Accès global Licence 3 actif. Choisissez une promotion pour consulter les fiches associées :',
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

          // Liste des 3 cartes de sélection
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    children: [
                      // Carte Licence 1
                      _buildLevelCard(
                        context: context,
                        levelTitle: 'Cours Licence 1',
                        levelBadge: 'L1 • Tronc Commun',
                        levelDescription: 'Bases fondamentales & Tronc commun (IDE & SFM)',
                        courseCount: l1Courses.length,
                        gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        accentColor: const Color(0xFF3B82F6),
                        icon: Icons.auto_stories_rounded,
                        onTap: () {
                          setState(() {
                            _selectedLevelForL3 = 'Licence 1';
                            _searchQuery = '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Carte Licence 2
                      _buildLevelCard(
                        context: context,
                        levelTitle: 'Cours Licence 2',
                        levelBadge: 'L2 • Spécialité ${user.filiere}',
                        levelDescription: 'Pathologies, soins cliniques et pharmacologie',
                        courseCount: l2Courses.length,
                        gradientColors: const [Color(0xFF0D9488), Color(0xFF0F766E)],
                        accentColor: const Color(0xFF14B8A6),
                        icon: Icons.medical_services_rounded,
                        onTap: () {
                          setState(() {
                            _selectedLevelForL3 = 'Licence 2';
                            _searchQuery = '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Carte Licence 3
                      _buildLevelCard(
                        context: context,
                        levelTitle: 'Cours Licence 3',
                        levelBadge: 'L3 • Promotion active (${user.filiere})',
                        levelDescription: "Programme de fin de cycle & Préparation au Diplôme d'État",
                        courseCount: l3Courses.length,
                        gradientColors: const [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                        accentColor: const Color(0xFF8B5CF6),
                        icon: Icons.workspace_premium_rounded,
                        onTap: () {
                          setState(() {
                            _selectedLevelForL3 = 'Licence 3';
                            _searchQuery = '';
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

  /// Carte interactive représentant un niveau académique
  Widget _buildLevelCard({
    required BuildContext context,
    required String levelTitle,
    required String levelBadge,
    required String levelDescription,
    required int courseCount,
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
                        Icon(Icons.menu_book_rounded, size: 16, color: gradientColors.first),
                        const SizedBox(width: 6),
                        Text(
                          '$courseCount ${courseCount > 1 ? "fiches disponibles" : "fiche disponible"}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: gradientColors.first,
                          ),
                        ),
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
                            'Consulter',
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

  /// Vue normale de la liste des cours pour un niveau
  Widget _buildCourseListView(BuildContext context, AppUser user) {
    final filteredCourses = _getFilteredCourses(user);
    final isL3 = isL3User(user.level);

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
                            _searchQuery = '';
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
                  isL3 && _selectedLevelForL3 != null ? 'Cours ${_selectedLevelForL3!}' : 'Fiches de Cours',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: isL3 && _selectedLevelForL3 != null
                        ? 'Rechercher en ${_selectedLevelForL3!}...'
                        : 'Rechercher un cours...',
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

          // Liste des cours
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCourses.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search_off_rounded, size: 64, color: AppColors.muted),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Aucun cours ne correspond à votre recherche.'
                                    : 'Aucune fiche disponible pour ce niveau.',
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
                                      _searchQuery = '';
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
                          final isLocked = course.premiumOnly && !user.premium;
                          final readingPct = _readingProgress[course.title] ?? 0;
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                              side: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () {
                                if (isLocked) {
                                  _showPremiumLockDialog();
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CourseDetailsScreen(course: course),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${course.category} • ${course.filiere}',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
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
                                    const SizedBox(height: 10),
                                    Text(
                                      course.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      course.summary,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.muted,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: readingPct / 100.0,
                                              minHeight: 6,
                                              color: AppColors.primary,
                                              backgroundColor: AppColors.primaryLight,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '$readingPct% lu',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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

  void _showPremiumLockDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: AppColors.success, size: 26),
            SizedBox(width: 8),
            Text('Contenu Premium', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Cette fiche de cours est réservée aux abonnés premium. Activez votre compte premium pour y accéder. Contactez les administrateurs sur WhatsApp pour une activation rapide.',
          style: TextStyle(height: 1.4, fontSize: 15),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Plus tard', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await launchWhatsAppPremiumRequest();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('Contacter sur WhatsApp'),
          ),
        ],
      ),
    );
  }
}
