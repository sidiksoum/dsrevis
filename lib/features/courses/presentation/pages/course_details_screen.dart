import 'dart:async';
import 'package:dsrevis/core/constants/app_colors.dart';
import 'package:dsrevis/features/shared/data/sample_data.dart';
import 'package:dsrevis/features/shared/presentation/widgets/rich_content_display.dart';
import 'package:dsrevis/core/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailsScreen extends StatefulWidget {
  const CourseDetailsScreen({super.key, required this.course});
  final CourseItem course;

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late final DateTime _startTime;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds = DateTime.now().difference(_startTime).inSeconds;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    final elapsedSeconds = DateTime.now().difference(_startTime).inSeconds;
    if (elapsedSeconds > 0) {
      DatabaseHelper.instance.addReadingTime(widget.course.title, elapsedSeconds, currentUser?.id ?? 'guest').then((_) {
        // Notifie l'UI d'actualiser la barre de progression locale
        currentSessionUserNotifier.value = currentUser;
      });
    }
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final String hoursStr = hours.toString().padLeft(2, '0');
      return '$hoursStr:$minutesStr:$secondsStr';
    }
    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top + 12, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
                  Expanded(child: Text(widget.course.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.025, vertical: 20),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notes_rounded, color: AppColors.primary),
                              const SizedBox(width: 10),
                              const Text('Résumé de Révision', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                              const Spacer(),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatDuration(_elapsedSeconds),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          RichContentDisplay(
                            content: widget.course.summary,
                            baseTextStyle: const TextStyle(fontSize: 16, height: 1.6, color: AppColors.text),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: globalIsOnline,
                    builder: (context, isOnline, _) {
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: ListTile(
                          leading: Icon(Icons.picture_as_pdf_rounded, color: isOnline ? AppColors.success : Colors.grey),
                          title: const Text('Support Complet PDF'),
                          subtitle: Text(isOnline ? 'Ouvrir sur Google Drive' : 'Connexion internet obligatoire.'),
                          trailing: const Icon(Icons.open_in_new_rounded),
                          onTap: isOnline ? () async {
                            final Uri url = Uri.parse(widget.course.driveLink);
                            try {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Impossible d’ouvrir le lien Drive.'), backgroundColor: AppColors.error),
                                );
                              }
                            }
                          } : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}