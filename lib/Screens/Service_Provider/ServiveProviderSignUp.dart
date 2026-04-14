import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:s_a/const/Modal/serviceListModal.dart';
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

  dynamic _selectedServiceId;
  List<Services> _services = [];

  List<RegionState> _states = [];
  List<RegionCity> _cities = [];
  RegionState? _selectedState;
  RegionCity? _selectedCity;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

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
    super.dispose();
  }

  // ✅ CORRECT: async with await — as per 0.1.6 docs
  Future<void> _loadIndiaStates() async {
    setState(() => _isLoadingStates = true);
    try {
      final rawStates = await csc.getStatesOfCountry('IN');
      debugPrint("✅ States loaded: ${rawStates.length}");
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

  // ✅ CORRECT: getStateCities(countryCode, stateCode) — as per 0.1.6 docs
  Future<void> _loadCities(String stateCode) async {
    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _selectedCity = null;
      _cityController.clear();
    });
    try {
      final rawCities = await csc.getStateCities('IN', stateCode);
      debugPrint("✅ Cities loaded: ${rawCities.length}");
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
      final response = await ApiService.fetchServiceList();
      if (response != null && response.status == true) {
        setState(() => _services = response.services ?? []);
      }
    } catch (e) {
      debugPrint("❌ Service Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isFetchingServices = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profileImage == null) {
      _showSnack("Photo is required!");
      return;
    }
    if (_selectedServiceId == null ||
        _stateController.text.isEmpty ||
        _cityController.text.isEmpty) {
      _showSnack("Please fill all location and service details");
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

      if (mounted &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainContainer()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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
              _buildProfilePicker(),
              const SizedBox(height: 25),
              _buildField(_nameController, "Full Name", Icons.person),
              _buildServiceDropdown(),
              _buildField(_emailController, "Email Address", Icons.email,
                  keyboard: TextInputType.emailAddress),
              _buildField(_phoneController, "Phone Number", Icons.phone,
                  keyboard: TextInputType.phone),
              _buildField(_addressController, "Residential Address", Icons.home),
              const SizedBox(height: 15),

              // ── STATE DROPDOWN ──
              _buildStateDropdown(),
              const SizedBox(height: 15),

              // ── CITY DROPDOWN ──
              _buildCityDropdown(),
              const SizedBox(height: 40),

              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildStateDropdown() {
    return _buildDropdownWrapper(
      child: _isLoadingStates
          ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map, color: Colors.blue, size: 20),
            const SizedBox(width: 10),
            const SizedBox(
              height: 14, width: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            // Expanded here prevents the "Loading..." text from pushing right
            const Expanded(
              child: Text(
                "Loading States...",
                style: TextStyle(color: Colors.grey, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      )
          : DropdownButtonFormField<RegionState>(
        isExpanded: true, // Takes all available space within the parent
        value: _selectedState,
        hint: const Text("Select State", style: TextStyle(fontSize: 14)),
        // Use a specific menuMaxHeight to prevent menu overflow
        menuMaxHeight: 300,
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.map, color: Colors.blue, size: 20),
          contentPadding: EdgeInsets.zero,
          isDense: true, // Reduces internal padding
        ),
        // Ensure the internal DropdownButton icon doesn't push width
        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        items: _states.map((st) {
          return DropdownMenuItem(
            value: st,
            child: Text(
              st.name,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis, // Critical for long names
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedState = value;
            _stateController.text = value?.name ?? "";
            _selectedCity = null;
            _cities = [];
          });
          if (value != null) _loadCities(value.isoCode);
        },
        validator: (v) => v == null ? "Required" : null,
      ),
    );
  }



  Widget _buildCityDropdown() {
    return _buildDropdownWrapper(
      child: _isLoadingCities
          ? const Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Icon(Icons.location_city, color: Colors.blue),
            SizedBox(width: 12),
            SizedBox(
              height: 16, width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text("Loading Cities...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : DropdownButtonFormField<RegionCity>(
        isExpanded: true,
        value: _selectedCity,
        hint: Text(
          _selectedState == null
              ? "Select State First"
              : _cities.isEmpty
              ? "No Cities Found"
              : "Select City",
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.location_city, color: Colors.blue),
        ),
        items: _cities
            .map((ct) => DropdownMenuItem(value: ct, child: Text(ct.name)))
            .toList(),
        onChanged: _selectedState == null
            ? null
            : (value) {
          setState(() {
            _selectedCity = value;
            _cityController.text = value?.name ?? "";
          });
        },
        validator: (v) => v == null ? "Please select a city" : null,
      ),
    );
  }

  Widget _buildDropdownWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: child,
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
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
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) =>
        (value == null || value.isEmpty) ? "Required" : null,
      ),
    );
  }

  Widget _buildProfilePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.blue.shade50,
        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
        child: _profileImage == null
            ? const Icon(Icons.camera_alt, size: 40, color: Colors.blue)
            : null,
      ),
    );
  }

  Widget _buildServiceDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<dynamic>(
        isExpanded: true,
        value: _selectedServiceId,
        hint: Text(_isFetchingServices ? "Loading Services..." : "Select Service Type"),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.build_circle, color: Colors.blue),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        items: _services
            .map((service) => DropdownMenuItem<dynamic>(
            value: service.id, child: Text(service.name ?? "Unknown")))
            .toList(),
        onChanged: (value) => setState(() => _selectedServiceId = value),
        validator: (value) => value == null ? "Field required" : null,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: (_isLoading || _isFetchingServices || _isLoadingStates)
            ? null
            : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Register Now",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}