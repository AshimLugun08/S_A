import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── 1. CURVED HEADER & PROFILE IMAGE ──
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // The Blue Curved Background
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(250, 100),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              "Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // The Profile Picture with Green Border
                Positioned(
                  bottom: -60, // Pushes it halfway out of the blue area
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: const CircleAvatar(
                              radius: 65,
                              backgroundImage: AssetImage('assets/images/user.png'),
                            ),
                          ),
                          // Camera Icon Button
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.green),
                              ),
                              child: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Manvi",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 100), // Space for the floating profile image

            // ── 2. MENU LIST ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem("Name", Icons.edit_outlined),
                  _buildMenuItem("Email", Icons.edit_outlined),
                  _buildMenuItem("Address", Icons.edit_outlined),
                  _buildMenuItem("Payment Due", Icons.arrow_forward_ios, isSmallArrow: true),
                  _buildMenuItem("Invoice Download", Icons.arrow_forward_ios, isSmallArrow: true),
                  _buildMenuItem("Booking Confirmation", Icons.arrow_forward_ios, isSmallArrow: true),
                  _buildMenuItem("History", Icons.arrow_forward_ios, isSmallArrow: true),
                  _buildMenuItem("Order Status", Icons.arrow_forward_ios, isSmallArrow: true),
                  _buildMenuItem("FAQ section", Icons.arrow_forward_ios, isSmallArrow: true),
                  _buildMenuItem("Support", Icons.arrow_forward_ios, isSmallArrow: true),
                  _buildMenuItem("Logout", Icons.logout, color: Colors.grey),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── REUSABLE MENU ITEM WIDGET ──
  Widget _buildMenuItem(String title, IconData icon, {Color? color, bool isSmallArrow = false}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF6E6E73),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          icon,
          size: isSmallArrow ? 18 : 22,
          color: color ?? Colors.grey.shade400,
        ),
        onTap: () {
          // Handle navigation
        },
      ),
    );
  }
}