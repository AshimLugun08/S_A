import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart';
// import 'package:your_project_path/const/color/colors.dart'; // Apna path check kar lein

class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

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
            // --- GREETING ---
            const Text("Good morning,\nAlex.",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.1
                )),
            const SizedBox(height: 8),
            const Text("You have 4 jobs scheduled for today.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 25),

            // --- EARNINGS CARD ---
            _buildEarningsCard(),
            const SizedBox(height: 16),

            // --- RATING CARD ---
            _buildRatingCard(),
            const SizedBox(height: 30),

            // --- SCHEDULE HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today's Schedule",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary
                    )),
                TextButton(
                    onPressed: () {},
                    child: const Text("View Calendar", style: TextStyle(color: AppColors.primary))
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- JOB CARDS ---
            _buildJobCard(
              title: "Deep Home Cleaning",
              name: "Sarah Jenkins",
              time: "09:00 AM - 11:30 AM",
              location: "482 Oakwood Ave, Seattle",
              status: "IN PROGRESS",
              icon: Icons.cleaning_services,
              button: _primaryButton("Complete Job"),
            ),
            _buildJobCard(
              title: "Kitchen Faucet Repair",
              name: "Marcus Chen",
              time: "01:30 PM",
              location: "129 Highland Terrace",
              status: "NEW REQUEST",
              icon: Icons.build,
              button: Row(
                children: [
                  Expanded(child: _secondaryButton("Reject")),
                  const SizedBox(width: 12),
                  Expanded(child: _primaryButton("Accept")),
                ],
              ),
            ),

            // --- HEATMAP SECTION ---
            const SizedBox(height: 30),
            const Text("Service Area Heatmap",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _buildHeatMap(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textLight),
      ),
    );
  }

  // ── APP BAR ──
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a')),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Fluid Marketplace",
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Provider Console",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: AppColors.iconSecondary)
        ),
      ],
    );
  }

  
  Widget _buildEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Estimated Earnings", style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text("\$428.50",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.trending_up, color: AppColors.primary, size: 20),
              SizedBox(width: 4),
              Text("12% more than yesterday",
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }

  // ── RATING CARD ──
  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.star, color: AppColors.textLight)
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("4.9",
                  style: TextStyle(color: AppColors.textLight, fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Customer Rating", style: TextStyle(color: Colors.white70)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
            child: const Text("TOP RATED",
                style: TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // ── JOB CARD WIDGET ──
  Widget _buildJobCard({
    required String title,
    required String name,
    required String time,
    required String location,
    required String status,
    required IconData icon,
    required Widget button,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12), // Gap thoda kam kiya 16 se 12 tak

              // Middle Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1, // Sirf ek line allow karein
                      overflow: TextOverflow.ellipsis, // Baki text "..." ban jayega
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$name • $time",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        // Location text ko bhi flexible banaya
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8), // Status badge se pehle gap

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          button,
        ],
      ),
    );
  }

  // ── BUTTONS ──
  Widget _primaryButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0
        ),
        child: Text(label, style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _secondaryButton(String label) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
        ),
        child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── HEATMAP MOCK ──
  Widget _buildHeatMap() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.searchBar,
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?auto=format&fit=crop&q=80&w=600'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 16, left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
              child: const Text("Seattle, WA • Active Zone",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
            ),
          )
        ],
      ),
    );
  }
}