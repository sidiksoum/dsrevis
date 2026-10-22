import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/data/sample_data.dart';

class SelectingSubjectView extends StatelessWidget {
  const SelectingSubjectView({
    super.key,
    required this.selectedCourse,
    required this.allLocalQuestions,
    required this.onSubjectSelected,
    required this.onBackPressed,
    required this.fallbackQuestions,
  });

  final CourseItem selectedCourse;
  final List<QuizQuestion> allLocalQuestions;
  final Function(CourseItem course, String subjectLevel, List<QuizQuestion> questions) onSubjectSelected;
  final VoidCallback onBackPressed;
  final List<QuizQuestion> fallbackQuestions;

  @override
  Widget build(BuildContext context) {
    final matchedQuestions = allLocalQuestions
        .where((q) => q.courseTitle.trim().toLowerCase() == selectedCourse.title.trim().toLowerCase())
        .toList();

    // Regrouper les questions par subjectLevel
    final Map<String, List<QuizQuestion>> subjectsMap = {};
    for (var q in matchedQuestions) {
      final level = q.subjectLevel;
      if (!subjectsMap.containsKey(level)) {
        subjectsMap[level] = [];
      }
      subjectsMap[level]!.add(q);
    }

    // Trier les sujets numériquement
    final sortedLevels = subjectsMap.keys.toList()
      ..sort((a, b) {
        try {
          final intA = int.parse(a.replaceAll(RegExp(r'[^0-9]'), ''));
          final intB = int.parse(b.replaceAll(RegExp(r'[^0-9]'), ''));
          return intA.compareTo(intB);
        } catch (_) {
          return a.compareTo(b);
        }
      });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top + 12, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                  onPressed: onBackPressed,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choisir un Sujet',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedCourse.title,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: sortedLevels.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Pas de sujet disponible',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.025),
                    itemCount: sortedLevels.length,
                    itemBuilder: (context, index) {
                      final level = sortedLevels[index];
                      final questions = subjectsMap[level]!;
                      final title = questions.isNotEmpty ? questions.first.subjectTitle : 'Généralités';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            onSubjectSelected(selectedCourse, level, questions);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    level.replaceAll(RegExp(r'[^0-9]'), ''),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.orange,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        level,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${questions.length} questions',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: AppColors.muted,
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
}
