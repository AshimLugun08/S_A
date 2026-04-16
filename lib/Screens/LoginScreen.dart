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

  // ── ROLE STATE ──
  // false = Customer, true = Owner
  bool _isOwner = false;

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    // Determine role string based on toggle
    final String selectedRole = _isOwner ? "owner" : "customer";

    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 10-digit mobile number")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint("📡 Sending OTP to $phone as $selectedRole");

      final response = await ApiService().sendOtp(
          phone: phone,
          role: selectedRole
      );

      if (mounted) {
        if (response != null && response.data['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? "OTP Sent Successfully")),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(
                phone: phone,
                serverOtp: response.data['otp'].toString(),
             // Pass role to next screen if needed for verification
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response?.data['message'] ?? "Account not found or Error")),
          );
        }
      }
    } catch (e) {
      debugPrint("💀 Login Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              children: [
                const SizedBox(height: 40),
                _buildHeaderIllustration(),
                const SizedBox(height: 20),
                _buildTitleSection(),
                const SizedBox(height: 30),

                // ── ROLE SELECTION TOGGLE ──
                _buildRoleToggle(),

                const SizedBox(height: 25),

                // ── PHONE INPUT ──
                _buildPhoneInput(),

                const SizedBox(height: 40),

                // ── NEXT BUTTON ──
                _buildSubmitButton(),

                const SizedBox(height: 40),
                _buildSignupFooter(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── UI COMPONENTS ──

  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        children: [
          _roleOption("Customer", !_isOwner, () => setState(() => _isOwner = false)),
          _roleOption("Provider/Owner", _isOwner, () => setState(() => _isOwner = true)),
        ],
      ),
    );
  }

  Widget _roleOption(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        decoration: InputDecoration(
          hintText: "Enter Mobile Number",
          prefixIcon: const Icon(Icons.phone_android, color: AppColors.primary, size: 20),

          prefixStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), letterSpacing: 0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSendOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Get OTP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  // ── HELPER WIDGETS ──

  Widget _buildHeaderIllustration() {
    return Image.asset(
      'assets/images/loginimg.png',
      height: 180,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.security, size: 100, color: AppColors.primary),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        const Text("Welcome Back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text("Select your role and enter number to continue", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSignupFooter() {
    return Column(
      children: [
        const Text("Don't have an account?", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _signupBtn("Customer", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())))),
            const SizedBox(width: 15),
            Expanded(child: _signupBtn("Provider", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IdentityTrustScreen())))),
          ],
        ),
      ],
    );
  }

  Widget _signupBtn(String title, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text("Signup $title", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}