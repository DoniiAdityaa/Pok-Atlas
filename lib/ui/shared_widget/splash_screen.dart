import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../config/constant.dart';
import '../color.dart';
import '../typography.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _loadingController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentFade;
  late final Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (runs once)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 2. Loading bar continuous sweep
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Entrance curves
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.50, curve: Curves.easeIn),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.80, curve: Curves.easeIn),
      ),
    );

    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
      ),
    );

    _entranceController.forward();

    // Navigate to MainNavigation with smooth fade
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainNavigation(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Seamless full-screen soft vertical gradient (PokéAtlas Slate & Blue)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor50,
              bg,
              bg,
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Hero Pokéball (clean, natural Lottie animation)
              _buildPokeball(),

              const SizedBox(height: 24),

              // Title, Badge & Tagline
              _buildBrandInfo(),

              const Spacer(flex: 3),

              // Minimalist Progress Bar & Version
              _buildFooter(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Bouncing Lottie Pokéball with smooth scale & fade entrance
  Widget _buildPokeball() {
    return ScaleTransition(
      scale: _logoScale,
      child: FadeTransition(
        opacity: _logoFade,
        child: SizedBox(
          width: 170,
          height: 170,
          child: Lottie.asset(
            'assets/animation/bola_pokemon.json',
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),
      ),
    );
  }

  /// Clean, crisp branding typography
  Widget _buildBrandInfo() {
    return SlideTransition(
      position: _contentSlide,
      child: FadeTransition(
        opacity: _contentFade,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtle pill tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.5),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'POKÉDEX COMPANION',
                style: xxsSemiBold.copyWith(
                  letterSpacing: 1.2,
                  color: primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // App Title - crisp and sharp, no blurry drop shadows
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Poké',
                    style: xxlBold.copyWith(
                      fontSize: 34,
                      letterSpacing: -0.5,
                      color: bgDark,
                    ),
                  ),
                  TextSpan(
                    text: 'Atlas',
                    style: xxlBold.copyWith(
                      fontSize: 34,
                      letterSpacing: -0.5,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'Explore. Discover. Know Them All.',
              style: smRegular.copyWith(
                color: textNeutralSecondary,
                letterSpacing: 0.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom progress bar and version info
  Widget _buildFooter() {
    return FadeTransition(
      opacity: _footerFade,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sleek indeterminate progress bar
          Container(
            width: 120,
            height: 4,
            decoration: BoxDecoration(
              color: black200,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: AnimatedBuilder(
              animation: _loadingController,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment(
                    -1.0 + (_loadingController.value * 2.0),
                    0.0,
                  ),
                  widthFactor: 0.40,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.4),
                          primaryColor,
                          primaryColor700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // Version info
          Text(
            'v$appVersion • Powered by PokéAPI',
            style: xxsRegular.copyWith(
              color: black400,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
