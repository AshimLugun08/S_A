import 'package:flutter/material.dart';
// Note: Ensure these imports match your project structure exactly
import 'package:s_a/Screens/CheckOutSummary.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/Modal/profectionalListModal.dart' as cat_pro;
import 'package:s_a/const/endpoint/endpoint.dart';
import 'package:s_a/const/session/session.dart';

class ChooseProfessionalScreen extends StatefulWidget {
  final int servidId;
  final int ownerId;
  const ChooseProfessionalScreen({super.key, required this.ownerId, required this.servidId});

  @override
  State<ChooseProfessionalScreen> createState() => _ChooseProfessionalScreenState();
}

class _ChooseProfessionalScreenState extends State<ChooseProfessionalScreen> {
  // ── DATA & LOADING STATE ──
  int _selectedIdx = 0;
  List<cat_pro.Data> _professionals = [];
  bool _isLoading = true;

  // ── ADDRESS DATA ──
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  String _addressType = "Home";
  String _sessionCityState = "";

  // ── SLOT DATA (Dynamic) ──
  late List<DateTime> _availableDates;
  String _selectedDate = ""; // Will store YYYY-MM-DD
  String _selectedTime = "18:30";

  @override
  void initState() {
    super.initState();
    _generateDates();
    _loadInitialData();
  }

  // Generates 7 days starting from today
  void _generateDates() {
    _availableDates = List.generate(7, (index) => DateTime.now().add(Duration(days: index)));
    // Initialize selected date to today's date string
    _selectedDate = _formatDateValue(_availableDates[0]);
  }

  @override
  void dispose() {
    _houseController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  // ── HELPER FORMATTERS ──
  String _getDayName(DateTime date) {
    List<String> weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return weekdays[date.weekday % 7];
  }

  String _formatDateValue(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // ── DATA LOADING ──
  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        ApiService.fetchProfessionals(widget.ownerId),
        UserPref.getUser(),
      ]);

      final cat_pro.ProffectionalModal? proResult = results[0] as cat_pro.ProffectionalModal?;
      final Map<String, dynamic> userData = results[1] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _professionals = proResult?.data ?? [];
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
        centerTitle: true,
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

  // ── 1. ADDRESS BOTTOM SHEET ──
  void _showAddressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.map_outlined, size: 40, color: Colors.grey),
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
                            child: _selectionChip("Home", isSelected: _addressType == "Home")),
                        const SizedBox(width: 10),
                        GestureDetector(
                            onTap: () => setModalState(() => _addressType = "Other"),
                            child: _selectionChip("Other", isSelected: _addressType == "Other")),
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
      }),
    );
  }

  // ── 2. SLOTS BOTTOM SHEET ──
  void _showSlotsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select date & Time", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Divider(height: 40),
              // Dynamic Calendar Row
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableDates.length,
                  itemBuilder: (context, index) {
                    DateTime date = _availableDates[index];
                    String dayName = _getDayName(date);
                    String dayNum = date.day.toString();
                    String fullVal = _formatDateValue(date);

                    return GestureDetector(
                      onTap: () => setModalState(() => _selectedDate = fullVal),
                      child: _dateCard(dayName, dayNum, isSelected: _selectedDate == fullVal),
                    );
                  },
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SummaryScreen(
                            professional: _professionals[_selectedIdx],
                            houseNumber: _houseController.text,
                            landmark: _landmarkController.text,
                            addressType: _addressType,
                            date: _selectedDate,
                            time: _selectedTime,
                            ownerId: widget.ownerId,
                            serviceId: widget.servidId)));
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSlotTime(Function setModalState, String displayLabel, String militaryValue) {
    return GestureDetector(
      onTap: () => setModalState(() => _selectedTime = militaryValue),
      child: _timeChip(displayLabel, isSelected: _selectedTime == militaryValue),
    );
  }

  // ── UI COMPONENTS ──

  Widget _buildProfessionalCard(int index) {
    final pro = _professionals[index];
    bool isSelected = _selectedIdx == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIdx = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // Adjusted for better look
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.background,
              backgroundImage: pro.image != null ? NetworkImage("${ApiEndoint.baseUrl}${pro.image}") : null,
              child: pro.image == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("${pro.name ?? 'Expert'} (${pro.ownerName ?? 'Salon'})",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                Text("${pro.experience ?? 0} yrs Exp | ${pro.profession ?? 'Specialist'}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
            Icon(Icons.check_circle, color: isSelected ? AppColors.primary : Colors.grey.shade200, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _customTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _selectionChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? AppColors.primary : Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  Widget _dateCard(String day, String date, {required bool isSelected}) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(day, style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(date, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
      ]),
    );
  }

  Widget _timeChip(String time, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
      width: double.infinity,
      height: 55,
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