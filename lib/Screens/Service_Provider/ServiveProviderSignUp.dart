import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:s_a/const/Modal/categoryListModal.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/Screens/Service_Provider/bottom_nav.dart';

class RegionState {
  final String name;
  final String isoCode;
  RegionState({required this.name, required this.isoCode});
  factory RegionState.fromCsc(csc.State state) =>
      RegionState(name: state.name, isoCode: state.isoCode);
}

class RegionCity {
  final String name;
  RegionCity({required this.name});
  factory RegionCity.fromCsc(csc.City city) => RegionCity(name: city.name);
}

class IdentityTrustScreen extends StatefulWidget {
  const IdentityTrustScreen({super.key});

  @override
  State<IdentityTrustScreen> createState() => _IdentityTrustScreenState();
}

class _IdentityTrustScreenState extends State<IdentityTrustScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingServices = true;
  bool _isLoadingStates = true;
  bool _isLoadingCities = false;

  File? _profileImage;
  File? _adharImage; // 👈 Added Aadhar Image File

  dynamic _selectedServiceId;
  List<Data> _services = [];

  List<RegionState> _states = [];
  List<RegionCity> _cities = [];
  RegionState? _selectedState;
  RegionCity? _selectedCity;

  // --- CONTROLLERS ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _adharController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _loadIndiaStates();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _adharController.dispose();
    super.dispose();
  }

  Future<void> _loadIndiaStates() async {
    setState(() => _isLoadingStates = true);
    try {
      final rawStates = await csc.getStatesOfCountry('IN');
      if (mounted) {
        setState(() {
          _states = rawStates.map((s) => RegionState.fromCsc(s)).toList();
        });
      }
    } catch (e) {
      debugPrint("❌ State Load Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingStates = false);
    }
  }

  Future<void> _loadCities(String stateCode) async {
    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _selectedCity = null;
      _cityController.clear();
    });
    try {
      final rawCities = await csc.getStateCities('IN', stateCode);
      if (mounted) {
        setState(() {
          _cities = rawCities.map((c) => RegionCity.fromCsc(c)).toList();
        });
      }
    } catch (e) {
      debugPrint("❌ City Load Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingCities = false);
    }
  }

  Future<void> _fetchServices() async {
    setState(() => _isFetchingServices = true);
    try {
      final response = await ApiService.fetchCategoryList();
      if (response != null && response.status == true) {
        setState(() => _services = response.data ?? []);
      }
    } catch (e) {
      debugPrint("❌ Service Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isFetchingServices = false);
    }
  }

  Future<void> _pickImage({required bool isProfile}) async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(pickedFile.path);
        } else {
          _adharImage = File(pickedFile.path);
        }
      });
    }
  }

  // ─── UPDATED REGISTRATION HANDLER ───
  Future<void> _handleRegister() async {
    debugPrint("🔘 [UI LOG]: Register Button Clicked");

    // 1. Form Validation Check
    if (!_formKey.currentState!.validate()) {
      debugPrint("⚠️ [UI LOG]: Form validation failed");
      return;
    }

    // 2. Profile Image Check
    if (_profileImage == null) {
      debugPrint("⚠️ [UI LOG]: Profile Image is missing");
      _showSnack("Profile Photo is required!");
      return;
    }

    // 3. Aadhar Image Check
    if (_adharImage == null) {
      debugPrint("⚠️ [UI LOG]: Aadhar Card Image is missing");
      _showSnack("Aadhar Card Image is required!");
      return;
    }

    // 4. Service ID Check


    debugPrint("🚀 [UI LOG]: All local validations passed. Sending data to API...");

    setState(() => _isLoading = true);
    try {
      final response = await ApiService().registerOwner(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        adharNo: _adharController.text.trim(),
        // serviceId: _selectedServiceId,
        imageFile: _profileImage,
        adharImage: _adharImage,
      );

      debugPrint("📥 [UI LOG]: API execution finished. Status Code: ${response.statusCode}");

      if (mounted && (response.statusCode == 200 || response.statusCode == 201)) {
        debugPrint("✅ [UI LOG]: Registration Successful");
        _showSnack("Registered Successfully!");
        Navigator.pop(context);
      } else {
        debugPrint("❌ [UI LOG]: Registration failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🔥 [UI LOG]: Exception caught in _handleRegister: $e");
      if (mounted) _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Join as Professional", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white, foregroundColor: Colors.black,
        elevation: 0, centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfilePicker(),
              const SizedBox(height: 30),

              _buildField(_nameController, "Full Name", Icons.person),
              _buildField(_adharController, "Aadhar Number (12 Digits)", Icons.badge, keyboard: TextInputType.number),

              // ─── AADHAR IMAGE PICKER ───
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text("Upload Aadhar Card Image", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
              ),
              _buildAdharPicker(),
              const SizedBox(height: 15),

              _buildField(_emailController, "Email Address", Icons.email, keyboard: TextInputType.emailAddress),
              _buildField(_phoneController, "Phone Number", Icons.phone, keyboard: TextInputType.phone),
              _buildField(_addressController, "Full Address", Icons.home),

              const SizedBox(height: 15),
              _buildStateDropdown(),
              const SizedBox(height: 15),
              _buildCityDropdown(),
              const SizedBox(height: 40),

              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─── NEW UI COMPONENTS ───

  Widget _buildAdharPicker() {
    return GestureDetector(
      onTap: () => _pickImage(isProfile: false),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: _adharImage != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_adharImage!, fit: BoxFit.cover),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.blue.shade700),
            const SizedBox(height: 8),
            const Text("Tap to upload Aadhar Photo", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildStateDropdown() {
    return _buildDropdownWrapper(
      child: _isLoadingStates
          ? const _LoadingDropdown(text: "Loading States...", icon: Icons.map)
          : DropdownButtonFormField<RegionState>(
        isExpanded: true,
        value: _selectedState,
        hint: const Text("Select State", style: TextStyle(fontSize: 14)),
        menuMaxHeight: 350,
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.map, color: Colors.blue, size: 20),
        ),
        items: _states.map((st) => DropdownMenuItem(value: st, child: Text(st.name, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: (value) {
          setState(() {
            _selectedState = value;
            _stateController.text = value?.name ?? "";
            _selectedCity = null;
          });
          if (value != null) _loadCities(value.isoCode);
        },
        validator: (v) => v == null ? "State required" : null,
      ),
    );
  }

  Widget _buildCityDropdown() {
    return _buildDropdownWrapper(
      child: _isLoadingCities
          ? const _LoadingDropdown(text: "Loading Cities...", icon: Icons.location_city)
          : DropdownButtonFormField<RegionCity>(
        isExpanded: true,
        value: _selectedCity,
        hint: Text(_selectedState == null ? "Select State First" : "Select City"),
        decoration: const InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.location_city, color: Colors.blue, size: 20)),
        items: _cities.map((ct) => DropdownMenuItem(value: ct, child: Text(ct.name, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: _selectedState == null ? null : (value) {
          setState(() {
            _selectedCity = value;
            _cityController.text = value?.name ?? "";
          });
        },
        validator: (v) => v == null ? "City required" : null,
      ),
    );
  }

  Widget _buildProfilePicker() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 65,
            backgroundColor: Colors.blue.shade50,
            backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
            child: _profileImage == null ? const Icon(Icons.person, size: 50, color: Colors.blue) : null,
          ),
          Positioned(
            bottom: 0, right: 0,
            child: CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              radius: 18,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                onPressed: () => _pickImage(isProfile: true),
              ),
            ),
          )
        ],
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
          prefixIcon: Icon(icon, color: Colors.blue, size: 20),
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Required";
          if (hint.contains("Aadhar") && value.length != 12) return "Aadhar must be 12 digits";
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: child,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: (_isLoading || _isFetchingServices || _isLoadingStates) ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Register as Professional", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _LoadingDropdown extends StatelessWidget {
  final String text;
  final IconData icon;
  const _LoadingDropdown({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}