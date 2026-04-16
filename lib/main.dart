import 'dart:async';
import 'package:flutter/material.dart';
import 'package:s_a/Screens/BottomNavComp.dart';

// Ensure this path matches your project structure
import 'package:s_a/Screens/LoginScreen.dart';
import 'package:s_a/Screens/OnbordingScreeen.dart';
import 'package:s_a/Screens/Service_Provider/PendinngScreen.dart';
import 'package:s_a/Screens/Service_Provider/bottom_nav.dart';
import 'package:s_a/const/session/session.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salon App',
      theme: ThemeData(
        useMaterial3: true,
        // Using your brand color from the splash icon as the seed
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B5EA6)),
      ),
      home: const SplashScreen(),
    );
  }
}

// ── YOUR SPLASH SCREEN CODE ──

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Setup the Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 2. Setup the Scale Animation (Bounce effect)
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // 3. Start the animation
    _controller.forward();

    // 4. Determine session and navigate
    _startSessionCheck();
  }

// ── NEW SESSION CHECK LOGIC ──
  Future<void> _startSessionCheck() async {
    // Fetch user data from Shared Preferences
    Map<String, dynamic> userData = await UserPref.getUser();
    bool isLoggedIn = userData['isLoggedIn'] ?? false;
    String role = (userData['role'] ?? "customer").toString().toLowerCase();

    // Wait for the splash screen duration (3 seconds total)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // 5. Decide Destination
    Widget destination;

    if (isLoggedIn) {
      if (role == "owner" || role == "service_provider") {
        destination = const PendingApprovalScreen(); // Provider Dashboard
      } else {
        destination = const MainNavigation(); // Customer Dashboard
      }
    } else {
      destination = const OnboardingScreen(); // New User
    }

    // 6. Perform Navigation
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── THE ANIMATED LOGO ──
            // Inside your build method
            ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/images/logo.png', // Added the "s" here
                width: 200,
                errorBuilder: (context, error, stackTrace) {
                  // This will show if the path is still wrong
                  debugPrint(
                    "❌ Could not find image at assets/images/logo.png  ${error}",
                  );
                  return const Icon(
                    Icons.auto_awesome,
                    size: 100,
                    color: Color(0xFF5B5EA6),
                  );
                },
              ),
            ),

            const SizedBox(height: 50),

            // Subtle loading indicator
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF5B5EA6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
