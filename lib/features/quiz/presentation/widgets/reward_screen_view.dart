import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/data/sample_data.dart';
import 'celebration_animation.dart';

class RewardScreenView extends StatelessWidget {
  const RewardScreenView({
    super.key,
    required this.course,
    required this.activeQuestions,
    required this.correctAnswersCount,
    required this.pointsAccumulated,
    required this.userAnswers,
    required this.onRestart,
    required this.onChooseAnotherSubject,
  });

  final CourseItem course;
  final List<QuizQuestion> activeQuestions;
  final int correctAnswersCount;
  final int pointsAccumulated;
  final List<String?> userAnswers;
  final VoidCallback onRestart;
  final VoidCallback onChooseAnotherSubject;

  @override
  Widget build(BuildContext context) {
    final double successRate = activeQuestions.isNotEmpty ? (correctAnswersCount / activeQuestions.length) : 0.0;
    final int percent = (successRate * 100).toInt();
    final bool isSuccess = percent >= 50;

    String quote;
    if (percent == 100) {
      quote = "Félicitations, futur Agent de Santé ! Vous avez obtenu un score parfait. Votre maîtrise de ce module est absolue !";
    } else if (percent >= 50) {
      quote = "Très bon travail ! Vous êtes sur la voie du succès aux examens de l'INFAS. Continuez ainsi !";
    } else {
      quote = "Continuez d'apprendre ! Relisez la fiche de cours associée à cette leçon, puis retentez l'évaluation pour vous améliorer.";
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.025, vertical: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CelebrationAnimation(isSuccess: isSuccess),
                const SizedBox(height: 28),
                Text(isSuccess ? 'Félicitations !' : 'Quiz Terminé !', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isSuccess ? AppColors.success : AppColors.text)),
                const SizedBox(height: 14),
                Text(course.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: AppColors.muted, fontWeight: FontWeight.bold)),
                const SizedBox(height: 28),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26), side: BorderSide(color: isSuccess ? AppColors.success.withValues(alpha: 0.5) : AppColors.border, width: isSuccess ? 2.0 : 1.2)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn('Réponses', '$correctAnswersCount / ${activeQuestions.length}', isSuccess),
                            _buildStatColumn('Score Final', '$pointsAccumulated pts', isSuccess),
                            _buildStatColumn('Réussite', '$percent %', isSuccess),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 14),
                        Text(quote, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: AppColors.text, height: 1.4, fontStyle: FontStyle.italic, fontWeight: isSuccess ? FontWeight.w600 : FontWeight.normal)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 38),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showCorrectionDialog(context),
                    icon: const Icon(Icons.fact_check_rounded, size: 20),
                    label: const Text('Voir la correction du quiz'),
                    style: OutlinedButton.styleFrom(foregroundColor: isSuccess ? AppColors.success : AppColors.primary, side: BorderSide(color: isSuccess ? AppColors.success : AppColors.primary, width: 2), padding: const EdgeInsets.symmetric(vertical: 18)),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRestart,
                    icon: const Icon(Icons.replay_rounded, size: 20),
                    label: const Text('Recommencer le Quiz'),
                    style: ElevatedButton.styleFrom(backgroundColor: isSuccess ? AppColors.success : AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 18)),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onChooseAnotherSubject,
                    icon: const Icon(Icons.list_rounded, size: 20),
                    label: const Text('Choisir un autre Sujet'),
                    style: OutlinedButton.styleFrom(foregroundColor: isSuccess ? AppColors.success : AppColors.primary, side: BorderSide(color: isSuccess ? AppColors.success : AppColors.primary, width: 2), padding: const EdgeInsets.symmetric(vertical: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCorrectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 680),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.fact_check_rounded, color: AppColors.primary, size: 26),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Correction du quiz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text))),
                    IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Voici les bonnes réponses et les explications associées à chaque question.', style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.4)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: activeQuestions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final question = activeQuestions[index];
                      final selectedAnswer = userAnswers[index];
                      final isCorrect = selectedAnswer == question.correctAnswer;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isCorrect ? AppColors.successLight.withValues(alpha: 0.25) : AppColors.errorLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isCorrect ? AppColors.success.withValues(alpha: 0.35) : AppColors.error.withValues(alpha: 0.35), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)), child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                                const SizedBox(width: 10),
                                Expanded(child: Text(question.prompt, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.text, height: 1.35))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (selectedAnswer != null) Text('Votre réponse : $selectedAnswer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isCorrect ? AppColors.success : AppColors.error)),
                            const SizedBox(height: 8),
                            Text('Bonne réponse : ${question.correctAnswer}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success)),
                            const SizedBox(height: 10),
                            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Text(question.explanation, style: const TextStyle(fontSize: 13, color: AppColors.text, height: 1.45))),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value, bool isSuccess) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, color: isSuccess ? AppColors.success : AppColors.primary, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
