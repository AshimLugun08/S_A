import 'package:flutter/material.dart';
import 'package:s_a/Screens/Service_Provider/EditProfilePage.dart';
import 'package:s_a/const/color/colors.dart';
// import 'package:your_project/const/color/colors.dart'; // Apna path check karein

class AccountProfilePage extends StatelessWidget {
  const AccountProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- OVERALL RATING CARD ---
            _buildOverallRatingCard(),
            const SizedBox(height: 16),

            // --- RATING BREAKDOWN CARD ---
            _buildRatingBreakdown(),
            const SizedBox(height: 20),

            // --- STATS GRID ---
            const _StatsGrid(),
            const SizedBox(height: 30),

            // --- CLIENT FEEDBACK SECTION ---
            const _ClientFeedbackHeader(),
            const SizedBox(height: 16),

            // --- REVIEW LIST ---
            _buildReviewCard(
              name: "Marcus Rivera",
              role: "Interior Design Consult",
              date: "May 12, 2024",
              comment: "Absolutely phenomenal service! The attention to detail during our design consultation was beyond what I expected...",
              initials: "MR",
              avatarColor: Colors.blue.shade100,
            ),
            _buildReviewCard(
              name: "Sarah O'Connell",
              role: "Logo Branding Package",
              date: "April 28, 2024",
              comment: "I was struggling with my brand identity for months. They took my vague ideas and turned them into something truly premium...",
              initials: "SO",
              avatarColor: Colors.blue.shade50,
            ),

            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {},
              icon: const Text("View 124 more reviews", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              label: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            ),
            const SizedBox(height: 80), // Bottom nav space
          ],
        ),
      ),
    );
  }

  // ── APP BAR WITH EDIT OPTION ──
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex'),
        ),
      ),
      title: const Text("Fluid Marketplace",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
      actions: [
        // EDIT PROFILE BUTTON
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceManagementPage()));
          },
          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          tooltip: "Edit Profile",
        ),
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: AppColors.iconSecondary)
        ),
      ],
    );
  }

  // ── OVERALL RATING CARD ──
  Widget _buildOverallRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text("OVERALL RATING",
              style: TextStyle(letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const Text("4.9",
              style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: AppColors.primary)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => Icon(
              index < 4 ? Icons.star : Icons.star_half,
              color: AppColors.primary,
              size: 28,
            )),
          ),
          const SizedBox(height: 8),
          const Text("Based on 128 client reviews", style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ── RATING BREAKDOWN ──
  Widget _buildRatingBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          _ratingRow("5 Star", 0.85, "85%"),
          _ratingRow("4 Star", 0.12, "12%"),
          _ratingRow("3 Star", 0.02, "2%"),
          _ratingRow("2 Star", 0.01, "1%"),
          _ratingRow("1 Star", 0.00, "0%"),
        ],
      ),
    );
  }

  Widget _ratingRow(String label, double val, String percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 45, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: val,
                minHeight: 8,
                backgroundColor: AppColors.background,
                color: AppColors.primaryLight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(percent, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── REVIEW CARD ──
  Widget _buildReviewCard({required String name, required String role, required String date, required String comment, required String initials, required Color avatarColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: avatarColor, child: Text(initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(role, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
                child: Text(date, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) => const Icon(Icons.star, color: AppColors.primary, size: 16)),
          ),
          const SizedBox(height: 10),
          Text(comment, style: const TextStyle(color: AppColors.textPrimary, height: 1.4, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── STATS GRID COMPONENT ──
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _statItem("99%", "On-time Completion"),
        _statItem("1hr", "Avg Response Time"),
        _statItem("42", "Repeat Clients"),
        _statItem("Top", "Marketplace Pro"),
      ],
    );
  }

  Widget _statItem(String val, String label) {
    return Container(
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── FEEDBACK HEADER WITH CHIPS ──
class _ClientFeedbackHeader extends StatelessWidget {
  const _ClientFeedbackHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Client\nFeedback", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.1)),
        Row(
          children: [
            _filterChip("Latest", true),
            const SizedBox(width: 8),
            _filterChip("Highest Rated", false),
          ],
        )
      ],
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8EDF2) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? AppColors.textPrimary : AppColors.textSecondary)),
    );
  }
}