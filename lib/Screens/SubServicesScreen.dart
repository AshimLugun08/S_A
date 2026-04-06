import 'package:flutter/material.dart';
import 'package:s_a/Screens/ServiceDetailsScreen.dart';
import 'package:s_a/const/color/colors.dart';

class SubServiceItem {
  final String title;
  final String price;
  final String image;

  SubServiceItem({required this.title, required this.price, required this.image});
}

class FacialSelectionScreen extends StatefulWidget {
  const FacialSelectionScreen({super.key});

  @override
  State<FacialSelectionScreen> createState() => _FacialSelectionScreenState();
}

class _FacialSelectionScreenState extends State<FacialSelectionScreen> {
  // ── DYNAMIC DATA ──
  final List<SubServiceItem> facials = [
    SubServiceItem(title: "Pearl Facial", price: "899", image: "assets/images/ss1.jpg"),
    SubServiceItem(title: "Gold Facial", price: "999", image: "assets/images/ss2.jpg"),
    SubServiceItem(title: "Diamond Facial", price: "1299", image: "assets/images/ss3.jpg"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          "Salon for Women",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── 1. SCROLLABLE LIST ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: facials.length,
              itemBuilder: (context, index) {
                return _buildFacialCard(facials[index]);
              },
            ),
          ),

          // ── 2. FIXED PROCEED BUTTON ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context)=>ServiceDetailScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Proceed",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── INDIVIDUAL CARD WIDGET ──
  Widget _buildFacialCard(SubServiceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              item.image,
              width: 110,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A8C), // Matches the blue in your screenshot
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "₹${item.price}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  "onwards",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Add Button (Plus Icon)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade400, // Matching the screenshot's grey-ish button
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}