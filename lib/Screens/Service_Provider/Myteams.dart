import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/endpoint/endpoint.dart'; // Ensure this has baseUrl
import 'package:s_a/const/session/session.dart';
// Ensure the path to your modal is correct
import 'package:s_a/const/Modal/profectionalListModal.dart' as pro_modal;

class TeamManagementPage extends StatefulWidget {
  const TeamManagementPage({super.key});

  @override
  State<TeamManagementPage> createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  // ── DATA STATE ──
  List<pro_modal.Data> _professionals = [];
  bool _isLoading = true;
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["All", "Active", "On Job", "Off Duty"];

  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }

  // ── API FETCH LOGIC ──
  Future<void> _loadTeamData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Get Owner ID from session
      final userData = await UserPref.getUser();
      final int ownerId = userData['userId'] ?? 0;

      // 2. Fetch from API
      final response = await ApiService.fetchProfessionals(ownerId);

      if (mounted) {
        setState(() {
          _professionals = response?.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("💀 Team Load Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        onRefresh: _loadTeamData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── 1. STATS SECTION ──
              Row(
                children: [
                  Expanded(child: _buildTotalMembersCard(_professionals.length)),
                  const SizedBox(width: 12),
                  // Note: Backend doesn't currently provide status counts, using placeholders
                  Expanded(child: _buildProgressBarStat("ON JOB", 0, 0.0, Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildProgressBarStat("AVAILABLE", _professionals.length, 1.0, Colors.deepPurple)),
                ],
              ),
              const SizedBox(height: 24),

              // ── 2. SEARCH BAR ──
              _buildSearchBar(),
              const SizedBox(height: 20),

              // ── 3. FILTER CHIPS ──
              _buildFilterChips(),
              const SizedBox(height: 24),

              // ── 4. DYNAMIC TEAM LIST ──
              _professionals.isEmpty
                  ? const Center(child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text("No professionals found"),
              ))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _professionals.length,
                itemBuilder: (context, index) {
                  final pro = _professionals[index];
                  return _buildProfessionalCard(
                    name: pro.name ?? "Expert",
                    phone: pro.phone ?? "No Phone",
                    status: "ACTIVE", // Defaulting to active
                    statusColor: Colors.green,
                    tags: [pro.profession?.toUpperCase() ?? "SPECIALIST"],
                    imageUrl: pro.image != null
                        ? "${ApiEndoint.baseUrl}${pro.image}"
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Professional Page
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  // ── UI COMPONENTS ──

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const Icon(Icons.menu, color: Colors.black),
      title: const Text("Team Management", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin')),
        )
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search professionals...",
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFE9EEF2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          bool isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : const Color(0xFFDDE4ED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_filters[index],
                  style: TextStyle(color: isSelected ? Colors.white : Colors.blueGrey, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalMembersCard(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FittedBox(child: Text("TOTAL TEAM MEMBERS", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          Text("$total", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const FittedBox(
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue, size: 14),
                SizedBox(width: 2),
                Text("Syncing live", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProgressBarStat(String title, int value, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("$value", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFFF0F0F0), color: color, minHeight: 6),
          )
        ],
      ),
    );
  }

  Widget _buildProfessionalCard({
    required String name,
    required String phone,
    required String status,
    required Color statusColor,
    required List<String> tags,
    String? imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                    child: imageUrl == null ? const Icon(Icons.person) : null,
                  ),
                  Positioned(
                    bottom: 2, right: 2,
                    child: CircleAvatar(radius: 6, backgroundColor: Colors.white, child: CircleAvatar(radius: 4, backgroundColor: statusColor)),
                  )
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(8)),
              child: Text(tag, style: const TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.bold)),
            )).toList(),
          )
        ],
      ),
    );
  }
}