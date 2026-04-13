import 'package:flutter/material.dart';
import 'package:s_a/Screens/Service_Provider/AddMemberScreen.dart';
import 'package:s_a/Screens/Service_Provider/EditProfilePage.dart'; // Ensure this path is correct
import 'package:s_a/Screens/Service_Provider/Myteams.dart';
import 'package:s_a/const/color/colors.dart';

class AccountProfilePage extends StatelessWidget {
  const AccountProfilePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          children: [
            // 1. PROFESSIONAL HEADER (Avatar + Bio)
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // 2. PROFESSIONAL ACTION STRIP (Share, View, Support)
            _buildProfessionalActionButtons(context),
            const SizedBox(height: 30),

            // 3. STATS GRID (Performance Metrics)
            const _StatsGrid(),
            const SizedBox(height: 24),

            // 4. OVERALL RATING CARD
            _buildOverallRatingCard(),
            const SizedBox(height: 16),

            // 5. RATING BREAKDOWN
            _buildRatingBreakdown(),
            const SizedBox(height: 24),

            // 6. PROFESSIONAL SETTINGS MENU
            _buildProfessionalMenu(context),
            const SizedBox(height: 30),

            // 7. CLIENT FEEDBACK SECTION
            const _ClientFeedbackHeader(),
            const SizedBox(height: 16),

            // REVIEWS
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
              icon: const Text("View 124 more reviews",
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              label: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            ),
            const SizedBox(height: 100), // Extra space for Bottom Navigation Bar
          ],
        ),
      ),
    );
  }

  // ── APP BAR ──
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text("Professional Profile",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
      actions: [
        IconButton(
          onPressed: () {
            // Logic to switch profile or settings
          },
          icon: Image.asset("assets/icons/switch.png", height: 24),
        ),
      ],
    );
  }

  // ── 1. PROFILE HEADER ──
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex'),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text("Alex Benjamin",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const Text("Professional Interior Designer",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text("Top Rated Pro",
              style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // ── 2. PROFESSIONAL ACTION BUTTONS ──
  Widget _buildProfessionalActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // _actionIcon(Icons.share_outlined, "Share"),
        _actionItem("assets/icons/developers.png", "My Team",onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TeamManagementPage()));
        },),
        _actionItem("assets/icons/worker.png", "Add Member",onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProfessionalPage()));
        },),
        // _actionIcon(Icons.remove_red_eye_outlined, "Public View"),
        _actionItem("assets/icons/customer-service.png" ,"Support",onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TeamManagementPage()));
        },)
      ],
    );
  }

  Widget _actionItem(String imageAssetPath, String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap, // ─── CLICK ACTION ADDED HERE ───
      behavior: HitTestBehavior.opaque, // Ensures the entire area (including padding) is clickable
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                imageAssetPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }



  // ── 6. PROFESSIONAL SETTINGS MENU ──
  Widget _buildProfessionalMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _menuItem("assets/icons/pencil.png", "Edit Profile", "Update bio and contact info",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceManagementPage()))
          ),
          _menuItem("assets/icons/offer.png", "My Services", "Manage your service listings"),


          // _menuItem(Icons.account_balance_wallet_outlined, "Earnings", "\$4,250.00 available to withdraw"),
          // _menuItem(, "Logout", "Exit your professional account",
          //     isLast: true, color: Colors.redAccent
          // ),
        ],
      ),
    );
  }

  Widget _menuItem(
      String imageAsset, // Changed from IconData icon
      String title,
      String subtitle, {
        bool isLast = false,
        Color? color,
        VoidCallback? onTap,
      }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // Keeps your light tinted background
          color: (color ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset(
          imageAsset,
          width: 20, // Matching your original icon size
          height: 20,
          fit: BoxFit.contain,

        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 18,
        color: AppColors.textSecondary,
      ),
      shape: isLast ? null : const Border(
        bottom: BorderSide(color: AppColors.divider), // Changed from AppColors.background for visibility
      ),
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