import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutriscan/config/app_localizations.dart';
import 'package:nutriscan/providers/ads/admob_provider.dart';
import 'package:nutriscan/providers/auth/cloud_backup_provider.dart';
import 'package:nutriscan/providers/theme/language_provider.dart';
import 'package:nutriscan/providers/theme/theme_provider.dart';
import 'package:nutriscan/screens/auth/login_screen.dart';
import 'package:nutriscan/screens/auth/onboarding_screen.dart';
import 'package:nutriscan/screens/main/main_navigation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _loadingController;
  late Animation<double> _logoScale;
  late Animation<double> _fadeAnimation;
  late Animation<double> _loadingRotation;

  @override
  void initState() {
    super.initState();

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Initialize animation controllers with faster durations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Define animations
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _loadingRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.linear),
    );

    // Start animations
    _logoController.forward();
    _fadeController.forward();
    _loadingController.repeat();

    // Navigate to appropriate screen after 3 second delay
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
        final hasLoggedIn = prefs.getBool('has_logged_in') ?? false;

        // Also check Firebase auth state
        if (!mounted) return;
        final cloudBackupProvider = context.read<CloudBackupProvider>();
        final isFirebaseSignedIn = cloudBackupProvider.isSignedIn;

        // Use Firebase auth state as primary source of truth
        final isActuallyLoggedIn = isFirebaseSignedIn && hasLoggedIn;

        if (mounted) {
          // Show open ad before navigating to main app (only if onboarding is completed)
          if (hasSeenOnboarding) {
            if (!mounted) return;
            final admobProvider = context.read<AdMobProvider>();
            if (admobProvider.canShowAppOpenAd()) {
              await admobProvider.showAppOpenAd();
            }
          }

          if (isActuallyLoggedIn) {
            // User is actually logged in - go directly to main screen
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const MainNavigation(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.0, 0.1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          } else if (!hasSeenOnboarding) {
            // User not logged in and hasn't seen onboarding - go to onboarding
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const OnboardingScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.0, 0.1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          } else {
            // User has seen onboarding but not logged in - navigate to login screen
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const LoginScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.0, 0.1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ThemeProvider>(
      builder: (context, languageProvider, themeProvider, child) {
        final currentLanguage = languageProvider.currentLanguage;

return Scaffold(
  body: Container(
    width: double.infinity,
    height: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF22C55E),
          Color(0xFF047857),
          Color(0xFF064E3B),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Stack(
      children: [
        // Background food icons
        const Positioned(
          top: 90,
          left: 28,
          child: Opacity(
            opacity: 0.12,
            child: Icon(Icons.eco, size: 80, color: Colors.white),
          ),
        ),
        const Positioned(
          top: 160,
          right: 35,
          child: Opacity(
            opacity: 0.12,
            child: Icon(Icons.apple, size: 70, color: Colors.white),
          ),
        ),
        const Positioned(
          bottom: 230,
          left: 35,
          child: Opacity(
            opacity: 0.10,
            child: Icon(Icons.local_dining, size: 70, color: Colors.white),
          ),
        ),
        const Positioned(
          bottom: 160,
          right: 28,
          child: Opacity(
            opacity: 0.10,
            child: Icon(Icons.spa, size: 85, color: Colors.white),
          ),
        ),

        SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const Spacer(flex: 2),

                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(34),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 30,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    AppLocalizations.getString(
                      'calorie_tracker',
                      currentLanguage,
                    ),
                    textAlign: TextAlign.center,
                    style: themeProvider.getFontForCurrentLanguage(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    AppLocalizations.getString(
                      'track_nutrition_journey',
                      currentLanguage,
                    ),
                    textAlign: TextAlign.center,
                    style: themeProvider.getFontForCurrentLanguage(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: 72,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA3E635),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const Spacer(flex: 1),

                AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _loadingRotation.value * 2 * 3.14159,
                      child: const SizedBox(
                        width: 46,
                        height: 46,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFA3E635),
                          ),
                          strokeWidth: 4,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    AppLocalizations.getString('loading', currentLanguage),
                    textAlign: TextAlign.center,
                    style: themeProvider.getFontForCurrentLanguage(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    AppLocalizations.getString(
                      'preparing_app',
                      currentLanguage,
                    ),
                    textAlign: TextAlign.center,
                    style: themeProvider.getFontForCurrentLanguage(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.70),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.getString(
                          'powered_by_groq_ai',
                          currentLanguage,
                        ),
                        textAlign: TextAlign.center,
                        style: themeProvider.getFontForCurrentLanguage(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.getString(
                          'splash_version',
                          currentLanguage,
                        ),
                        textAlign: TextAlign.center,
                        style: themeProvider.getFontForCurrentLanguage(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
);
      },
    );
  }
}
