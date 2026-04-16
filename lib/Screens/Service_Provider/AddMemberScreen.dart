import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/session/session.dart';

class AddProfessionalPage extends StatefulWidget {
  const AddProfessionalPage({super.key});

  @override
  State<AddProfessionalPage> createState() => _AddProfessionalPageState();
}

class _AddProfessionalPageState extends State<AddProfessionalPage> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Image & Selection
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  String _selectedProfession = "Cleaning"; // Default based on your API example
  bool _isLoading = false;

  // ── IMAGE PICKER LOGIC ──
  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.gallery);
    if (selected != null) {
      setState(() => _image = selected);
    }
  }

  // ── API SUBMISSION LOGIC ──
  Future<void> _submitData() async {
    // Basic Validation
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill required fields")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userData = await UserPref.getUser();
      final int userId = userData['userId'] ?? 0;

      final result = await ApiService.createProfessional(
        name: _nameController.text,
        phone: _phoneController.text,
        profession: _selectedProfession,
        experienceYears: int.tryParse(_expController.text) ?? 0,
        address: _addressController.text,
        description: _descController.text,
        userId: userId,
        imageFile: _image, // Passing the XFile here
      );
      // print("result: ${result.message}");

      if (result != null && result['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Professional Added Successfully!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to add professional"), backgroundColor: Colors.red));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Add Professional", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── PROFILE PHOTO UPLOADER ──
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.5),
                            shape: BoxShape.circle,
                            image: _image != null ? DecorationImage(image: FileImage(File(_image!.path)), fit: BoxFit.cover) : null,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: _image == null ? const Icon(Icons.person_outline, size: 60, color: AppColors.textSecondary) : null,
                        ),
                        Positioned(
                          bottom: 5, right: 5,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Upload Professional Photo", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            _buildLabel("Full Name *"),
            _buildTextField("e.g. Akansha Kumari", _nameController),

            const SizedBox(height: 20),

            _buildLabel("Phone Number *"),
            _buildTextField("9876543339", _phoneController, keyboard: TextInputType.phone),

            const SizedBox(height: 20),

            _buildLabel("Experience (Years)"),
            _buildTextField("e.g. 9", _expController, keyboard: TextInputType.number),

            const SizedBox(height: 20),

            _buildLabel("Address"),
            _buildTextField("e.g. Ranchi", _addressController),

            const SizedBox(height: 20),

            _buildLabel("Description"),
            _buildTextField("Tell us about your expertise", _descController, maxLines: 3),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _isLoading ? null : _buildBottomButtons(),
    );
  }

  // ── REUSABLE HELPERS ──
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.searchBar,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.searchBar, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Add Professional", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}