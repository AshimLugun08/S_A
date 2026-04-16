import 'package:flutter/material.dart';
import 'package:s_a/Screens/BookingScreen.dart';
import 'package:s_a/Screens/EditScreen.dart';
import 'package:s_a/Screens/LoginScreen.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart'; // Ensure fetchProfile is here
import 'package:s_a/const/session/session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAndSyncProfile();
  }

  // ── 1. LOAD LOCAL & SYNC WITH SERVER ──
  Future<void> _loadAndSyncProfile() async {
    // 1. Local data load karein taaki screen khali na dikhe
    final localData = await UserPref.getUser();
    setState(() {
      _userData = localData;
    });

    try {
      final int userId = localData['userId'] ?? 0;

      if (userId != 0) {
        // 2. Server se fresh data fetch karein
        final serverResponse = await ApiService.fetchProfile(userId);

        if (serverResponse != null && serverResponse.status == true) {
          final serverData = serverResponse.data;

          if (serverData != null && mounted) {
            // ── SESSION SAVE REMOVED ──
            // Humne yahan se UserPref.saveUser() hata diya hai.
            print("object ${serverData.profileImage}");

            setState(() {
              // Sirf local state update kar rahe hain display ke liye
              _userData = {
                "userId": serverData.userId,
                "name": serverData.name,
                "email": serverData.email,
                "phone": serverData.phone,
                "address": serverData.address ?? localData['address'],
                "profile_image": serverData.profileImage,
              };
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("💀 Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _goToEditPage() async {
    // Navigator.push se result ka wait karenge
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    // Agar EditProfileScreen se 'true' wapas aata hai, toh refresh karein
    if (result == true) {
      _loadAndSyncProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading && _userData.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        onRefresh: _loadAndSyncProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ── CURVED HEADER & PROFILE IMAGE ──
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180, width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(250, 100)),
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
                              child: Text("Profile", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -60,
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
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: (_userData['profile_image'] != null && _userData['profile_image'] != "")
                                    ? NetworkImage(_userData['profile_image'])
                                    : const AssetImage('assets/images/user.png') as ImageProvider,
                              ),
                            ),
                            // ── CAMERA ICON CLICKABLE ──
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: _goToEditPage, // Camera par click karne par bhi edit page
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.green)),
                                  child: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.green),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _userData['name'] ?? "User",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100),

              // ── MENU LIST ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildMenuItem(
                      title: "Name: ${_userData['name'] ?? 'N/A'}",
                      trailingIcon: Icons.edit_outlined,
                      imagePath: "assets/icons/label.png",
                      onTap: _goToEditPage, // 👈 Redirect to edit
                    ),
                    _buildMenuItem(
                      title: "Email: ${_userData['email'] ?? 'N/A'}",
                      trailingIcon: Icons.edit_outlined,
                      imagePath: "assets/icons/gmail.png",
                      onTap: _goToEditPage, // 👈 Redirect to edit
                    ),
                    _buildMenuItem(
                      title: "Phone: ${_userData['phone'] ?? 'N/A'}",
                      trailingIcon: Icons.edit_outlined,
                      imagePath: "assets/icons/delivery.png",
                      onTap: _goToEditPage, // 👈 Redirect to edit
                    ),
                    _buildMenuItem(
                      title: "Address: ${_userData['address'] ?? 'No Address'}",
                      trailingIcon: Icons.edit_outlined,
                      imagePath: "assets/icons/location-pin.png",
                      onTap: _goToEditPage, // 👈 Redirect to edit
                    ),
                    _buildMenuItem(
                      title: "Booking Confirmation",
                      trailingIcon: Icons.arrow_forward_ios,
                      isSmallArrow: true,
                      imagePath: "assets/icons/booking.png",
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>BookingScreen()));
                      }
                    ),
                    // _buildMenuItem(
                    //   title: "History",
                    //   trailingIcon: Icons.arrow_forward_ios,
                    //   isSmallArrow: true,
                    //   imagePath: "assets/icons/clock.png",
                    // ),
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
      ),
    );
  }

  // ── LOGOUT & HELPER WIDGETS ──
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await UserPref.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required String title, required IconData trailingIcon, String? imagePath, Color? trailingIconColor, bool isSmallArrow = false, VoidCallback? onTap}) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1))),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: imagePath != null ? Image.asset(imagePath, width: 22, height: 22, fit: BoxFit.contain) : null,
        title: Text(title, style: const TextStyle(color: Color(0xFF6E6E73), fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: Icon(trailingIcon, size: isSmallArrow ? 18 : 22, color: trailingIconColor ?? Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }
}