import 'package:flutter/material.dart';
import 'package:s_a/Screens/LoginScreen.dart';
import 'package:s_a/const/color/colors.dart';

// --- DATA MODEL ---
class OnboardingData {
  final String title;
  final String image;

  OnboardingData({required this.title, required this.image});
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      title: "Easy Service Booking, Scheduling & Cancellation with Just One Click",
      image: "assets/images/service.jpg",
    ),
    OnboardingData(
      title: "Professional Home Services You Can Trust — Quality Work at Affordable Prices",
      image: "assets/images/service2.jpg",
    ),
    OnboardingData(
      title: "Enjoy Professional Beauty Parlor Services at Home with Complete Grooming Care",
      image: "assets/images/service3.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── SLIDING CONTENT ──
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingPages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return OnboardingContent(
                title: _onboardingPages[index].title,
                image: _onboardingPages[index].image,
              );
            },
          ),

          // ── BOTTOM CONTROLS (Dots and Button) ──
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Progress Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingPages.length,
                        (index) => _buildDot(index),
                  ),
                ),
                const SizedBox(height: 50),

                // Next Button
                GestureDetector(
                  onTap: () {
                    if (_currentPage < _onboardingPages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // TODO: Navigate to Login or Home
                      debugPrint("Finish Onboarding");
                    }
                  },
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── SKIP BUTTON ──
          Positioned(
            bottom: 40,
            left: 30,
            child: TextButton(
              onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              },
              child: const Text(
                "Skip",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build the animated progress dots
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 6,
      width: _currentPage == index ? 35 : 10,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// --- CONTENT WIDGET WITH WHITE FADE ---
class OnboardingContent extends StatelessWidget {
  final String title, image;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── TOP IMAGE SECTION WITH SHADER MASK (FADE) ──
        Expanded(
          flex: 6,
          child: ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,       // Top is visible
                  Colors.transparent, // Bottom fades away
                ],
                stops: [0.65, 1.0],   // Fade starts at 65% of the image height
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              image,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[100],
                child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
            ),
          ),
        ),

        // ── BOTTOM TEXT SECTION ──
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}