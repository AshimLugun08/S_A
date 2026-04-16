import 'package:flutter/material.dart';
import 'package:s_a/Screens/CheckOutSummary.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
// Aliasing the modal to avoid 'Data' naming conflicts
import 'package:s_a/const/Modal/profectionalListModal.dart' as cat_pro;
import 'package:s_a/const/endpoint/endpoint.dart';
import 'package:s_a/const/session/session.dart';

class ChooseProfessionalScreen extends StatefulWidget {
  final int servidId;
  final int ownerId;
  const ChooseProfessionalScreen({super.key, required this.ownerId , required this.servidId}  );

  @override
  State<ChooseProfessionalScreen> createState() => _ChooseProfessionalScreenState();
}

class _ChooseProfessionalScreenState extends State<ChooseProfessionalScreen> {
  // ── DATA & LOADING STATE ──
  int _selectedIdx = 0;
  List<cat_pro.Data> _professionals = [];
  bool _isLoading = true;

  // ── ADDRESS DATA (Session Integrated) ──
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  String _addressType = "Home";
  String _sessionCityState = "";

  // ── SLOT DATA ──
  String _selectedDate = "Sat 10";
  String _selectedTime = "06:30 PM";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _houseController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  // ── LOAD PROFESSIONALS & SESSION DATA ──
  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Parallel execution for speed
      final results = await Future.wait([
        ApiService.fetchProfessionals(widget.ownerId),
        UserPref.getUser(),
      ]);

      final cat_pro.ProffectionalModal? proResult = results[0] as cat_pro.ProffectionalModal?;
      final Map<String, dynamic> userData = results[1] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _professionals = proResult?.data ?? [];

          // PRE-FILL ADDRESS FROM SESSION
          if (userData['address'] != null && userData['address'].toString().isNotEmpty) {
            _houseController.text = userData['address'];
          }

          _sessionCityState = "${userData['city'] ?? ''}, ${userData['state'] ?? ''}";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("🚨 Initialization Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Choose Professional",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
        children: [
          Expanded(
            child: _professionals.isEmpty
                ? const Center(child: Text("No professionals found."))
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _professionals.length,
              itemBuilder: (context, index) => _buildProfessionalCard(index),
            ),
          ),
          if (_professionals.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: _fullWidthButton("Proceed", () => _showAddressBottomSheet(context)),
            ),
        ],
      ),
    );
  }

  // ── 1. ADDRESS BOTTOM SHEET (Stateful) ──
  void _showAddressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    child: Container(
                      height: 150, width: double.infinity, color: Colors.grey[200],
                      child: const Icon(Icons.map, size: 50, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Service Location", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(_sessionCityState.isNotEmpty ? _sessionCityState : "Current Address",
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 20),
                        _customTextField("House / Flat Number", _houseController),
                        const SizedBox(height: 12),
                        _customTextField("Landmark (Optional)", _landmarkController),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () => setModalState(() => _addressType = "Home"),
                                child: _selectionChip("Home", isSelected: _addressType == "Home")
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                                onTap: () => setModalState(() => _addressType = "Other"),
                                child: _selectionChip("Other", isSelected: _addressType == "Other")
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        _fullWidthButton("Save and Proceed to slots", () {
                          if (_houseController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter house number")));
                            return;
                          }
                          Navigator.pop(context);
                          _showSlotsBottomSheet(context);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  // ── 2. SLOTS BOTTOM SHEET (Stateful) ──
  void _showSlotsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select date & Time", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Divider(height: 40),
                  SizedBox(
                    height: 75,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildSlotDate(setModalState, "Sat", "10", "2026-04-10"),
                        _buildSlotDate(setModalState, "Sun", "11", "2026-04-11"),
                        _buildSlotDate(setModalState, "Mon", "12", "2026-04-12"),
                        _buildSlotDate(setModalState, "Tue", "13", "2026-04-13"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSlotTime(setModalState, "06:30 PM", "18:30"),
                        const SizedBox(width: 10),
                        _buildSlotTime(setModalState, "07:30 PM", "19:30"),
                        const SizedBox(width: 10),
                        _buildSlotTime(setModalState, "08:30 PM", "20:30"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _fullWidthButton("Proceed to checkout", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryScreen(
                      professional: _professionals[_selectedIdx],
                      houseNumber: _houseController.text,
                      landmark: _landmarkController.text,
                      addressType: _addressType,
                      date: _selectedDate,
                      time: _selectedTime,
                        serviceId :widget.servidId
                    )));
                  }),
                ],
              ),
            );
          }
      ),
    );
  }

  // ── SLOT BUILDERS ──
  Widget _buildSlotDate(Function setModalState, String day, String date, String fullValue) {
    return GestureDetector(
      onTap: () => setModalState(() => _selectedDate = fullValue), // Stores "2026-04-13"
      child: _dateCard(day, date, isSelected: _selectedDate == fullValue),
    );
  }

  Widget _buildSlotTime(Function setModalState, String displayLabel, String militaryValue) {
    return GestureDetector(
      onTap: () => setModalState(() => _selectedTime = militaryValue), // Stores "19:30"
      child: _timeChip(displayLabel, isSelected: _selectedTime == militaryValue),
    );
  }

  // ── PROFESSIONAL CARD ──
  Widget _buildProfessionalCard(int index) {
    final pro = _professionals[index];
    bool isSelected = _selectedIdx == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIdx = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(50),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30, backgroundColor: AppColors.background,
              backgroundImage: pro.image != null ? NetworkImage("${ApiEndoint.baseUrl}${pro.image}") : null,
              child: pro.image == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("${pro.name ?? 'Expert'} (${pro.ownerName ?? 'Salon'})",
                    style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                Text("${pro.experience ?? 0} yrs Exp | ${pro.profession ?? 'Specialist'}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
            Icon(Icons.check_circle, color: isSelected ? AppColors.primary : Colors.grey.shade200, size: 30),
          ],
        ),
      ),
    );
  }

  // ── UI REUSABLE HELPERS ──
  Widget _customTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint, filled: true, fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }

  Widget _selectionChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? AppColors.primary : Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  Widget _dateCard(String day, String date, {required bool isSelected}) {
    return Container(
      width: 65, margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(day, style: TextStyle(color: isSelected ? AppColors.primary : Colors.grey, fontSize: 12)),
        Text(date, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : Colors.black)),
      ]),
    );
  }

  Widget _timeChip(String time, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
      ),
      child: Text(time, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : Colors.black54)),
    );
  }

  Widget _fullWidthButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}