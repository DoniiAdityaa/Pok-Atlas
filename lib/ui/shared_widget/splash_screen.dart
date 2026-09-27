import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pokeatlas/ui/color.dart';
import 'package:pokeatlas/ui/shared_widget/main_navigation.dart';
import 'package:pokeatlas/ui/typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Start fade animation after short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fadeController.forward();
      }
    });

    // Navigate to main navigation after splash
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _backgroundGradient(),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _pokemonBallAnimation(),
                const SizedBox(height: 48),
                _appTitle(),
                const SizedBox(height: 12),
                _tagline(),
                const Spacer(flex: 2),
                _loadingIndicator(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Background gradient decoration
  BoxDecoration _backgroundGradient() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.1),
          bg,
        ],
      ),
    );
  }

  /// Pokemon ball bouncing animation (Lottie)
  Widget _pokemonBallAnimation() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Lottie.asset(
        'assets/animation/bola_pokemon.json',
        fit: BoxFit.contain,
        repeat: true,
      ),
    );
  }

  /// App title with fade animation
  Widget _appTitle() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        'PokéAtlas',
      ),
    );
  }

  /// Tagline with fade animation
  Widget _tagline() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        'Explore. Discover. Know Them All.',
        style: mRegular.copyWith(
          color: textNeutralSecondary,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Loading indicator with animated dots
  Widget _loadingIndicator() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _animatedDot(delay: 0),
          const SizedBox(width: 8),
          _animatedDot(delay: 200),
          const SizedBox(width: 8),
          _animatedDot(delay: 400),
        ],
      ),
    );
  }

  /// Single animated dot
  Widget _animatedDot({required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        // Loop animation
        Future.delayed(Duration(milliseconds: delay), () {
          if (mounted) {
            setState(() {});
          }
        });
      },
    );
  }
}
