import 'package:flutter/material.dart';
import 'package:s_a/Screens/BookingScreen.dart';
import 'package:s_a/Screens/ChatScreen.dart';
import 'package:s_a/Screens/OfferScreeen.dart';
import 'package:s_a/Screens/ProfileScreen.dart';
import 'package:s_a/Screens/homescreen.dart';
import 'package:s_a/const/color/colors.dart';


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // 1. List of screens for the tabs
  final List<Widget> _pages = [
    const HomeScreen(),     // Replace with HomeScreen()
    const BookingScreen(), // Replace with BookingScreen()
    const OfferScreen(),  // Replace with OfferScreen()
    const ChatScreen(),     // Replace with ChatScreen()
    const ProfileScreen()  // Replace with ProfileScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // 2. Body using IndexedStack to keep page states alive
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // 3. The Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: // ... existing imports ...

// 1. Ensure your assets are defined in pubspec.yaml
// assets:
//   - assets/icons/

        BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.navSelected,
          unselectedItemColor: AppColors.navUnselected,
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('assets/icons/3d-house.png', height: 35),
              activeIcon: Image.asset('assets/icons/3d-house.png', height: 40),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/icons/calendar.png', height: 35),
              activeIcon: Image.asset('assets/icons/calendar.png', height: 40),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/icons/offer.png', height: 35),
              activeIcon: Image.asset('assets/icons/offer.png', height: 40),
              label: 'Offer',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/icons/chat.png', height: 35),
              activeIcon: Image.asset('assets/icons/chat.png', height: 40),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/icons/profile.png', height: 35),
              activeIcon: Image.asset('assets/icons/profile.png', height: 40),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}