import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_a/const/Modal/serviceListModal.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/Screens/Service_Provider/bottom_nav.dart';
// Ensure you import your Service model here


class IdentityTrustScreen extends StatefulWidget {
  const IdentityTrustScreen({super.key});

  @override
  State<IdentityTrustScreen> createState() => _IdentityTrustScreenState();
}

class _IdentityTrustScreenState extends State<IdentityTrustScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingServices = true;
  File? _profileImage;

  // --- Dynamic Service List ---
  dynamic _selectedServiceId;
  List<Services> _services = [];

  // --- Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchServices(); // Fetch real data on load
  }

  // --- Fetch Real Services from API ---
  Future<void> _fetchServices() async {
    setState(() => _isFetchingServices = true);
    try {
      // Calling the ApiService method we created earlier
      final response = await ApiService.fetchServiceList();
      if (response != null && response.status == true) {
        print("response ${response.services}");
        setState(() {
          _services = response.services ?? [];
        });
      }
    } catch (e) {
      debugPrint("Service Fetch Error: $e");
    } finally {
      setState(() => _isFetchingServices = false);
    }
  }

  // --- Image Picker ---
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70
    );
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  // --- API Submission ---
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo is required! Please upload a profile picture.")),
      );
      return;
    }

    if (_selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a service!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService().registerOwner(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        serviceId: _selectedServiceId,
        imageFile: _profileImage,
      );

      if (mounted && (response.statusCode == 200 || response.statusCode == 201)) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainContainer()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Service Provider Registration"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Profile Image ---
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.blue)
                      : null,
                ),
              ),
              const SizedBox(height: 25),

              _buildField(_nameController, "Full Name", Icons.person),

              // --- Dynamic Dropdown ---
              _buildServiceDropdown(),

              _buildField(_emailController, "Email Address", Icons.email, keyboard: TextInputType.emailAddress),
              _buildField(_phoneController, "Phone Number", Icons.phone, keyboard: TextInputType.phone),
              _buildField(_addressController, "Residential Address", Icons.home),

              Row(
                children: [
                  Expanded(child: _buildField(_cityController, "City", Icons.location_city)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(_stateController, "State", Icons.map)),
                ],
              ),

              const SizedBox(height: 40),

              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isFetchingServices) ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                      "Register Now",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dynamic Service Dropdown ---
  Widget _buildServiceDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<dynamic>(
        value: _selectedServiceId,
        hint: Text(_isFetchingServices ? "Loading Services..." : "Select Service Type"),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.build_circle, color: Colors.blue),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none
          ),
        ),
        // Mapping real IDs and Names from the API list
        items: _services.map((service) {
          return DropdownMenuItem<dynamic>(
            value: service.id,
            child: Text(service.name ?? "Unknown"),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedServiceId = value);
        },
        validator: (value) => value == null ? "Field required" : null,
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none
          ),
        ),
        validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
      ),
    );
  }
}