import 'package:flutter/material.dart';
import 'package:s_a/Screens/Service_Provider/DashbordScreen.dart';
import 'package:s_a/Screens/Service_Provider/EarningsScreen.dart';
import 'package:s_a/Screens/Service_Provider/JobsScreen.dart';
import 'package:s_a/Screens/Service_Provider/ProfileScreen.dart';
import 'package:s_a/const/color/colors.dart';


class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}



class _MainContainerState extends State<MainContainer> {

  int _selectedIndex = 0;

  final List<Widget> _pages = [

    const ProviderDashboard(),
    const ManageJobsScreen(),
    const EarningsScreen(),
    const AccountProfilePage(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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
          type: BottomNavigationBarType.fixed, // 4 items ke liye fixed best hai
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          // 1. Remove 'const' from the items list
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/data.png',
                height: 35,
              ),
              activeIcon: Image.asset(
                'assets/icons/data.png',
                height: 40,
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/job-search.png',
                height: 35,
              ),
              activeIcon: Image.asset(
                'assets/icons/job-search.png',
                height: 40,
              ),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/earning.png',
                height: 35,
              ),
              activeIcon: Image.asset(
                'assets/icons/earning.png',
                height: 40,
              ),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/profile.png',
                height: 35,
              ),
              activeIcon: Image.asset(
                'assets/icons/profile.png',
                height: 40,
              ),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}