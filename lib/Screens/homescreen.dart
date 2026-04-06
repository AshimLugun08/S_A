import 'package:flutter/material.dart';
import 'package:s_a/Screens/IndivudelaServices.dart';
import 'package:s_a/const/color/colors.dart';

// --- DATA MODEL ---
class ServiceItem {
  final String title;
  final String image;

  ServiceItem({required this.title, required this.image});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── 1. SALON SERVICES ──
  final List<ServiceItem> salonServices = [
    ServiceItem(title: "Salon for Women", image: "assets/images/salon.png"),
    ServiceItem(title: "Spa for Women", image: "assets/images/salon2.png"),
    ServiceItem(title: "Hair & Skin", image: "assets/images/salon3.png"),
    ServiceItem(title: "Salon for Men", image: "assets/images/salon4.png"),
    ServiceItem(title: "Massage for Men", image: "assets/images/salon5.png"),
  ];

  // ── 2. HOME SERVICES ──
  final List<ServiceItem> homeServices = [
    ServiceItem(title: "Electrical & Plumbing", image: "assets/images/home.png"),
    ServiceItem(title: "Cleaning & Pest", image: "assets/images/home2.png"),
    ServiceItem(title: "Home repairs", image: "assets/images/home3.png"),
    ServiceItem(title: "Home Painting", image: "assets/images/home4.png"),
    ServiceItem(title: "Repair Appliances", image: "assets/images/home5.png"),
  ];

  // ── 3. POPULAR SERVICES (NEW) ──
  final List<ServiceItem> popularServices = [
    ServiceItem(title: "Bleach & Dtan", image: "assets/images/pop.png"),
    ServiceItem(title: "TV Installing", image: "assets/images/pop2.png"),
    ServiceItem(title: "AC Repair", image: "assets/images/pop3.png"),
    ServiceItem(title: "Hair Care", image: "assets/images/pop4.png"),
    ServiceItem(title: "Head Massage", image: "assets/images/pop5.png"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildPromoBanner(),
              _buildCategorySection("Salon Services", salonServices),
              _buildCategorySection("Home Services", homeServices),
              // Updated to use the dynamic popularServices list
              _buildCategorySection("Popular Services", popularServices),
              _buildFooterOffer(),
              const SizedBox(height: 20), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENT METHODS ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/images/user.png'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Hello!", style: TextStyle(color: Colors.grey, fontSize: 14)),
              const Text("Manvi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 12),
                    Text(" Bangalore ▾", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
          const Spacer(),
          _iconButton(Icons.notifications_none_outlined),
          const SizedBox(width: 10),
          _iconButton(Icons.chat_bubble_outline),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: Colors.black54),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search for Services & Packages",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 50,
            width: 80,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tune, color: Colors.white, size: 20),
                SizedBox(width: 4),
                Text("Filter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 140,
      width: double.infinity,
      // CRITICAL: This ensures children don't bleed or leave weird gaps at the edges
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          // ── 1. THE IMAGE (Force to edges)  ──
          Positioned(
            right: 0, // No right padding
            top: 0,   // No top padding
            bottom: 0,// No bottom padding
            width: 180, // Explicitly set how much of the right side it covers
            child: Image.asset(
              'assets/images/banner_bg.png',
              fit: BoxFit.cover, // Forces image to fill the 140x180 area completely
              alignment: Alignment.centerRight,
            ),
          ),

          // ── 2. THE TEXT (Inside its own padding) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Let's make a package\njust for you, Manvi!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Text(
                      "Salon for women",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<ServiceItem> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Text("View All", style: TextStyle(color: Colors.white, fontSize: 10)),
              )
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return InkWell(
                  // ── NAVIGATION TRIGGER ──
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ServiceListScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10), // Matches the container shape
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15, left: 5, top: 5, bottom: 5),
                    child: SizedBox(
                      width: 70,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              item.image,
                              height: 40,
                              width: 40,
                              // Adding a hero tag here would make a nice transition later!
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            maxLines: 2, // Ensures long titles don't break the layout
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFooterOffer() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Signup & get 20% OFF", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("on first salon service", style: TextStyle(fontSize: 12)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Signup Now", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}