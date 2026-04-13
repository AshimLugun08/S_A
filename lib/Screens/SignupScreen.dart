import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_a/Screens/BottomNavComp.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'dart:developer' as dev;

import 'package:s_a/const/endpoint/endpoint.dart'; // Advanced logging


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  File? _imageFile;
  final String _selectedRole = "customer";
  bool _isLoading = false;

  // Function to pick image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }


  Future<void> _handleSignup() async {


    final String fullUrl = "${ApiEndoint.baseUrl}${ApiEndoint.register}.";

    debugPrint("🚀 DEBUG: [Signup] Process Started");
    debugPrint("🔗 DEBUG: [API] Full Target URL: $fullUrl");

    // 2. Comprehensive Validation
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passController.text.isEmpty ||
        _phoneController.text.trim().isEmpty) {

      debugPrint("❌ DEBUG: [Validation] Failed - Missing required fields at $fullUrl");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields (Name, Email, Password, Phone)")),
      );
      return;
    }

    // 3. Start Loading State
    setState(() => _isLoading = true);

    try {
      debugPrint("📡 DEBUG: [API] Calling POST to: $fullUrl");
      debugPrint("📦 DEBUG: [API] Payload: { name: ${_nameController.text.trim()}, email: ${_emailController.text.trim()}, role: $_selectedRole }");
      debugPrint("🖼️ DEBUG: [API] Profile Image Attached: ${_imageFile != null}");

      // 4. Execute API Call
      final response = await ApiService().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passController.text,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        role: _selectedRole,
        imageFile: _imageFile,
      );

      // 5. Check for Async Gap
      if (!mounted) {
        debugPrint("⚠️ DEBUG: [Context] Widget unmounted during API call to $fullUrl");
        return;
      }

      debugPrint("✅ DEBUG: [API] Success from $fullUrl. Status Code: ${response.statusCode}");
      debugPrint("📄 DEBUG: [API] Response Data: ${response.data}");

      // 6. Handle Response Status
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("➡️ DEBUG: [Navigation] Redirecting to MainNavigation...");

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
              (route) => false,
        );
      } else {
        debugPrint("⚠️ DEBUG: [API] Server returned non-success status: ${response.statusCode} at $fullUrl");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: ${response.data['message'] ?? 'Unknown Error'}")),
        );
      }

    } catch (e) {
      // 7. Error Logging with Full URL
      debugPrint("💥 DEBUG: [Error] Exception at $fullUrl: $e");

      if (mounted) {
        String errorMsg = "Connection failed. Please check your internet.";

        if (e.toString().contains("409")) {
          errorMsg = "This email is already registered.";
        } else if (e.toString().contains("400")) {
          errorMsg = "Invalid data. Please check your inputs.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } finally {
      // 8. Reset Loading State
      if (mounted) {
        debugPrint("🏁 DEBUG: [Signup] Flow Completed for $fullUrl");
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // ── PROFILE IMAGE PICKER ──
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? const Icon(Icons.camera_alt, size: 40, color: AppColors.primary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Create Account", // Replaced l10n.aboutUs
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // ── INPUT FIELDS ──
              _buildInputField(_nameController, "Full Name", Icons.person_outline),
              const SizedBox(height: 15),
              _buildInputField(_emailController, "Email", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildInputField(_passController, "Password", Icons.lock_outline, isPassword: true),
              const SizedBox(height: 15),
              _buildInputField(_phoneController, "Phone", Icons.phone_android, keyboardType: TextInputType.phone),
              const SizedBox(height: 15),
              _buildInputField(_addressController, "Address", Icons.home_outlined),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: _buildInputField(_cityController, "City", Icons.location_city)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInputField(_stateController, "State", Icons.map_outlined)),
                ],
              ),

              const SizedBox(height: 40),

              // ── SIGNUP BUTTON ──
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Signup Now", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "By signing up, you agree to our Terms & Conditions", // Replaced l10n.termsCond
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── REUSABLE INPUT FIELD ──
  Widget _buildInputField(
      TextEditingController controller,
      String hint,
      IconData icon,
      {bool isPassword = false, TextInputType keyboardType = TextInputType.text}
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}