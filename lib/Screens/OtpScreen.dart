import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s_a/Screens/BottomNavComp.dart';
import 'package:s_a/Screens/Service_Provider/bottom_nav.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/session/session.dart'; // Ensure correct path

class VerifyOtpScreen extends StatefulWidget {
  final String phone;
  final String serverOtp;

  const VerifyOtpScreen({super.key, required this.phone, this.serverOtp = ""});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();

}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {

  final TextEditingController _otp1 = TextEditingController();
  final TextEditingController _otp2 = TextEditingController();
  final TextEditingController _otp3 = TextEditingController();
  final TextEditingController _otp4 = TextEditingController();
  final TextEditingController _otp5 = TextEditingController();
  final TextEditingController _otp6 = TextEditingController();

  bool _isLoading = false;

  // ── VERIFY OTP LOGIC ──
  Future<void> _handleVerify() async {
    // 1. UI Cleanup: Hide keyboard as soon as button is pressed
    FocusScope.of(context).unfocus();

    // 2. Concatenation: Cleaner way to join OTP values
    final String fullOtp = [
      _otp1.text, _otp2.text, _otp3.text,
      _otp4.text, _otp5.text, _otp6.text
    ].join().trim();

    // 3. Validation
    if (fullOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the complete 6-digit OTP")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint("📡 [Auth] Verifying OTP for: ${widget.phone}");

      final response = await ApiService().verifyOtp(
        phone: widget.phone,
        otp: fullOtp,
      );

      // Guard against context usage after async work
      if (!mounted) return;

      if (response != null && response.data['status'] == true) {
        // 4. Data Extraction with strict null-safety fallbacks
        final String role = (response.data['role'] ?? "customer").toString().toLowerCase();
        final int userId = response.data['user_id'] ?? 0;
        final String phone = response.data['phone'] ?? widget.phone;

        debugPrint("✅ [Auth] Success - UserID: $userId | Role: $role");

        // 5. Save Persistent Session
        await UserPref.saveUser(userId, phone, role);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'] ?? "Welcome Back!")),
        );

        // 6. Role-Based Routing
        // Using a local variable for the widget makes the logic cleaner
        final Widget targetScreen = (role == "owner" || role == "service_provider")
            ? const MainContainer()
            : const MainNavigation();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
              (route) => false,
        );
      } else {
        // 7. Backend-driven Error Message
        final String errorMsg = response?.data['message'] ?? "Invalid OTP entered";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      debugPrint("💥 [Auth Error] Exception: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connection failed. Please try again.")),
        );
      }
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 50),

                // ── TOP ILLUSTRATION ──
                Image.asset(
                  'assets/images/otp_img.png',
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.security, size: 100, color: AppColors.primary),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Verify OTP",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 4, width: 40,
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2)),
                ),

                const SizedBox(height: 10),

                Text(
                  "We have sent an OTP to ${widget.phone}\nplease enter it below",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
                ),
                Text(
                  "otp ${widget.serverOtp}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
                ),

                const SizedBox(height: 40),

                // ── OTP INPUT FIELDS (6 BOXES) ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _otpBox(_otp1, first: true, last: false),
                    _otpBox(_otp2, first: false, last: false),
                    _otpBox(_otp3, first: false, last: false),
                    _otpBox(_otp4, first: false, last: false),
                    _otpBox(_otp5, first: false, last: false),
                    _otpBox(_otp6, first: false, last: true),
                  ],
                ),

                const SizedBox(height: 25),

                // ── RESEND OTP TEXT ──
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // Call your sendOtp API here again
                      debugPrint("Resending OTP...");
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Didn't receive OTP? ",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        children: [
                          TextSpan(
                            text: "resend OTP",
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // ── VERIFY BUTTON ──
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Login Now",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
      height: 60,
      width: 50, // Reduced width to fit 6 boxes on one row
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1),
      ),
      child: TextField(
        controller: controller,
        autofocus: first,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(counterText: "", border: InputBorder.none),
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