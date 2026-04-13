import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart'; // Ensure your path is correct

class TeamManagementPage extends StatefulWidget {
  const TeamManagementPage({super.key});

  @override
  State<TeamManagementPage> createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["All", "Active", "On Job", "Off Duty"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Subtle off-white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black),
        title: const Text(
          "Team Management",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin'),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── 1. STATS SECTION ──
            Row(
              children: [
                Expanded(child: _buildTotalMembersCard()),
                const SizedBox(width: 12),
                Expanded(child: _buildProgressBarStat("ON JOB", 12, 0.5, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildProgressBarStat("AVAILABLE", 8, 0.3, Colors.deepPurple)),
              ],
            ),
            const SizedBox(height: 24),

            // ── 2. SEARCH BAR ──
            TextField(
              decoration: InputDecoration(
                hintText: "Search professionals...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFE9EEF2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── 3. FILTER CHIPS ──
            SizedBox(
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
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // ── 4. TEAM LIST ──
            _buildProfessionalCard(
              name: "Marcus Thorne",
              phone: "+1 (555) 012-3456",
              status: "ACTIVE",
              statusColor: Colors.green,
              tags: ["ELECTRICAL", "HVAC"],
              imageUrl: "https://i.pravatar.cc/150?u=1",
            ),
            _buildProfessionalCard(
              name: "Elena Rodriguez",
              phone: "+1 (555) 098-7654",
              status: "ON JOB",
              statusColor: Colors.blue,
              tags: ["PLUMBING", "EMERGENCY"],
              imageUrl: "https://i.pravatar.cc/150?u=2",
            ),
            _buildProfessionalCard(
              name: "David Kim",
              phone: "+1 (555) 444-2211",
              status: "OFF DUTY",
              statusColor: Colors.grey,
              tags: ["CARPENTRY", "REPAIR"],
              imageUrl: "https://i.pravatar.cc/150?u=3",
            ),
            _buildProfessionalCard(
              name: "Sarah Jenkins",
              phone: "+1 (555) 777-8899",
              status: "ACTIVE",
              statusColor: Colors.green,
              tags: ["INTERIOR", "DESIGN"],
              imageUrl: "https://i.pravatar.cc/150?u=4",
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── STATS CARD WIDGETS ──

  Widget _buildTotalMembersCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), // Reduced horizontal padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use FittedBox so the long title scales down on small screens
          const FittedBox(
            child: Text(
              "TOTAL TEAM MEMBERS",
              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Text("24", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Use FittedBox here to prevent the +3 row from overflowing
          const FittedBox(
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue, size: 14), // Reduced icon size
                SizedBox(width: 2), // Reduced spacing
                Text(
                  "+3 this month",
                  style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("$value", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF0F0F0),
              color: color,
              minHeight: 6,
            ),
          )
        ],
      ),
    );
  }

  // ── PROFESSIONAL CARD WIDGET ──

  Widget _buildProfessionalCard({
    required String name,
    required String phone,
    required String status,
    required Color statusColor,
    required List<String> tags,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(radius: 28, backgroundImage: NetworkImage(imageUrl)),
                  Positioned(
                    bottom: 2,
                    right: 2,
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

  // ── BOTTOM NAVIGATION ──

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 2, // Team tab active
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'OVERVIEW'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'SCHEDULE'),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'TEAM'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'PROFILE'),
      ],
    );
  }
}