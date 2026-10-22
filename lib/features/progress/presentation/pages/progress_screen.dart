import 'package:dsrevis/core/constants/app_colors.dart';
import 'package:dsrevis/features/shared/data/sample_data.dart';
import 'package:dsrevis/core/services/database_helper.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progressItems = getSampleProgressItems(); // Conserve la structure graphique stable

    return ValueListenableBuilder<AppUser?>(
      valueListenable: currentSessionUserNotifier,
      builder: (context, liveUser, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(
                  24,
                  MediaQuery.of(context).padding.top + 16,
                  24,
                  24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Progression',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.025,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tableau d\'honneur challenges',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 18),

                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: DatabaseHelper.instance.getTop3BestCourses(currentUser?.id ?? 'guest'),
                        builder: (context, snapshot) {
                          final topCourses = snapshot.data ?? [];
                          
                          final p1Name = topCourses.isNotEmpty ? topCourses[0]['courseTitle'] as String : 'Aucune leçon';
                          final p1Score = topCourses.isNotEmpty ? '${topCourses[0]['bestPercentage']}%' : '--';
                          
                          final p2Name = topCourses.length > 1 ? topCourses[1]['courseTitle'] as String : 'Aucune leçon';
                          final p2Score = topCourses.length > 1 ? '${topCourses[1]['bestPercentage']}%' : '--';
                          
                          final p3Name = topCourses.length > 2 ? topCourses[2]['courseTitle'] as String : 'Aucune leçon';
                          final p3Score = topCourses.length > 2 ? '${topCourses[2]['bestPercentage']}%' : '--';

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Tableau d\'honneur (Meilleurs Quiz)',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // 2e place
                                    Expanded(
                                      child: _buildPodiumUser(
                                        name: p2Name,
                                        score: p2Score,
                                        place: '2',
                                        avatarColor: Colors.orange.shade100,
                                        avatarLetter: '2',
                                        podiumHeight: 85,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // 1re place
                                    Expanded(
                                      child: _buildPodiumUser(
                                        name: p1Name,
                                        score: p1Score,
                                        place: '1',
                                        avatarColor: Colors.yellow.shade100,
                                        avatarLetter: '1',
                                        podiumHeight: 118,
                                        hasCrown: true,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // 3e place
                                    Expanded(
                                      child: _buildPodiumUser(
                                        name: p3Name,
                                        score: p3Score,
                                        place: '3',
                                        avatarColor: Colors.pink.shade100,
                                        avatarLetter: '3',
                                        podiumHeight: 68,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        'Mes statistiques de révision',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Injection dynamique autonome des indicateurs de réussite
                      FutureBuilder<List<QuizQuestion>>(
                        future: DatabaseHelper.instance.getLocalQuizQuestions(currentUser?.id ?? 'guest'),
                        builder: (context, snapshot) {
                          int totalQuestionsCount = snapshot.hasData ? snapshot.data!.length : 0;
                          
                          return Column(
                            children: progressItems.map((item) {
                              double practicalValue = item.value;
                              String subtitleText = item.subtitle;
                              
                              // Dynamisation simple de la jauge si les données sont chargées
                              if (item.label == "Quiz Validés" && totalQuestionsCount > 0) {
                                practicalValue = 0.0; 
                                subtitleText = "0 quiz réussi sur $totalQuestionsCount questions locales";
                              }

                              return Card(
                                margin: const EdgeInsets.only(bottom: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(item.label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 15)),
                                          Text('${(practicalValue * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 15)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: practicalValue,
                                          minHeight: 10,
                                          color: AppColors.success,
                                          backgroundColor: AppColors.successLight,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(subtitleText, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Historique récent',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: DatabaseHelper.instance.getQuizHistory(currentUser?.id ?? 'guest'),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                              child: const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'Aucun quiz récent. Commencez à vous entraîner !',
                                    style: TextStyle(color: AppColors.muted),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          }

                          final list = snapshot.data!.take(5).toList();

                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: list.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final row = list[index];
                                final title = row['courseTitle'] as String;
                                final score = row['score'] as int;
                                final total = row['totalQuestions'] as int;
                                final isOffline = (row['isOffline'] as int) == 1;
                                final pct = total > 0 ? (score / total * 100).toInt() : 0;

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: pct >= 50 ? AppColors.successLight : AppColors.errorLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      pct >= 50 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                      color: pct >= 50 ? AppColors.success : AppColors.error,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text('Quiz : $title', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    'Score : $score / $total correctes • ${isOffline ? "Hors-ligne" : "En ligne"}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  trailing: Text(
                                    '$pct%',
                                    style: TextStyle(
                                      color: pct >= 50 ? AppColors.success : AppColors.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
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

  Widget _buildPodiumUser({
    required String name,
    required String score,
    required String place,
    required Color avatarColor,
    required String avatarLetter,
    required double podiumHeight,
    bool hasCrown = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasCrown) const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 26),
        CircleAvatar(
          radius: 28,
          backgroundColor: avatarColor,
          child: Text(avatarLetter, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 15)),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        Text(score, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 10),
        Container(
          width: 68,
          height: podiumHeight,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)), border: Border.all(color: Colors.white30)),
          child: Center(child: Text(place, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900))),
        ),
      ],
    );
  }
}