import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/data/sample_data.dart';
import 'bouncing_verify_button.dart';

class ActiveQuizView extends StatefulWidget {
  const ActiveQuizView({
    super.key,
    required this.course,
    required this.activeQuestions,
    required this.currentIndex,
    required this.selectedAnswer,
    required this.showResult,
    required this.remainingSeconds,
    required this.pointsAccumulated,
    required this.formattedTime,
    required this.onOptionSelected,
    required this.onVerify,
    required this.onNext,
    required this.onBackPressed,
  });

  final CourseItem course;
  final List<QuizQuestion> activeQuestions;
  final int currentIndex;
  final String? selectedAnswer;
  final bool showResult;
  final int remainingSeconds;
  final int pointsAccumulated;
  final String formattedTime;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onVerify;
  final VoidCallback onNext;
  final VoidCallback onBackPressed;

  @override
  State<ActiveQuizView> createState() => _ActiveQuizViewState();
}

class _ActiveQuizViewState extends State<ActiveQuizView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ActiveQuizView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Nouvelle question : retour automatique en haut de page
    if (oldWidget.currentIndex != widget.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    // Affichage de la réponse/explication : défilement doux vers l'explication
    if (!oldWidget.showResult && widget.showResult) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.activeQuestions[widget.currentIndex];

    final isCorrect = () {
      if (widget.selectedAnswer == null) return false;
      final sel = widget.selectedAnswer!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList()
        ..sort();
      final corr = question.correctAnswer
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList()
        ..sort();
      if (sel.length != corr.length) return false;
      for (int i = 0; i < sel.length; i++) {
        if (sel[i] != corr[i]) return false;
      }
      return true;
    }();

    final progressValue = (widget.currentIndex + 1) / widget.activeQuestions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 1. En-tête Gradient Fixé en haut
          Container(
            padding: EdgeInsets.fromLTRB(
              12,
              MediaQuery.of(context).padding.top + 10,
              20,
              18,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                  onPressed: widget.onBackPressed,
                  tooltip: 'Quitter le quiz',
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${question.subjectLevel} • ${question.subjectTitle}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.course.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Text(
                    '${widget.currentIndex + 1}/${widget.activeQuestions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Zone Principale Défilable (Question + Options + Explication)
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre de progression linéaire & Badges Chronomètre / Score
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 6,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge Chronomètre
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: widget.remainingSeconds <= 30
                              ? AppColors.errorLight
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              size: 16,
                              color: widget.remainingSeconds <= 30
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.formattedTime,
                              style: TextStyle(
                                color: widget.remainingSeconds <= 30
                                    ? AppColors.error
                                    : AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Badge Score
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: widget.pointsAccumulated >= 0
                              ? AppColors.successLight
                              : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              size: 16,
                              color: widget.pointsAccumulated >= 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.pointsAccumulated} pts',
                              style: TextStyle(
                                color: widget.pointsAccumulated >= 0
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Carte Énoncé de la Question (Hauteur adaptative illimitée)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      question.type == 'QCD'
                                          ? Icons.flaky_rounded
                                          : Icons.checklist_rounded,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      question.type,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  widget.course.category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            question.prompt,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Liste des Options de Réponses (Défile avec la question)
                  ...question.options.map((option) {
                    final selectedList = widget.selectedAnswer
                            ?.split(',')
                            .map((e) => e.trim())
                            .toList() ??
                        [];
                    final isSelected = selectedList.contains(option);

                    final correctList = question.correctAnswer
                        .split(',')
                        .map((e) => e.trim())
                        .toList();
                    final isCorrectOption = correctList.contains(option);

                    Color cardBorderColor = AppColors.border;
                    Color cardBgColor = Colors.white;
                    Widget? trailingWidget;

                    if (widget.showResult) {
                      if (isCorrectOption) {
                        cardBgColor = AppColors.successLight;
                        cardBorderColor = AppColors.success;
                        trailingWidget = const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 24,
                        );
                      } else if (isSelected) {
                        cardBgColor = AppColors.errorLight;
                        cardBorderColor = AppColors.error;
                        trailingWidget = const Icon(
                          Icons.cancel_rounded,
                          color: AppColors.error,
                          size: 24,
                        );
                      }
                    } else {
                      if (isSelected) {
                        cardBgColor = AppColors.primaryLight;
                        cardBorderColor = AppColors.primary;
                      }
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: cardBorderColor,
                          width: isSelected ? 2.2 : 1.2,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: cardBorderColor.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: widget.showResult
                              ? null
                              : () => widget.onOptionSelected(option),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                          isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: AppColors.text,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                if (trailingWidget != null) ...[
                                  const SizedBox(width: 10),
                                  trailingWidget,
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Carte d'Explication & Correction (visible après vérification)
                  if (widget.showResult) ...[
                    const SizedBox(height: 10),
                    Card(
                      elevation: 0,
                      color: isCorrect
                          ? AppColors.successLight.withValues(alpha: 0.5)
                          : AppColors.errorLight.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(
                          color: isCorrect
                              ? AppColors.success.withValues(alpha: 0.3)
                              : AppColors.error.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle_rounded
                                      : Icons.info_outline_rounded,
                                  color: isCorrect ? AppColors.success : AppColors.error,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isCorrect
                                      ? 'Excellente réponse !'
                                      : 'Oups, mauvaise réponse...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: isCorrect ? AppColors.success : AppColors.error,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            if (question.explanation.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                question.explanation,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.text,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Marge supplémentaire pour ne jamais chevaucher la barre du bas
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // 3. Barre d'Action Inférieure Épinglée (Toujours 100% visible et accessible)
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 8
                  : 18,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
            ),
            child: SizedBox(
              width: double.infinity,
              child: BouncingVerifyButton(
                onPressed: widget.selectedAnswer == null
                    ? null
                    : () {
                        if (widget.showResult) {
                          widget.onNext();
                        } else {
                          widget.onVerify();
                        }
                      },
                label: widget.showResult ? 'Question Suivante' : 'Vérifier la réponse',
                icon: widget.showResult
                    ? Icons.arrow_forward_rounded
                    : Icons.verified_user_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
