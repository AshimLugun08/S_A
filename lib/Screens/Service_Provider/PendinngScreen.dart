import 'dart:async';
import 'package:flutter/material.dart';// Apna path check karein
import 'package:s_a/Screens/Service_Provider/bottom_nav.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/session/session.dart';
import 'package:s_a/Screens/LoginScreen.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  Timer? _timer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // ─── TIMER STARTS HERE (3 SECONDS) ───
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Memory leak se bachne ke liye timer stop karein
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final userData = await UserPref.getUser();
      final int ownerId = userData['userId'] ?? 0;
      print("uer id  ${ownerId}");

      if (ownerId != 0) {
        final response = await ApiService.checkOwnerStatus(ownerId);

        if (response != null && response['is_active'] == true) {
          _timer?.cancel(); // Stop polling
          if (mounted) {
            // ─── NAVIGATE TO MAIN CONTAINER ───
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainContainer()),
                  (route) => false,
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Polling Error: $e");
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── CREATIVE ILLUSTRATION ──
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.verified_user_outlined, size: 100, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 40),

            // ── TEXT CONTENT ──
            const Text(
              "Verification Pending",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 15),
            Text(
              "Bhai, Admin aapke documents review kar raha hai. Jaise hi approval milega, aapka dashboard activate ho jayega.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 50),

            // ── LOADING INDICATOR ──
            const SizedBox(
              width: 40,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.background,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            const Text("Checking status...", style: TextStyle(fontSize: 12, color: Colors.grey)),

            const SizedBox(height: 80),

            // ── LOGOUT OPTION ──
            TextButton.icon(
              onPressed: () async {
                await UserPref.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
              label: const Text("Cancel & Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}