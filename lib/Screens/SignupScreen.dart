import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart'; // Ensure path is correct

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers for each field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ── TOP ILLUSTRATION ──
              Image.asset(
                'assets/images/signupimg.png', // Ensure this matches your asset name
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                      Icons.person_add_alt_1,
                      size: 100,
                      color: AppColors.primary
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── TITLE ──
              const Text(
                "Signup Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              // ── YELLOW ACCENT BAR ──
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── SUBTITLE ──
              const Text(
                "Please enter your credential\nto signup account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // ── INPUT FIELDS ──
              _buildInputField(
                controller: _nameController,
                hint: "Enter your name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 15),
              _buildInputField(
                controller: _emailController,
                hint: "Enter your Email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              _buildInputField(
                controller: _phoneController,
                hint: "Enter your mobile number",
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              _buildInputField(
                controller: _locationController,
                hint: "Enter your location",
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 50),

              // ── SIGNUP BUTTON ──
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic for signup
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Signup Now",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── HELPER WIDGET FOR INPUT FIELDS ──
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
          border: InputBorder.none,
          // Optional: Add prefix icons if you want to match common UI patterns
          // prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
      ),
    );
  }
}