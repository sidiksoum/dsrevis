import 'dart:async';
import 'package:dsrevis/core/constants/app_colors.dart';
import 'package:dsrevis/features/shared/data/sample_data.dart';
import 'package:dsrevis/core/services/database_helper.dart';
import 'package:dsrevis/core/services/firebase_service.dart';
import 'package:flutter/material.dart';

import '../widgets/selecting_course_view.dart';
import '../widgets/selecting_subject_view.dart';
import '../widgets/active_quiz_view.dart';
import '../widgets/reward_screen_view.dart';

enum QuizState { selectingCourse, selectingSubject, activeQuiz, rewardScreen }

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizState _quizState = QuizState.selectingCourse;
  CourseItem? _selectedCourse;
  String? _selectedSubjectLevel;
  List<QuizQuestion> _allLocalQuestions = [];
  List<QuizQuestion> _activeQuestions = [];
  List<CourseItem> _localCourses = [];
  Map<String, int> _bestQuizScores = {};
  bool _isLoading = true;
  
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  List<String?> _userAnswers = [];
  Timer? _questionTimer;
  int _remainingSeconds = 120;
  
  int _correctAnswersCount = 0;
  int _pointsAccumulated = 0;
  bool _qcdWarningShown = false;

  String _courseSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    currentSessionUserNotifier.addListener(_loadData);
  }

  @override
  void dispose() {
    currentSessionUserNotifier.removeListener(_loadData);
    _questionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final courses = await DatabaseHelper.instance.getLocalCourses();
    final questions = await DatabaseHelper.instance.getLocalQuizQuestions();
    final userId = currentUser?.id ?? 'guest';
    
    final scoresMap = <String, int>{};
    for (var c in courses) {
      final pct = await DatabaseHelper.instance.getBestScorePercentageForCourse(c.title, userId);
      scoresMap[c.title] = pct;
    }

    if (mounted) {
      setState(() {
        _localCourses = courses;
        _allLocalQuestions = questions;
        _bestQuizScores = scoresMap;
        _isLoading = false;
      });
    }
  }

  List<QuizQuestion> _getQuestionsForCourse(CourseItem course) {
    final List<QuizQuestion> matched = _allLocalQuestions
        .where((q) => q.courseTitle.trim().toLowerCase() == course.title.trim().toLowerCase())
        .toList();

    if (matched.isNotEmpty) {
      return matched;
    }

    return [
      QuizQuestion(
        id: 'mock_${course.title}_1',
        courseTitle: course.title,
        subjectLevel: 'Sujet 1',
        subjectTitle: 'Généralités',
        prompt: 'Dans le cadre du cours "${course.title}", quelle est la règle clinique primordiale à appliquer ?',
        type: 'QCM',
        options: [
          'La double vérification systématique de l’identité du patient',
          'L’administration rapide sans prescription médicale écrite',
          'Le partage des tâches critiques sans supervision directe',
          'La réutilisation du matériel à usage unique stérilisé'
        ],
        correctAnswer: 'La double vérification systématique de l’identité du patient',
        explanation: 'La sécurité clinique du patient repose avant tout sur l’identification correcte du malade à chaque étape de la prise en charge (règle des 5 B).',
      ),
      QuizQuestion(
        id: 'mock_${course.title}_2',
        courseTitle: course.title,
        subjectLevel: 'Sujet 1',
        subjectTitle: 'Généralités',
        prompt: 'Le lavage antiseptique des mains est obligatoire avant tout soin invasif lié au module "${course.title}" ?',
        type: 'QCD',
        options: ['Vrai', 'Faux'],
        correctAnswer: 'Vrai',
        explanation: 'L’hygiène des mains reste le moyen le plus simple et efficace de lutter contre la transmission d’infections nosocomiales.',
      ),
      QuizQuestion(
        id: 'mock_${course.title}_3',
        courseTitle: course.title,
        subjectLevel: 'Sujet 1',
        subjectTitle: 'Généralités',
        prompt: 'Quelle est la complication immédiate majeure à surveiller activement dans la thématique "${course.title}" ?',
        type: 'QCM',
        options: [
          'L’apparition d’un choc infectieux ou hémorragique',
          'Une somnolence passagère bénigne après repos',
          'Un pic d’hypertension mineur de fin d’après-midi',
          'Une amélioration soudaine de la vision'
        ],
        correctAnswer: 'L’apparition d’un choc infectieux ou hémorragique',
        explanation: 'Les complications aiguës requièrent un diagnostic infirmier ou obstétrical précoce et une action clinique immédiate.',
      ),
    ];
  }

  void _startQuiz(CourseItem course) {
    _cancelQuestionTimer();
    setState(() {
      _selectedCourse = course;
      _activeQuestions = _getQuestionsForCourse(course);
      _currentIndex = 0;
      _selectedAnswer = null;
      _showResult = false;
      _correctAnswersCount = 0;
      _pointsAccumulated = 0;
      _qcdWarningShown = false;
      _userAnswers = List<String?>.filled(_activeQuestions.length, null);
      _quizState = QuizState.activeQuiz;
      _remainingSeconds = 120;
    });
    globalIsQuizActive.value = true;
    _startQuestionTimer();
  }

  void _startQuizForSubject(CourseItem course, String subjectLevel, List<QuizQuestion> subjectQuestions) {
    _cancelQuestionTimer();
    setState(() {
      _selectedCourse = course;
      _selectedSubjectLevel = subjectLevel;
      _activeQuestions = subjectQuestions;
      _currentIndex = 0;
      _selectedAnswer = null;
      _showResult = false;
      _correctAnswersCount = 0;
      _pointsAccumulated = 0;
      _qcdWarningShown = false;
      _userAnswers = List<String?>.filled(_activeQuestions.length, null);
      _quizState = QuizState.activeQuiz;
      _remainingSeconds = 120;
    });
    globalIsQuizActive.value = true;
    _startQuestionTimer();
  }

  void _restartActiveQuiz() {
    if (_selectedCourse == null) return;
    if (_selectedSubjectLevel != null) {
      final matchedQuestions = _allLocalQuestions
          .where((q) => q.courseTitle.trim().toLowerCase() == _selectedCourse!.title.trim().toLowerCase())
          .toList();
      final subjectQuestions = matchedQuestions.where((q) => q.subjectLevel == _selectedSubjectLevel).toList();
      if (subjectQuestions.isNotEmpty) {
        _startQuizForSubject(_selectedCourse!, _selectedSubjectLevel!, subjectQuestions);
        return;
      }
    }
    _startQuiz(_selectedCourse!);
  }

  void _handleOptionSelect(String option) {
    if (_showResult) return;
    final question = _activeQuestions[_currentIndex];
    setState(() {
      if (question.type == 'QCD') {
        _selectedAnswer = option;
      } else {
        final currentSelected = _selectedAnswer?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? [];
        if (currentSelected.contains(option)) {
          currentSelected.remove(option);
        } else {
          currentSelected.add(option);
        }
        _selectedAnswer = currentSelected.isEmpty ? null : currentSelected.join(', ');
      }
    });
  }

  void _verifyAnswer(QuizQuestion question) {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une réponse.'), backgroundColor: AppColors.muted),
      );
      return;
    }

    if (question.type == 'QCD' && !_qcdWarningShown) {
      _showQcdWarningDialog(() {
        setState(() {
          _qcdWarningShown = true;
          _processVerification(question);
        });
      });
    } else {
      _processVerification(question);
    }
  }

  void _processVerification(QuizQuestion question) {
    setState(() {
      _showResult = true;
      _userAnswers[_currentIndex] = _selectedAnswer;
      
      final isCorrect = () {
        if (_selectedAnswer == null) return false;
        final sel = _selectedAnswer!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()..sort();
        final corr = question.correctAnswer.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()..sort();
        if (sel.length != corr.length) return false;
        for (int i = 0; i < sel.length; i++) {
          if (sel[i] != corr[i]) return false;
        }
        return true;
      }();
      
      if (isCorrect) {
        _correctAnswersCount++;
        _pointsAccumulated += 1;
      } else {
        if (question.type == 'QCD') {
          _pointsAccumulated -= 1;
        }
      }
    });
  }

  void _saveQuizResult() async {
    if (_selectedCourse == null) return;
    final title = _selectedCourse!.title;
    final score = _correctAnswersCount;
    final total = _activeQuestions.length;
    final isOffline = !globalIsOnline.value;
    
    await DatabaseHelper.instance.saveQuizResult(title, score, total, isOffline, currentUser?.id ?? 'guest');
    currentSessionUserNotifier.value = currentUser;
  }

  void _handleNext() {
    _cancelQuestionTimer();
    if (_currentIndex + 1 < _activeQuestions.length) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showResult = false;
        _remainingSeconds = 120;
      });
      _startQuestionTimer();
    } else {
      _saveQuizResult();
      setState(() { _quizState = QuizState.rewardScreen; });
      globalIsQuizActive.value = true;
    }
  }

  void _showQcdWarningDialog(VoidCallback onProceed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
            SizedBox(width: 8),
            Text('Pénalité QCD INFAS', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Attention : Les questions de type QCD (Vrai/Faux) obéissent au barème officiel de l’INFAS :\n\n• Réponse correcte = +1 point\n• Réponse fausse = -1 point\n\nÊtes-vous sûr de votre choix ?',
          style: TextStyle(height: 1.4, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.of(ctx).pop(); setState(() => _selectedAnswer = null); },
            child: const Text('Modifier', style: TextStyle(fontSize: 15)),
          ),
          ElevatedButton(
            onPressed: () { Navigator.of(ctx).pop(); onProceed(); },
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            child: const Text('Valider', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  void _cancelQuestionTimer() {
    _questionTimer?.cancel();
    _questionTimer = null;
  }

  void _startQuestionTimer() {
    _cancelQuestionTimer();
    setState(() => _remainingSeconds = 45);
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        if (!mounted) return;
        setState(() => _remainingSeconds = 0);
        _handleNext();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<bool> _showQuitConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28), SizedBox(width: 8), Text('Quitter le Quiz ?')]),
        content: const Text('Voulez-vous vraiment quitter le quiz en cours ? Votre progression actuelle sera perdue.', style: TextStyle(fontSize: 15, height: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Continuer le quiz', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white), child: const Text('Quitter', style: TextStyle(fontSize: 15))),
        ],
      ),
    );
    return result ?? false;
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
            Text('Quiz Premium', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Ce quiz est réservé aux abonnés premium. Activez votre compte premium pour y accéder. Contactez les administrateurs sur WhatsApp pour une activation.',
          style: TextStyle(height: 1.4, fontSize: 15),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Plus tard', style: TextStyle(color: AppColors.muted))),
          ElevatedButton.icon(
            onPressed: () async { Navigator.of(ctx).pop(); await launchWhatsAppPremiumRequest(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('Contacter sur WhatsApp'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    switch (_quizState) {
      case QuizState.selectingCourse:
        return ValueListenableBuilder<AppUser?>(
          valueListenable: currentSessionUserNotifier,
          builder: (context, liveUser, _) {
            final user = liveUser ?? currentUser ?? AppUser(name: "Étudiant", email: "", level: "Licence 1", filiere: "IDE", premium: false, isActive: true);
            return SelectingCourseView(
              user: user,
              localCourses: _localCourses,
              allLocalQuestions: _allLocalQuestions,
              bestQuizScores: _bestQuizScores,
              courseSearchQuery: _courseSearchQuery,
              onSearchQueryChanged: (val) => setState(() => _courseSearchQuery = val),
              onCourseSelected: (course) => setState(() {
                _selectedCourse = course;
                _quizState = QuizState.selectingSubject;
              }),
              onShowPremiumLockDialog: _showPremiumLockDialog,
            );
          },
        );

      case QuizState.selectingSubject:
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            setState(() {
              _quizState = QuizState.selectingCourse;
              _selectedCourse = null;
            });
          },
          child: SelectingSubjectView(
            selectedCourse: _selectedCourse!,
            allLocalQuestions: _allLocalQuestions,
            onSubjectSelected: _startQuizForSubject,
            onBackPressed: () => setState(() {
              _quizState = QuizState.selectingCourse;
              _selectedCourse = null;
            }),
            fallbackQuestions: _getQuestionsForCourse(_selectedCourse!),
          ),
        );

      case QuizState.activeQuiz:
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldQuit = await _showQuitConfirmationDialog();
            if (shouldQuit) { 
              _cancelQuestionTimer(); 
              setState(() { _quizState = QuizState.selectingSubject; }); 
              globalIsQuizActive.value = false; 
            }
          },
          child: ActiveQuizView(
            course: _selectedCourse!,
            activeQuestions: _activeQuestions,
            currentIndex: _currentIndex,
            selectedAnswer: _selectedAnswer,
            showResult: _showResult,
            remainingSeconds: _remainingSeconds,
            pointsAccumulated: _pointsAccumulated,
            formattedTime: _formattedTime,
            onOptionSelected: _handleOptionSelect,
            onVerify: () => _verifyAnswer(_activeQuestions[_currentIndex]),
            onNext: _handleNext,
            onBackPressed: () async {
              final shouldQuit = await _showQuitConfirmationDialog();
              if (shouldQuit) {
                _cancelQuestionTimer();
                setState(() { _quizState = QuizState.selectingSubject; });
                globalIsQuizActive.value = false;
              }
            },
          ),
        );

      case QuizState.rewardScreen:
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            setState(() {
              _quizState = QuizState.selectingSubject;
            });
          },
          child: RewardScreenView(
            course: _selectedCourse!,
            activeQuestions: _activeQuestions,
            correctAnswersCount: _correctAnswersCount,
            pointsAccumulated: _pointsAccumulated,
            userAnswers: _userAnswers,
            onRestart: _restartActiveQuiz,
            onChooseAnotherSubject: () {
              _cancelQuestionTimer();
              setState(() { _quizState = QuizState.selectingSubject; });
              globalIsQuizActive.value = false;
            },
          ),
        );
    }
  }
}