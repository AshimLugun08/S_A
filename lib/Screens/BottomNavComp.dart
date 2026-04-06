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
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.navSelected,
          unselectedItemColor: AppColors.navUnselected,

          // ── ADD THESE TWO LINES TO INCREASE ICON SIZE ──
          selectedIconTheme: const IconThemeData(size: 40),   // Size when item is selected
          unselectedIconTheme: const IconThemeData(size: 35), // Size when item is NOT selected

          selectedFontSize: 12,
          unselectedFontSize: 12,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined),
              activeIcon: Icon(Icons.local_offer),
              label: 'Offer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}