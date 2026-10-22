import 'package:share_plus/share_plus.dart';
import 'package:dsrevis/core/constants/app_colors.dart';
import 'package:dsrevis/features/courses/presentation/pages/courses_screen.dart';
import 'package:dsrevis/features/progress/presentation/pages/progress_screen.dart';
import 'package:dsrevis/features/profile/presentation/pages/profile_screen.dart';
import 'package:dsrevis/features/quiz/presentation/pages/quiz_screen.dart';
import 'package:dsrevis/features/shared/data/sample_data.dart';
import 'package:dsrevis/core/services/firebase_service.dart';
import 'package:dsrevis/core/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.onLogout});
  final VoidCallback onLogout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late final AnimationController _bounceController;
  bool _dismissedBanner = false;

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
      _dismissedBanner = false; // Reactiver la banniere au changement d'onglet
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseService().startLivePremiumObserver();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _screens = [
      const HomeHomeScreen(),
      const CoursesScreen(),
      const QuizScreen(),
      const ProgressScreen(),
      ProfileScreen(onLogout: widget.onLogout),
    ];
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: currentSessionUserNotifier,
      builder: (context, user, child) {
        final isPremium = user?.premium ?? false;

        return Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: globalIsQuizActive,
            builder: (context, isQuizActive, child) {
              return Stack(
                children: [
                  IndexedStack(index: _currentIndex, children: _screens),
                  if (user != null &&
                      !isPremium &&
                      !_dismissedBanner &&
                      !isQuizActive)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Card(
                        elevation: 8,
                        color: const Color(0xFFFFFBEB),
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: Color(0xFFFDE68A),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Color(0xFFD97706),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      "Activez votre abonnement premium pour débloquer tous les cours et quiz. Contactez-nous sur WhatsApp.",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _dismissedBanner = true;
                                      });
                                    },
                                    child: Text(
                                      "Plus tard",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      launchWhatsAppPremiumRequest();
                                    },
                                    icon: const Icon(
                                      Icons.chat_bubble_rounded,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      "Contacter sur WhatsApp",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          bottomNavigationBar: ValueListenableBuilder<bool>(
            valueListenable: globalIsQuizActive,
            builder: (context, isQuizActive, child) {
              if (isQuizActive) return const SizedBox.shrink();
              return Container(
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTabItem(0, Icons.home_rounded, 'Accueil'),
                      _buildTabItem(1, Icons.menu_book_rounded, 'Cours'),
                      _buildSpecialQuizItem(),
                      _buildTabItem(3, Icons.insights_rounded, 'Progrès'),
                      _buildTabItem(4, Icons.person_rounded, 'Profil'),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabChanged(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.muted,
              size: isSelected ? 28 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialQuizItem() {
    final isSelected = _currentIndex == 2;
    return Expanded(
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -7 * _bounceController.value),
            child: GestureDetector(
              onTap: () => _onTabChanged(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.success
                            : Colors.transparent,
                        width: 3.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: 0.35 * _bounceController.value + 0.15,
                          ),
                          blurRadius: 10 + 4 * _bounceController.value,
                          offset: Offset(0, 4 + 4 * _bounceController.value),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quiz',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class HomeHomeScreen extends StatefulWidget {
  const HomeHomeScreen({super.key});
  @override
  State<HomeHomeScreen> createState() => _HomeHomeScreenState();
}

class _HomeHomeScreenState extends State<HomeHomeScreen> {
  bool _isSyncing = false;
  bool _checkingUpdates = false;
  bool _updatesAvailable = false;

  @override
  void initState() {
    super.initState();
    // Lancer la détection optimisée au chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    if (!globalIsOnline.value) return;
    setState(() => _checkingUpdates = true);
    try {
      final serverUpdate = await FirebaseService()
          .fetchLastDatabaseUpdateFromServer();
      final syncStatus = await DatabaseHelper.instance.getSyncStatus();
      final localSync = syncStatus['lastSyncTimestamp'] ?? '';
      setState(() {
        _updatesAvailable =
            serverUpdate.isNotEmpty && serverUpdate != localSync;
      });
    } catch (e) {
      debugPrint("Erreur lors de la détection des mises à jour : $e");
    } finally {
      setState(() => _checkingUpdates = false);
    }
  }

  void _triggerSync() async {
    if (!globalIsOnline.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de synchroniser : vous êtes hors-ligne.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSyncing = true);

    try {
      final firebaseService = FirebaseService();
      // Vérifie et synchronise d'abord le rôle Premium à chaud
      await firebaseService.checkAndSyncPremiumStatusInBackground();
      // Lance le téléchargement local des tables associées
      bool success = await firebaseService.synchronizeDataFromServer();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Catalogue synchronisé et actualisé à chaud !'),
            backgroundColor: AppColors.success,
          ),
        );
        await _checkForUpdates();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la synchronisation.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _handleHeaderMenuAction(String value) {
    switch (value) {
      case 'share':
        _shareApplication();
        break;
      case 'rate':
        _rateApplication();
        break;
      case 'about':
        _showAboutDialog();
        break;
      case 'help':
        _showHelpDialog();
        break;
    }
  }

  Future<void> _shareApplication() async {
    const shareMessage =
        "Téléchargez l'application DS REVIS, une application incroyable pour vos révisions médicales :\nhttps://play.google.com/store/apps/details?id=ci.sante.dsrevis";
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareMessage,
          subject: "DS REVIS - Révisions médicales",
        ),
      );
    } catch (e) {
      debugPrint('Erreur lors du partage : $e');
      final uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=ci.sante.dsrevis',
      );
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  Future<void> _rateApplication() async {
    final marketUri = Uri.parse('market://details?id=ci.sante.dsrevis');
    final webUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=ci.sante.dsrevis',
    );
    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Erreur ouverture notation : $e');
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Qui sommes-nous ?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'À propos de DS REVIS',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                        tooltip: 'Fermer',
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mission & Intro
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Text(
                            "Développée par des étudiants de l'INFAS et des étudiants en Informatique, DS REVIS est une application spécialement développée pour accompagner les étudiants en santé (INFAS, IDE, SF, AS).\n\n"
                            "L'application regroupe vos fiches de cours, vos évaluations corrigées (QCM & QCD) et suit votre progression académique, même sans connexion Internet.",
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.text,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Une méthode de révision ciblée',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Étudiez efficacement avec nos outils intégrés. Notre plateforme permet de centraliser et d'organiser les apprentissages pour que chaque session de révision soit synonyme de progression.",
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          icon: Icons.menu_book_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          title: 'Fiches de Cours',
                          description:
                              'Accédez à des fiches de cours synthétiques et validées, téléchargeables au format PDF pour une lecture hors-ligne.',
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureCard(
                          icon: Icons.quiz_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: 'Quiz QCM & QCD',
                          description:
                              "Testez vos connaissances en conditions réelles d'examen avec des questionnaires à choix multiples ou choix doubles (Vrai/Faux).",
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureCard(
                          icon: Icons.insights_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: 'Progression Analytique',
                          description:
                              'Visualisez en direct vos taux de réussite par matière et suivez votre assiduité pour combler vos lacunes.',
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureCard(
                          icon: Icons.cloud_sync_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'Sauvegarde & Synchronisation',
                          description:
                              'Grâce à notre intégration Firebase, vos scores sont sauvegardés et synchronisés automatiquement dès que vous retrouvez du réseau.',
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFCD34D),
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                color: Color(0xFFD97706),
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Engagés pour votre réussite : cette application est le fruit d'un dévouement constant et d'une volonté solidaire de propulser chaque étudiant en santé vers l'excellence.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF92400E),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom actions
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "J'ai compris",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.headset_mic_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aide & Support',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Nous sommes à votre écoute',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                        tooltip: 'Fermer',
                      ),
                    ],
                  ),
                ),
                // Body
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Une question, une difficulté ou un besoin d'assistance concernant l'application ? Contactez directement notre équipe de support.",
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Email box
                      InkWell(
                        onTap: () async {
                          final uri = Uri.parse(
                            'mailto:ds.revis225@gmail.com?subject=Demande%20d%27aide%20DS%20REVIS',
                          );
                          try {
                            await launchUrl(uri);
                          } catch (e) {
                            debugPrint('Erreur ouverture email : $e');
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFBBF7D0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDCFCE7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF16A34A),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email du Support',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'ds.revis225@gmail.com',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF166534),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.open_in_new_rounded,
                                color: Color(0xFF16A34A),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Support Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            supportRequest();
                          },
                          icon: const Icon(Icons.chat_bubble_rounded, size: 20),
                          label: const Text(
                            "Demander de l'aide",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ÉCOUTEUR RÉACTIF GLOBAL : Force la mise à jour instantanée au clic sur le bouton
    return ValueListenableBuilder<AppUser?>(
      valueListenable: currentSessionUserNotifier,
      builder: (context, liveUser, _) {
        final user =
            liveUser ??
            currentUser ??
            AppUser(
              name: "Étudiant",
              email: "",
              level: "Licence 1",
              filiere: "IDE",
              premium: false,
              isActive: true,
            );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: ValueListenableBuilder<bool>(
            valueListenable: globalIsOnline,
            builder: (context, isOnline, _) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 48, 16, 36),
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
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      'Bonjour, ${user.name}',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Text(
                                              '${user.filiere} • ${user.level}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        if (user.premium) ...[
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.success,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .workspace_premium_rounded,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 3),
                                                Text(
                                                  'PREMIUM',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_vert_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    tooltip: 'Menu options',
                                    offset: const Offset(0, 38),
                                    color: Colors.white,
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    onSelected: _handleHeaderMenuAction,
                                    itemBuilder: (BuildContext context) => [
                                      _buildMenuItem(
                                        value: 'share',
                                        icon: Icons.share_rounded,
                                        iconColor: const Color(0xFF2563EB),
                                        title: "Partager l'application",
                                      ),
                                      _buildMenuItem(
                                        value: 'rate',
                                        icon: Icons.star_rounded,
                                        iconColor: const Color(0xFFF59E0B),
                                        title: "Noter l'application",
                                      ),
                                      _buildMenuItem(
                                        value: 'about',
                                        icon: Icons.info_outline_rounded,
                                        iconColor: const Color(0xFF7C3AED),
                                        title: "Qui sommes-nous",
                                      ),
                                      _buildMenuItem(
                                        value: 'help',
                                        icon: Icons.help_outline_rounded,
                                        iconColor: const Color(0xFF10B981),
                                        title: "Aide",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/logods.png',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isOnline
                                          ? Icons.wifi_rounded
                                          : Icons.wifi_off_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      isOnline
                                          ? 'Mode : En Ligne'
                                          : 'Mode : Hors Ligne',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.circle,
                                  color: isOnline
                                      ? AppColors.success
                                      : Colors.orange,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statut & Synchronisation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryLight,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.sync_rounded,
                                          color: AppColors.primary,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      const Expanded(
                                        child: Text(
                                          'Synchronisation',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.text,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Téléchargez les fiches locales de cours et mettez à jour vos questionnaires de quiz depuis le Cloud. Cliquez deux fois sur le bouton Synchroniser',
                                    style: TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (_checkingUpdates)
                                    const Row(
                                      children: [
                                        SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Vérification des mises à jour...',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    )
                                  else if (_updatesAvailable)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFA7F3D0),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.info_rounded,
                                            color: Color(0xFF10B981),
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Des mises à jour sont disponibles !',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: AppColors.muted,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Vos données locales sont à jour.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.text,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: _isSyncing
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : ElevatedButton.icon(
                                            onPressed: _triggerSync,
                                            icon: const Icon(
                                              Icons.cloud_download_rounded,
                                              size: 20,
                                            ),
                                            label: const Text('Synchroniser'),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
