import 'package:dsrevis/core/constants/app_colors.dart';
import 'package:dsrevis/features/shared/data/sample_data.dart';
import 'package:dsrevis/core/services/firebase_service.dart';
import 'package:dsrevis/core/services/database_helper.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: currentSessionUserNotifier,
      builder: (context, liveUser, _) {
        final user = liveUser ?? currentUser ?? AppUser(name: "Étudiant INFAS", email: "non connecté", level: "L1", filiere: "IDE", premium: false, isActive: true);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Mon Profil',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.025, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 34,
                                    backgroundColor: AppColors.primaryLight,
                                    child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 40),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text)),
                                        const SizedBox(height: 4),
                                        Text(user.email, style: const TextStyle(color: AppColors.muted, fontSize: 15)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              const Divider(),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.start,
                                children: [
                                  Chip(
                                    label: Text(user.level, style: const TextStyle(fontSize: 14)),
                                    avatar: const Icon(Icons.school_rounded, size: 16, color: AppColors.primary),
                                  ),
                                  Chip(
                                    label: Text(user.filiere, style: const TextStyle(fontSize: 14)),
                                    avatar: const Icon(Icons.medical_services_rounded, size: 16, color: AppColors.primary),
                                  ),
                                  Chip(
                                    label: Text(user.premium ? 'Premium ✨' : 'Gratuit', style: const TextStyle(fontSize: 14)),
                                    backgroundColor: user.premium ? AppColors.successLight : Colors.grey.shade100,
                                    labelStyle: TextStyle(color: user.premium ? AppColors.success : AppColors.muted, fontWeight: FontWeight.bold),
                                    avatar: Icon(
                                      user.premium ? Icons.workspace_premium_rounded : Icons.person_outline_rounded,
                                      size: 16,
                                      color: user.premium ? AppColors.success : AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      const Text(
                        'Mes Succès & Badges',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text),
                      ),
                      const SizedBox(height: 14),
                      FutureBuilder<Map<String, dynamic>>(
                        future: () async {
                          final userId = currentUser?.id ?? 'guest';
                          final streak = await DatabaseHelper.instance.getRevisionDaysStreak(userId);
                          final offlineQuizzes = await DatabaseHelper.instance.getOfflineQuizCount(userId);
                          final topCourses = await DatabaseHelper.instance.getTop3BestCourses(userId);
                          final bestQuiz = topCourses.isNotEmpty
                              ? "${topCourses[0]['courseTitle']} (${topCourses[0]['bestPercentage']}%)"
                              : "Aucun quiz validé";
                          return {
                            'streak': streak,
                            'bestQuiz': bestQuiz,
                            'offlineQuizzes': offlineQuizzes,
                          };
                        }(),
                        builder: (context, snapshot) {
                          final data = snapshot.data ?? {
                            'streak': 0,
                            'bestQuiz': 'Aucun quiz validé',
                            'offlineQuizzes': 0,
                          };

                          final streak = data['streak'] as int;
                          final bestQuiz = data['bestQuiz'] as String;
                          final offlineQuizzes = data['offlineQuizzes'] as int;

                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  _buildBadgeItem(
                                    icon: Icons.local_fire_department_rounded,
                                    color: Colors.red,
                                    title: streak > 0 ? 'Série de $streak jours' : 'Série de révision',
                                    subtitle: streak > 0 
                                        ? 'Vous avez révisé $streak jours (lecture + quiz le même jour).' 
                                        : 'Faites un quiz et lisez un cours le même jour pour lancer votre série.',
                                  ),
                                  const Divider(height: 28),
                                  _buildBadgeItem(
                                    icon: Icons.stars_rounded,
                                    color: Colors.amber,
                                    title: 'As du Quiz',
                                    subtitle: 'Meilleur score : $bestQuiz.',
                                  ),
                                  const Divider(height: 28),
                                  _buildBadgeItem(
                                    icon: Icons.offline_bolt_rounded,
                                    color: AppColors.success,
                                    title: 'Guerrier Hors-ligne',
                                    subtitle: '$offlineQuizzes quiz complétés en mode déconnecté.',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 38),
                      
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await FirebaseService().signOut();
                            onLogout();
                          },
                          icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                          label: const Text('Se déconnecter', style: TextStyle(color: AppColors.error)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error, width: 1.8),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}