import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s_a/Screens/BottomNavComp.dart';
import 'package:s_a/const/color/colors.dart'; // Ensure path is correct

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  // Controllers for the 4 OTP boxes
  final TextEditingController _otp1 = TextEditingController();
  final TextEditingController _otp2 = TextEditingController();
  final TextEditingController _otp3 = TextEditingController();
  final TextEditingController _otp4 = TextEditingController();

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
                const SizedBox(height: 50),

                // ── TOP ILLUSTRATION ──
                // ── TOP ILLUSTRATION ──
                Image.asset(
                  'assets/images/otp_img.png',
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint("❌ Could not find image at assets/images/otp_img.png: $error");
                    // You need the 'return' keyword here!
                    return const Icon(
                      Icons.security,
                      size: 100,
                      color: AppColors.primary,
                    );
                  },
                ),

                const SizedBox(height: 30),

                // ── TITLE ──
                const Text(
                  "Verify OTP",
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

                const SizedBox(height: 10),

                // ── SUBTITLE ──
                const Text(
                  "We have sent an OTP to you mobile\nnumber please enter below",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // ── OTP INPUT FIELDS ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _otpBox(_otp1, first: true, last: false),
                    _otpBox(_otp2, first: false, last: false),
                    _otpBox(_otp3, first: false, last: false),
                    _otpBox(_otp4, first: false, last: true),
                  ],
                ),

                const SizedBox(height: 20),

                // ── RESEND OTP TEXT ──
                Align(
                  alignment: Alignment.centerRight,
                  child: RichText(
                    text: const TextSpan(
                      text: "Didn't received OTP? ",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      children: [
                        TextSpan(
                          text: "resend OTP",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 120),

                // ── LOGIN BUTTON ──
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      String fullOtp = _otp1.text + _otp2.text + _otp3.text + _otp4.text;
                      debugPrint("Verifying OTP: $fullOtp");
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>MainNavigation()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Login Now",
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
      ),
    );
  }

  // ── HELPER WIDGET FOR OTP BOXES ──
  Widget _otpBox(TextEditingController controller, {required bool first, required bool last}) {
    return Container(
      height: 70,
      width: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        autofocus: first,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.length == 1 && last == false) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && first == false) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }
}