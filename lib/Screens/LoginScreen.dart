import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s_a/Screens/OtpScreen.dart';
import 'package:s_a/Screens/Service_Provider/ServiveProviderSignUp.dart';
import 'package:s_a/Screens/SignupScreen.dart';
import 'package:s_a/const/color/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  // ── ROLE STATE ──
  // False = Customer, True = Service Provider
  bool _isServiceProvider = false;

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
                Text(
                  _isServiceProvider ? "Provider Login" : "Login Account",
                  style: const TextStyle(
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

                // ── ROLE SELECTOR (Customer vs Provider) ──
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      _buildRoleButton("Customer", !_isServiceProvider),
                      _buildRoleButton("Service Provider", _isServiceProvider),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ── SUBTITLE ──
                Text(
                  _isServiceProvider
                      ? "Enter your provider mobile number\nto manage your services"
                      : "Please enter your mobile\nnumber to get an OTP",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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

                const SizedBox(height: 60),

                // ── NEXT BUTTON ──
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // You can pass the role to the next screen if needed
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VerifyOtpScreen(
                                // Passing the role
                              )
                          )
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have account? ",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_isServiceProvider) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const IdentityTrustScreen()),
                          );
                        }

                        else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        }
                      },
                      child: const Text(
                        "Signup now",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HELPER WIDGET FOR ROLE SELECTION ──
  Widget _buildRoleButton(String title, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isServiceProvider = (title == "Service Provider");
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}