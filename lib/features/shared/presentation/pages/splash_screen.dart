import 'package:dsrevis/core/constants/app_colors.dart';
import 'package:dsrevis/features/shared/presentation/widgets/animated_logo.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 8500), widget.onFinished);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Title & App Identity
              const Text(
                'D.S REVIS',
                style: TextStyle(
                  fontSize: 38, // Scaled up from 34
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Institut National de Formation des Agents de Santé',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15, // Scaled up from 13
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 38),

              // Prominent Medical/Science Lottie animation (proper to Flutter)
              Lottie.network(
                'https://assets5.lottiefiles.com/packages/lf20_5n8ybbpa.json', // High quality medical animation
                width: 280,
                height: 280,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Elegant offline fallback: glowing medical icon container
                  return Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      size: 110,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Animated Logo overlay
              const AnimatedLogo(size: 80), // Scaled up from 72
              const Spacer(),

              // Horizontal scrolling text ticker just below the image section
              Container(
                color: Colors.white10,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ), // Scaled up vertical padding
                child: const HorizontalTicker(
                  text:
                      '★ RÉVISEZ PARTOUT ★ 100% HORS-LIGNE ★ PRENEZ L\'AVANTAGE AUX CONCOURS ★ SUIVEZ VOTRE PROGRESSION ★',
                ),
              ),
              const SizedBox(height: 18),
              const SizedBox(
                width: 150, // Scaled up from 140
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  minHeight: 5, // Scaled up height
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom horizontal scrolling text ticker widget
class HorizontalTicker extends StatefulWidget {
  const HorizontalTicker({super.key, required this.text});
  final String text;

  @override
  State<HorizontalTicker> createState() => _HorizontalTickerState();
}

class _HorizontalTickerState extends State<HorizontalTicker> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    if (!mounted || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) {
      Future.delayed(const Duration(milliseconds: 100), _startScrolling);
      return;
    }

    // Slow scroll to the end
    await _scrollController.animateTo(
      maxScroll,
      duration: const Duration(seconds: 22),
      curve: Curves.linear,
    );

    // Jump back to the start and loop
    if (mounted) {
      _scrollController.jumpTo(0.0);
      _startScrolling();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 16, // Scaled up from 14
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
