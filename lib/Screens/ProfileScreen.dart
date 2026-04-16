import 'package:flutter/material.dart';
import 'package:s_a/Screens/LoginScreen.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/session/session.dart';

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
                  _buildMenuItem(
                    title: "Name",
                    trailingIcon: Icons.edit_outlined,
                    imagePath: "assets/icons/label.png",
                    // onTap: () => _editField("Name"),
                  ),
                  _buildMenuItem(
                    title: "Email",
                    trailingIcon: Icons.edit_outlined,
                    imagePath: "assets/icons/gmail.png",
                    // onTap: () => _editField("Email"),
                  ),
                  _buildMenuItem(
                    title: "Address",
                    trailingIcon: Icons.edit_outlined,
                    imagePath: "assets/icons/location-pin.png",
                    // onTap: () => _editField("Address"),
                  ),
                  _buildMenuItem(
                    title: "Payment Due",
                    trailingIcon: Icons.arrow_forward_ios,
                    isSmallArrow: true,
                    imagePath: "assets/icons/money.png",
                    // onTap: () => _navigateTo("payment_due"),
                  ),
                  _buildMenuItem(
                    title: "Invoice Download",
                    trailingIcon: Icons.arrow_forward_ios,
                    isSmallArrow: true,
                    imagePath: "assets/icons/invoice.png",
                    // onTap: () => _navigateTo("invoice"),
                  ),
                  _buildMenuItem(
                    title: "Booking Confirmation",
                    trailingIcon: Icons.arrow_forward_ios,
                    isSmallArrow: true,
                    imagePath: "assets/icons/booking.png",
                    // onTap: () => _navigateTo("booking_confirmation"),
                  ),
                  _buildMenuItem(
                    title: "History",
                    trailingIcon: Icons.arrow_forward_ios,
                    isSmallArrow: true,
                    imagePath: "assets/icons/clock.png",
                    // onTap: () => _navigateTo("history"),
                  ),
                  _buildMenuItem(
                    title: "Order Status",
                    trailingIcon: Icons.arrow_forward_ios,
                    isSmallArrow: true,
                    imagePath: "assets/icons/delivery.png",
                    // onTap: () => _navigateTo("order_status"),
                  ),
                  _buildMenuItem(
                    title: "FAQ section",
                    trailingIcon: Icons.arrow_forward_ios,
                    isSmallArrow: true,
                    imagePath: "assets/icons/faq.png",
                    // onTap: () => _navigateTo("faq"),
                  ),
                  _buildMenuItem(
                    title: "Support",
                    trailingIcon: Icons.arrow_forward_ios,
                    isSmallArrow: true,
                    imagePath: "assets/icons/headphones.png",
                    // onTap: () => _navigateTo("support"),
                  ),
                  _buildMenuItem(
                    title: "Logout",
                    trailingIcon: Icons.logout,
                    trailingIconColor: Colors.red,
                    imagePath: "assets/icons/switch.png",
                    onTap: () => _showLogoutConfirmation(context),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await UserPref.logout(); // Clear session
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData trailingIcon,
    String? imagePath,
    Color? trailingIconColor,
    bool isSmallArrow = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: imagePath != null
            ? Image.asset(imagePath, width: 22, height: 22, fit: BoxFit.contain)
            : null,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF6E6E73),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          trailingIcon,
          size: isSmallArrow ? 18 : 22,
          color: trailingIconColor ?? Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }
}