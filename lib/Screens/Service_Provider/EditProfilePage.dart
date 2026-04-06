import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart';
// import 'package:your_project/const/color/colors.dart'; // Apna path check karein

class ServiceManagementPage extends StatefulWidget {
  const ServiceManagementPage({super.key});

  @override
  State<ServiceManagementPage> createState() => _ServiceManagementPageState();
}

class _ServiceManagementPageState extends State<ServiceManagementPage> {
  double _radius = 25.0;
  bool _isWeekly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: AppColors.iconSecondary)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            const Text("Service\nManagement",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
            const SizedBox(height: 10),
            const Text("Update your offerings, availability, and\nservice zones.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),

            // --- SKILLS & SERVICES ---
            _buildSectionCard(
              icon: Icons.architecture,
              title: "Skills & Services",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip("Plumbing", true),
                      _buildChip("HVAC Repair", true),
                      _buildChip("Electrical", false),
                      _buildChip("Smart Home", false),
                      _buildChip("Appliance Install", false),
                      _buildAddChip(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Years of Professional Experience", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  _buildExperienceInput(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- SERVICE AREA ---
            _buildSectionCard(
              icon: Icons.map_outlined,
              title: "Service Area",
              child: Column(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=400'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Current Radius: ${_radius.toInt()} miles", style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () {}, child: const Text("Change Location", style: TextStyle(color: AppColors.primary))),
                    ],
                  ),
                  Slider(
                    value: _radius,
                    min: 5,
                    max: 100,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _radius = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- AVAILABILITY SCHEDULE ---
            _buildSectionCard(
              icon: Icons.calendar_today_outlined,
              title: "Availability Schedule",
              child: Column(
                children: [
                  _buildToggle(),
                  const SizedBox(height: 20),
                  _buildDaySchedule("MON", ["08:00 - 12:00", "13:00 - 17:00"]),
                  _buildDaySchedule("TUE", ["08:00 - 12:00", "13:00 - 17:00"]),
                  _buildDaySchedule("SAT", [], isUnavailable: true),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ── HELPER: SECTION CARD ──
  Widget _buildSectionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: AppColors.secondary, child: Icon(icon, color: AppColors.primary, size: 20)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // ── HELPER: CHIPS ──
  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryDark : AppColors.secondary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
          if (isSelected) const SizedBox(width: 8),
          if (isSelected) const Icon(Icons.close, size: 14, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildAddChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 16, color: AppColors.primary),
          SizedBox(width: 4),
          Text("Add New", style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── HELPER: EXPERIENCE INPUT ──
  Widget _buildExperienceInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Text("8", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Spacer(),
          Text("years", style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ── HELPER: TOGGLE ──
  Widget _buildToggle() {
    return Container(
      height: 45,
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(child: _toggleItem("Weekly", _isWeekly)),
          Expanded(child: _toggleItem("Specific Dates", !_isWeekly)),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _isWeekly = label == "Weekly"),
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
      ),
    );
  }

  // ── HELPER: DAY SCHEDULE ──
  Widget _buildDaySchedule(String day, List<String> slots, {bool isUnavailable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          if (isUnavailable)
            _slotBox("Unavailable", isDashed: true)
          else
            ...slots.map((s) => _slotBox(s)).toList(),
          _slotBox("+", isDashed: true, isAction: true),
        ],
      ),
    );
  }

  Widget _slotBox(String label, {bool isDashed = false, bool isAction = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDashed ? Colors.transparent : AppColors.secondary.withOpacity(0.5),
        border: isDashed ? Border.all(color: Colors.grey.shade300, style: BorderStyle.solid) : null, // Ideal solution would be a custom painter for true dashes
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(
          color: isAction ? AppColors.primary : (isDashed ? Colors.grey : AppColors.primaryDark),
          fontSize: 13,
          fontWeight: isDashed ? FontWeight.normal : FontWeight.bold
      )),
    );
  }
}