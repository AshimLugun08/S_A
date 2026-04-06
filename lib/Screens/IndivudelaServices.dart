import 'package:flutter/material.dart';
import 'package:s_a/Screens/SubServicesScreen.dart';
import 'package:s_a/const/color/colors.dart';

class SalonService {
  final String title;
  final String price;
  final String image;

  SalonService({required this.title, required this.price, required this.image});
}

class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── DYNAMIC SERVICE DATA ──
    final List<SalonService> services = [
      SalonService(title: "Facial for glow", price: "599", image: "assets/images/s1.jpg"),
      SalonService(title: "Manicure", price: "399", image: "assets/images/s2.jpg"),
      SalonService(title: "Pedicure", price: "399", image: "assets/images/s3.jpg"),
      SalonService(title: "Threading", price: "60", image: "assets/images/s4.jpg"),
    ];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return _buildServiceCard(context,services[index]);
        },
      ),
    );
  }

  // ── INDIVIDUAL SERVICE CARD ──
// ── UPDATE: Pass 'context' into the method ──
  Widget _buildServiceCard(BuildContext context, SalonService service) {
    return InkWell(
      // ── NAVIGATION LOGIC ──
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FacialSelectionScreen(),
          ),
        );
      },
      // Optional: make the ripple match the card corners
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. Service Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                service.image,
                width: 120,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120, height: 110, color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),

            const SizedBox(width: 15),

            // 2. Service Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3A8C),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 12),
                    height: 2,
                    width: 40,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  Text(
                    "₹${service.price}",
                    style: const TextStyle(
                      fontSize: 22,
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

            // 3. Arrow Action Button
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}