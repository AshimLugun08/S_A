import 'package:flutter/material.dart';
import 'package:s_a/const/Modal/schedule_modal.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/endpoint/endpoint.dart';
import 'package:s_a/const/session/session.dart';
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

  // Mapping each Pro ID to their list of weekly schedules
  Map<int, List<ScheduleItem>> _proSchedules = {};

  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }

  // ── API LOGIC ──
  Future<void> _loadTeamData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await UserPref.getUser();
      final int ownerId = userData['userId'] ?? 0;

      final response = await ApiService.fetchProfessionals(ownerId);

      if (mounted && response?.data != null) {
        _professionals = response!.data!;

        // Fetch schedules for all pros in parallel to fill the card previews
        for (var pro in _professionals) {
          if (pro.id != null) {
            final scheduleList = await ApiService.getProfessionalSchedule(pro.id!);
            _proSchedules[pro.id!] = scheduleList;
          }
        }
      }
    } catch (e) {
      debugPrint("💀 Load Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── SCHEDULE EDITOR (ADD/UPDATE) ──
  void _openScheduleEditor(pro_modal.Data pro) {
    String selectedDay = "Monday";
    List<ScheduleItem> currentSchedules = _proSchedules[pro.id] ?? [];
    List<String> selectedSlots = [];

    void syncSlots(String day) {
      var dayData = currentSchedules.firstWhere(
              (s) => s.day == day,
          orElse: () => ScheduleItem(id: 0, day: day, timeSlots: [])
      );
      selectedSlots = List.from(dayData.timeSlots ?? []);
    }

    syncSlots(selectedDay);
    final List<String> presetSlots = ["09:00 AM", "11:00 AM", "01:00 PM", "03:00 PM", "06:00 PM"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Manage Schedule: ${pro.name}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("Select Day", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedDay,
                isExpanded: true,
                items: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                    .map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                onChanged: (val) {
                  setModalState(() {
                    selectedDay = val!;
                    syncSlots(selectedDay);
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text("Available Slots", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: presetSlots.map((slot) {
                  final isSelected = selectedSlots.contains(slot);
                  return FilterChip(
                    label: Text(slot, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    onSelected: (val) {
                      setModalState(() {
                        val ? selectedSlots.add(slot) : selectedSlots.remove(slot);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder()),
                  onPressed: () async {
                    final res = await ApiService.addSchedule(
                        professionalId: pro.id!,
                        day: selectedDay,
                        timeSlots: selectedSlots
                    );

                    if (res?.status == true) {
                      Navigator.pop(ctx);
                      _loadTeamData(); // Refresh UI
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Schedule updated!")));
                    }
                  },
                  child: const Text("Save Schedule", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ── SCHEDULE DETAILS (VIEW) ──
  void _showScheduleDetails(pro_modal.Data pro) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    // This now correctly receives List<ScheduleItem> from the ApiService
    final List<ScheduleItem> schedules = await ApiService.getProfessionalSchedule(pro.id!);

    if (!mounted) return;
    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("MEMBER SCHEDULE", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10)),
                    Text(pro.name ?? "Expert", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 30),
            if (schedules.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: Text("No saved slots.")))
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final dayData = schedules[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dayData.day ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: dayData.timeSlots?.map((slot) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.primary.withOpacity(0.1))),
                              child: Text(slot, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                            )).toList() ?? [],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openScheduleEditor(pro);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("MODIFY SLOTS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildFilterChips(),
            const SizedBox(height: 24),
            ..._professionals.map((pro) => _buildProfessionalCard(pro)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalCard(pro_modal.Data pro) {
    final schedule = _proSchedules[pro.id] ?? [];

    return GestureDetector(
      onTap: () => _showScheduleDetails(pro),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: pro.image != null ? NetworkImage("${ApiEndoint.baseUrl}${pro.image}") : null,
                  child: pro.image == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pro.name ?? "Expert", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(pro.profession ?? "Specialist", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _openScheduleEditor(pro),
                  icon: const Icon(Icons.calendar_month_outlined, size: 20, color: AppColors.primary),
                ),
              ],
            ),
            if (schedule.isNotEmpty) ...[
              const Divider(height: 30),
              const Text("WEEKLY SUMMARY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: schedule.take(3).map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                  child: Text("${s.day}: ${s.timeSlots?.length ?? 0} slots",
                      style: const TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold)),
                )).toList(),
              ),
            ],
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(pro.phone ?? "No phone", style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
                const Text("ACTIVE", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ── APPBAR, STATS, SEARCH ──
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text("Team Management", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard("TOTAL", "${_professionals.length}", Colors.black)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard("ON JOB", "0", Colors.blue)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard("AVAIL", "${_professionals.length}", Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search team...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          bool sel = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
              alignment: Alignment.center,
              child: Text(_filters[index], style: TextStyle(color: sel ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}