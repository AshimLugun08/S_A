import 'package:flutter/material.dart';
import 'package:s_a/const/Modal/earningListModal.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/session/session.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  // ── 1. STATE VARIABLES ──
  bool _isLoading = true;
  double _totalEarnings = 0.0;
  int _totalBookings = 0;
  List<EarningItem> _activities = [];
  String _ownerName = "Pro";

  @override
  void initState() {
    super.initState();
    _fetchEarningsData();
  }

  // ── 2. FETCH DATA FROM API ──
  Future<void> _fetchEarningsData() async {
    try {
      final userData = await UserPref.getUser();
      final int ownerId = userData['userId'] ?? 0;

      if (ownerId != 0) {
        final response = await ApiService.fetchOwnerEarningList(ownerId);

        if (response != null && response.status == true) {
          setState(() {
            _totalEarnings = response.totalEarning ?? 0.0;
            _totalBookings = response.totalBookings ?? 0;
            _activities = response.data ?? [];
            _ownerName = response.ownerName ?? "Pro";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("💀 Earnings Screen Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        onRefresh: _fetchEarningsData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TOTAL EARNINGS CARD ---
              _buildTotalEarningsCard(),
              const SizedBox(height: 30),

              // --- EARNING INSIGHTS ---
              _buildEarningInsightsHeader(),
              const SizedBox(height: 20),
              _buildBarChart(), // Mock chart logic stays for UI
              const SizedBox(height: 30),

              // --- RECENT ACTIVITY ---
              _buildRecentActivityHeader(),
              const SizedBox(height: 16),

              _activities.isEmpty
                  ? const Center(child: Text("No recent bookings found."))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activities.length,
                itemBuilder: (context, index) {
                  final item = _activities[index];
                  return _buildActivityItem(
                    icon: Icons.history,
                    title: item.serviceName ?? "Service",
                    subtitle: "Customer: ${item.customerName}\n${item.bookingDate} | ${item.bookingTime}",
                    amount: "₹${item.amount}",
                    status: "SUCCESS", // Mock status
                    isPositive: true,
                  );
                },
              ),

              const SizedBox(height: 20),
              _buildWithdrawalButton(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ── UI COMPONENTS (UPDATED WITH DATA) ──

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(backgroundImage: AssetImage('assets/images/user.png')),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Earnings", style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text(_ownerName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: AppColors.iconSecondary)),
      ],
    );
  }

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
          const Text("Balance Amount", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text("₹${_totalEarnings.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _subEarningBox("Total Bookings", "$_totalBookings")),
              const SizedBox(width: 15),
              Expanded(child: _subEarningBox("Pending", "₹0.00")),
            ],
          )
        ],
      ),
    );
  }

  Widget _subEarningBox(String title, String amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
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

  Widget _buildEarningInsightsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Earning Insights", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(20)),
          child: const Text("Weekly", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          bool isSelected = index == 3;
          return Column(
            children: [
              Container(
                height: 100 * values[index],
                width: 30,
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
    );
  }

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
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: isPositive ? AppColors.primaryDark : Colors.black87)),
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
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      ),
    );
  }
}