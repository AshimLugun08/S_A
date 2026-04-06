import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart';
// import 'package:your_project/const/color/colors.dart'; // Apna path check karein

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOTAL EARNINGS GRADIENT CARD ---
            _buildTotalEarningsCard(),
            const SizedBox(height: 30),

            // --- EARNING INSIGHTS (BAR CHART) ---
            _buildEarningInsightsHeader(),
            const SizedBox(height: 20),
            _buildBarChart(),
            const SizedBox(height: 30),

            // --- RECENT ACTIVITY ---
            _buildRecentActivityHeader(),
            const SizedBox(height: 16),
            _buildActivityItem(
              icon: Icons.work,
              title: "Professional Cleaning",
              subtitle: "Yesterday, 4:30 PM",
              amount: "+\$120.00",
              status: "COMPLETED",
              isPositive: true,
            ),
            _buildActivityItem(
              icon: Icons.payments_outlined,
              title: "Weekly Payout",
              subtitle: "Oct 12, 2023",
              amount: "-\$1,840.00",
              status: "WITHDRAWN",
              isPositive: false,
            ),
            _buildActivityItem(
              icon: Icons.build_circle_outlined,
              title: "Furniture Assembly",
              subtitle: "Oct 10, 2023",
              amount: "+\$85.50",
              status: "COMPLETED",
              isPositive: true,
            ),

            const SizedBox(height: 20),

            // --- WITHDRAWAL BUTTON ---
            _buildWithdrawalButton(),
            const SizedBox(height: 100), // Bottom nav space
          ],
        ),
      ),
    );
  }

  // ── APP BAR ──
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a')),
      ),
      title: const Text("Fluid Marketplace",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: AppColors.iconSecondary)),
      ],
    );
  }

  // ── TOTAL EARNINGS CARD ──
  Widget _buildTotalEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A90E2), Color(0xFF2F6FC1)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Earnings", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          const Text("\$12,840.50",
              style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _subEarningBox("Monthly", "\$2,450.00")),
              const SizedBox(width: 15),
              Expanded(child: _subEarningBox("Pending", "\$420.15")),
            ],
          )
        ],
      ),
    );
  }

  Widget _subEarningBox(String title, String amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── BAR CHART SECTION ──
  Widget _buildEarningInsightsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Earning Insights", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(20)),
          child: const Text("This Month", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final List<double> values = [0.4, 0.7, 0.6, 0.9, 0.5, 0.65, 0.3];
    final List<String> days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              bool isSelected = index == 3; // Thursday highlighted
              return Column(
                children: [
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(6)),
                      child: const Text("\$840", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120 * values[index],
                    width: 35,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryDark : AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(days[index], style: TextStyle(fontSize: 10, color: isSelected ? AppColors.primary : Colors.grey, fontWeight: FontWeight.bold)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── RECENT ACTIVITY ──
  Widget _buildRecentActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Recent Activity", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        TextButton(onPressed: () {}, child: const Text("View All", style: TextStyle(color: AppColors.primary))),
      ],
    );
  }

  Widget _buildActivityItem({required IconData icon, required String title, required String subtitle, required String amount, required String status, required bool isPositive}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: TextStyle(fontWeight: FontWeight.bold, color: isPositive ? AppColors.primaryDark : Colors.black87)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ── WITHDRAWAL BUTTON ──
  Widget _buildWithdrawalButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4A90E2), Color(0xFF6FAAF0)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
        label: const Text("Withdrawal Request", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}