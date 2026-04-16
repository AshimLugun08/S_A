import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

// Local Project Imports
import 'package:s_a/Screens/BottomNavComp.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/endpoint/endpoint.dart';

// ── CUSTOM MODELS ──
// Renamed from "State" to "RegionState" to avoid Flutter conflict
class RegionState {
  final String name;
  final String countryCode;
  final String isoCode;

  RegionState({required this.name, required this.countryCode, required this.isoCode});

  factory RegionState.fromCsc(csc.State state) => RegionState(
    name: state.name,
    countryCode: state.countryCode,
    isoCode: state.isoCode,
  );
}

class RegionCity {
  final String name;
  RegionCity({required this.name});
  factory RegionCity.fromCsc(csc.City city) => RegionCity(name: city.name);
}

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
  bool _isLoading = false;

  // Location State
  List<RegionState> _states = [];
  List<RegionCity> _cities = [];
  RegionState? _selectedState;
  RegionCity? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadIndiaStates();
  }

  // ── LOAD INITIAL DATA ──
  Future<void> _loadIndiaStates() async {
    // Fetching states for India (ISO Code: IN)
    final rawStates = await csc.getStatesOfCountry('IN');
    setState(() {
      _states = rawStates.map((s) => RegionState.fromCsc(s)).toList();
    });
  }

  Future<void> _loadCities(String stateCode) async {
    // Fetching all cities for India and filtering by state
    final allCities = await csc.getCountryCities('IN');
    final filteredCities = allCities.where((city) => city.stateCode == stateCode).toList();

    setState(() {
      _cities = filteredCities.map((c) => RegionCity.fromCsc(c)).toList();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _handleSignup() async {
    if (_nameController.text.isEmpty || _stateController.text.isEmpty || _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields, including State and City")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passController.text,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        role: "customer",
        imageFile: _imageFile,
      );

      if (mounted && (response.statusCode == 200 || response.statusCode == 201)) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Signup Error: $e");
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
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildProfileImage(),
              const SizedBox(height: 20),
              const Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

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

              // ── STATE DROPDOWN ──
              _buildDropdownWrapper(
                child: DropdownButtonFormField<RegionState>(
                  isExpanded: true, // 1. CRITICAL: This forces the dropdown to stay within parent bounds
                  value: _selectedState,
                  hint: const Text("Select State"),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.map_outlined, color: AppColors.primary, size: 20),
                    // 2. Reduce internal density to save horizontal space
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  items: _states.map((st) => DropdownMenuItem(
                    value: st,
                    child: Text(
                      st.name,
                      overflow: TextOverflow.ellipsis, // 3. Prevents long names from pushing width
                    ),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                      _stateController.text = value?.name ?? "";
                      _selectedCity = null;
                      _cities = [];
                    });
                    if (value != null) _loadCities(value.isoCode);
                  },
                ),
              ),
              const SizedBox(height: 15),

              // ── CITY DROPDOWN ──
              _buildDropdownWrapper(
                child: DropdownButtonFormField<RegionCity>(
                  value: _selectedCity,
                  hint: Text(_states.isEmpty ? "Loading States..." : "Select City"),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.location_city, color: AppColors.primary, size: 20),
                  ),
                  items: _cities.map((ct) => DropdownMenuItem(value: ct, child: Text(ct.name))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                      _cityController.text = value?.name ?? "";
                    });
                  },
                ),
              ),

              const SizedBox(height: 40),
              _buildSignupButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── UI HELPERS ──

  Widget _buildDropdownWrapper({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
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

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
            child: _imageFile == null ? const Icon(Icons.camera_alt, size: 40, color: AppColors.primary) : null,
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
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
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
    );
  }
}