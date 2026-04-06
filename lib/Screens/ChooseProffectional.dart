import 'package:flutter/material.dart';
import 'package:s_a/Screens/CheckOutSummary.dart';
import 'package:s_a/const/color/colors.dart';

// ── CUSTOM COLORS (Replace with your AppColors file if needed) ──


// ── DATA MODELS ──
class Professional {
  final String name;
  final String salon;
  final String experience;
  final String time;
  final String image;

  Professional({
    required this.name,
    required this.salon,
    required this.experience,
    required this.time,
    required this.image,
  });
}

class ChooseProfessionalScreen extends StatefulWidget {
  const ChooseProfessionalScreen({super.key});

  @override
  State<ChooseProfessionalScreen> createState() => _ChooseProfessionalScreenState();
}

class _ChooseProfessionalScreenState extends State<ChooseProfessionalScreen> {
  int _selectedIdx = 0; // Default selected professional

  final List<Professional> professionals = [
    Professional(name: "Pankaj Kumar", salon: "Salon Classic", experience: "5 yrs Exp", time: "30 mins", image: "assets/images/user.png"),
    Professional(name: "Rohan Singh", salon: "Skylark Spa", experience: "4 yrs Exp", time: "50 mins", image: "assets/images/user.png"),
    Professional(name: "Rajan Mehta", salon: "Mehta Spa", experience: "6 yrs Exp", time: "40 mins", image: "assets/images/user.png"),
    Professional(name: "Saurabh Singh", salon: "Paul Spa", experience: "6 yrs Exp", time: "20 mins", image: "assets/images/user.png"),
    Professional(name: "Ragini Kant", salon: "Kant Spa", experience: "6 yrs Exp", time: "20 mins", image: "assets/images/user.png"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Choose Professional",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: professionals.length,
              itemBuilder: (context, index) => _buildProfessionalCard(index),
            ),
          ),

          // ── BOTTOM PROCEED BUTTON ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _showAddressBottomSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text("Proceed",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 1: ADDRESS BOTTOM SHEET ──
  void _showAddressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: Image.asset('assets/images/map_placeholder.png', height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("White Field, Bangalore", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text("Plot No. 209, Kavuri Hills, Bangalore", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  _customTextField("House / Flat Number"),
                  const SizedBox(height: 12),
                  _customTextField("Landmark (Optional)"),
                  const SizedBox(height: 20),
                  const Text("Saves as", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _selectionChip("Home", isSelected: true),
                      const SizedBox(width: 10),
                      _selectionChip("Other", isSelected: false),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _fullWidthButton("Save and Proceed to slots", () {
                    Navigator.pop(context);
                    _showSlotsBottomSheet(context);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 2: SLOTS BOTTOM SHEET ──
  void _showSlotsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select date & Time", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Your service will take approx 45 mins", style: TextStyle(color: Colors.grey)),
            const Divider(height: 40),
            SizedBox(
              height: 75,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _dateCard("Sat", "10", isSelected: true),
                  _dateCard("Sun", "11", isSelected: false),
                  _dateCard("Mon", "12", isSelected: false),
                  _dateCard("Tue", "13", isSelected: false),
                  _dateCard("Wed", "14", isSelected: false),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                _timeChip("06:30 PM", isSelected: true),
                const SizedBox(width: 10),
                _timeChip("07:30 PM", isSelected: false),
                const SizedBox(width: 10),
                _timeChip("08:30 PM", isSelected: false),
              ],
            ),
            const SizedBox(height: 40),
            _fullWidthButton("Proceed to checkout", () {
           Navigator.push(context, MaterialPageRoute(builder: (context)=>SummaryScreen()));
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ── UI HELPERS ──
  Widget _buildProfessionalCard(int index) {
    final pro = professionals[index];
    bool isSelected = _selectedIdx == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIdx = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundImage: AssetImage(pro.image)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${pro.name} (${pro.salon})", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("${pro.experience} | ${pro.time} from you", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.arrow_circle_right, color: isSelected ? AppColors.primary : Colors.grey.shade300, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _customTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
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
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day, style: TextStyle(color: isSelected ? AppColors.primary : Colors.grey, fontSize: 12)),
          Text(date, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : Colors.black)),
        ],
      ),
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
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}