import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s_a/Screens/OtpScreen.dart';
import 'package:s_a/Screens/Service_Provider/ServiveProviderSignUp.dart';
import 'package:s_a/Screens/SignupScreen.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;


  // Inside _LoginScreenState
  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid mobile number")),
      );
      return;
    }

    // Show loading dialog or state
    setState(() => _isLoading = true);

    try {
      // Determine role based on which button or context (Defaulting to customer here)
      final response = await ApiService().sendOtp(
          phone: phone,
          role: "customer" // Or "service_provider" based on your logic
      );

      if (response != null && response.data['status'] == true) {
        // SUCCESS
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'] ?? "OTP Sent")),
        );

        // Navigate to OTP Verification Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpScreen(
              phone: phone,
              // If backend sends OTP in response (for testing), pass it
              serverOtp: response.data['otp'].toString(),
            ),
          ),
        );
      } else {
        // FAIL
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response?.data['message'] ?? "Failed to send OTP")),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // ── TOP ILLUSTRATION ──
                Image.asset(
                  'assets/images/loginimg.png',
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.mobile_friendly, size: 100, color: AppColors.primary),
                ),

                const SizedBox(height: 20),

                // ── TITLE ──
                const Text(
                  "Login Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 20),

                // ── SUBTITLE ──
                const Text(
                  "Please enter your mobile\nnumber to get an OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                // ── PHONE INPUT FIELD ──
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                    decoration: InputDecoration(
                      hintText: "+91 000 0000 000",
                      prefixIcon: const Icon(Icons.phone_android, color: AppColors.primary, size: 20),
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── NEXT BUTTON ──
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSendOtp, // Disable button while loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.6), // Stay blue but faded
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24, width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text(
                      "Next",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "Don't have an account?",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),

                const SizedBox(height: 15),

                // ── SIGNUP BUTTONS ──
                Row(
                  children: [
                    Expanded(
                      child: _buildSignupButton(
                        title: "Customer",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildSignupButton(
                        title: "Provider",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const IdentityTrustScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── REUSABLE SIGNUP BUTTON HELPER ──
  Widget _buildSignupButton({required String title, required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Text(
        "Signup as $title",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}