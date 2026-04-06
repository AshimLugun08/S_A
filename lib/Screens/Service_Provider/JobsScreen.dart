import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart';
// import 'package:your_project/const/color/colors.dart'; // Apna path check karein

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});

  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen> {
  int _selectedTab = 0; // 0: Upcoming, 1: Ongoing, 2: Completed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // --- CUSTOM TAB BAR ---
            _buildCustomTabBar(),
            const SizedBox(height: 30),

            // --- SECTION HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("SCHEDULE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
                    Text("Today's Tasks", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                _buildStatusBadge("3 Jobs Left", AppColors.secondary, AppColors.primary),
              ],
            ),
            const SizedBox(height: 20),

            // --- UPCOMING JOB CARD ---
            _buildUpcomingCard(),
            const SizedBox(height: 16),

            // --- ONGOING JOB CARD ---
            _buildOngoingCard(),
            const SizedBox(height: 16),

            // --- REVIEW COMPLETED JOBS ---
            _buildReviewActionCard(),
            const SizedBox(height: 16),

            // --- NEXT JOB LOCATION CARD ---
            _buildNextJobMapCard(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ── APP BAR ──
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const Icon(Icons.menu, color: AppColors.primary),
      title: const Text("Manage Jobs", style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        const Icon(Icons.filter_list, color: AppColors.textSecondary),
        const SizedBox(width: 15),
        const Padding(
          padding: EdgeInsets.only(right: 15),
          child: CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a')),
        ),
      ],
    );
  }

  // ── CUSTOM TAB BAR ──
  Widget _buildCustomTabBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          _tabItem("Upcoming", 0),
          _tabItem("Ongoing", 1),
          _tabItem("Completed", 2),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // ── UPCOMING CARD ──
  Widget _buildUpcomingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 25, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=sarah')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Sarah Jenkins", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(" 4.9 • New Customer", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusBadge("CONFIRMED", AppColors.secondary, AppColors.primary),
            ],
          ),
          const Divider(height: 30),
          _jobDetailRow(Icons.cleaning_services_outlined, "Service Type", "Deep Home Cleaning"),
          _jobDetailRow(Icons.access_time, "Date & Time", "Today, 2:00 PM - 5:00 PM"),
          _jobDetailRow(Icons.location_on_outlined, "Location", "4521 Oakwood Ave, Silver Lake, CA"),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _actionButton("View Details", Colors.grey.shade100, Colors.black)),
              const SizedBox(width: 12),
              Expanded(child: _actionButton("Start Job", AppColors.primary, Colors.white)),
            ],
          )
        ],
      ),
    );
  }

  // ── ONGOING CARD ──
  Widget _buildOngoingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 25, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=michael')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Michael Chen", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("AC System Maintenance", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              _buildStatusBadge("• IN PROGRESS", AppColors.primary, Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("ESTIMATED FINISH", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Text("45 MIN LEFT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(value: 0.6, minHeight: 8, backgroundColor: Colors.white, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _actionButton("Navigate", Colors.white, Colors.black, icon: Icons.near_me, isOutlined: true)),
              const SizedBox(width: 12),
              Expanded(child: _actionButton("Manage Job", AppColors.primary, Colors.white)),
            ],
          )
        ],
      ),
    );
  }

  // ── REVIEW ACTION CARD ──
  Widget _buildReviewActionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid)),
      child: Row(
        children: [
          const Icon(Icons.history, color: Colors.grey),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Review Completed Jobs", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("12 jobs finished this week", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }

  // ── NEXT JOB MAP CARD ──
  Widget _buildNextJobMapCard() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?w=600'), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.7)])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.my_location, color: AppColors.primary)),
            const SizedBox(height: 10),
            const Text("Next Job Location", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("3.4 miles from your current position", style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ──
  Widget _jobDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle), child: Icon(icon, size: 16, color: AppColors.primary)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color bg, Color text, {IconData? icon, bool isOutlined = false}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: isOutlined ? Border.all(color: Colors.grey.shade200) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 16, color: text),
          if (icon != null) const SizedBox(width: 8),
          Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}