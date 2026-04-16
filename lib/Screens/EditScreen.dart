import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/session/session.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _imageFile;
  String? _networkImageUrl; // Server se aane wali image ke liye
  bool _isLoading = true;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _fetchAndFillData();
  }

  // ── 1. FETCH DATA FROM API & FILL CONTROLLERS ──
  Future<void> _fetchAndFillData() async {
    // A. Pehle local session se ID nikaalo
    final localData = await UserPref.getUser();
    _userId = localData['userId'] ?? 0;

    if (_userId != 0) {
      try {
        // B. API se fresh profile fetch karo
        final response = await ApiService.fetchProfile(_userId);

        if (response != null && response.status == true) {
          final serverData = response.data;
          if (serverData != null) {
            setState(() {
              _nameController.text = serverData.name ?? "";
              _emailController.text = serverData.email ?? "";
              _phoneController.text = serverData.phone ?? "";
              _networkImageUrl = serverData.profileImage;
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint("💀 API Fetch Error: $e");
      }
    }

    // Fallback: Agar API fail ho jaye toh local data use karein
    setState(() {
      _nameController.text = localData['name'] ?? "";
      _emailController.text = localData['email'] == "No Email" ? "" : localData['email'];
      _phoneController.text = localData['phone'] == "No Phone" ? "" : localData['phone'];
      _isLoading = false;
    });
  }

  // ── 2. IMAGE PICKER LOGIC ──
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _networkImageUrl = null; // New image select ki toh purani URL hide kar do
      });
    }
  }

  // ── 3. UPDATE LOGIC ──
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.editProfile(
      userId: _userId,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      imageFile: _imageFile,
    );

    if (result != null && result['status'] == true) {
      // ✅ SUCCESS: Update local session so other screens refresh
      await UserPref.saveUser(
        id: _userId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: "customer",

      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Pop with 'true' to trigger refresh in ProfileScreen
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Update Failed! Please try again."), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── PROFILE IMAGE PICKER ──
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_networkImageUrl != null && _networkImageUrl != "")
                          ? NetworkImage(_networkImageUrl!)
                          : const AssetImage('assets/images/user.png') as ImageProvider,
                    ),
                    // Positioned(
                    //   bottom: 0,
                    //   right: 0,
                    //   child: GestureDetector(
                    //     onTap: _pickImage,
                    //     child: Container(
                    //       padding: const EdgeInsets.all(8),
                    //       decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    //       child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _buildEditField("Full Name", _nameController, Icons.person_outline),
              const SizedBox(height: 20),
              _buildEditField("Email Address", _emailController, Icons.email_outlined, isEmail: true),
              const SizedBox(height: 20),
              _buildEditField("Phone Number", _phoneController, Icons.phone_android_outlined, isPhone: true),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon, {bool isEmail = false, bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
          validator: (value) {
            if (value == null || value.isEmpty) return "This field is required";
            if (isEmail && !value.contains("@")) return "Enter a valid email";
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}