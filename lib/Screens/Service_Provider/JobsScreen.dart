import 'package:flutter/material.dart';
import 'package:s_a/Screens/Service_Provider/bookingdetails.dart';
import 'package:s_a/const/Modal/owmerBookingListModal.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/session/session.dart';

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});

  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen> {
  // ── DATA STATE ──
  int _selectedTab = 0; // 0: Upcoming, 1: Ongoing, 2: Completed
  bool _isLoading = true;
  List<Data> _allJobs = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // ── LOAD DATA FROM SESSION & API ──
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await UserPref.getUser();
      final int ownerId = userData['userId'] ?? 0;

      if (ownerId == 0) {
        setState(() { _errorMessage = "Session Expired"; _isLoading = false; });
        return;
      }

      final response = await ApiService.fetchOwnerBookings(ownerId);

      if (mounted) {
        setState(() {
          _allJobs = response?.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() { _errorMessage = "Connection Error"; _isLoading = false; });
    }
  }

  // ── HANDLE STATUS UPDATES (Cancel/Start/Finish) ──
  Future<void> _changeJobStatus(int bookingId, String status) async {
    // Show quick loading overlay if needed, or just set state
    bool success = await ApiService.updateBookingStatus(bookingId:  bookingId ,status:  status);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Job updated to $status"), backgroundColor: Colors.green)
      );
      _loadInitialData(); // Reload list to move job to correct tab
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Update failed"), backgroundColor: Colors.red)
      );
    }
  }

  // ── FILTER DATA FOR TABS ──
  List<Data> _getFilteredList() {
    if (_selectedTab == 0) return _allJobs.where((j) => j.status == "pending").toList();
    if (_selectedTab == 1) return _allJobs.where((j) => j.status == "accepted").toList();
    return _allJobs.where((j) => j.status == "completed" || j.status == "cancelled").toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedJobs = _getFilteredList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        onRefresh: _loadInitialData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildCustomTabBar(),
              const SizedBox(height: 30),
              _buildHeader(displayedJobs.length),
              const SizedBox(height: 20),

              if (displayedJobs.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedJobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _buildDynamicJobCard(displayedJobs[index]),
                ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ── DYNAMIC JOB CARD ──
// ... existing imports ...

  // ── DYNAMIC JOB CARD (Updated with Navigation) ──
  Widget _buildDynamicJobCard(Data job) {
    bool isOngoing = job.status == "accepted";
    bool isCompleted = job.status == "completed" || job.status == "cancelled";

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      // ─── NAVIGATE TO DETAIL PAGE ───
      onTap: () {
        if (job.bookingId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailPage(bookingId: job.bookingId!),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isOngoing ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.secondary,
                    child: Text(job.professionalName?[0] ?? "P", style: const TextStyle(color: AppColors.primary))
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.professionalName ?? "Staff Assigned", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(job.serviceName ?? "Service", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                _buildStatusBadge(
                    job.status?.toUpperCase() ?? "NEW",
                    isOngoing ? AppColors.primary : AppColors.secondary,
                    isOngoing ? Colors.white : AppColors.primary
                ),
              ],
            ),
            const Divider(height: 30),
            _jobDetailRow(Icons.access_time, "Time Slot", "${job.bookingDate} | ${job.bookingTime}"),
            _jobDetailRow(Icons.location_on_outlined, "Address", job.address ?? "No address"),
            const SizedBox(height: 20),

            if (!isCompleted)
              Row(
                children: [
                  // Left Button (Cancel or Navigate)
                  Expanded(
                      child: _actionButton(
                          isOngoing ? "Navigate" : "Cancel",
                          Colors.grey.shade100,
                          isOngoing ? Colors.black : Colors.red,
                          onTap: () {
                            if (isOngoing) {
                              // Logic for Map navigation if you have it
                            } else {
                              _changeJobStatus(job.bookingId!, "cancelled");
                            }
                          }
                      )
                  ),
                  const SizedBox(width: 12),
                  // Right Button (Start or Finish)
                  Expanded(
                      child: _actionButton(
                          isOngoing ? "Finish Job" : "Start Job",
                          AppColors.primary,
                          Colors.white,
                          onTap: () => _changeJobStatus(job.bookingId!, isOngoing ? "completed" : "accepted")
                      )
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  // ── UI HELPERS ──
  Widget _buildHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("WORKLIST", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
            Text(_selectedTab == 0 ? "Upcoming" : _selectedTab == 1 ? "Ongoing" : "History",
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ],
        ),
        _buildStatusBadge("$count Jobs", AppColors.secondary, AppColors.primary),
      ],
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          _tabItem("Upcoming", 0),
          _tabItem("Ongoing", 1),
          _tabItem("History", 2),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isActive ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _jobDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text("$label: $value", style: const TextStyle(fontSize: 12, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color bg, Color text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white, elevation: 0,
      title: const Text("Manage Jobs", style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.grey), onPressed: _loadInitialData)],
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 100),
      child: Center(child: Text("No jobs found in this category", style: TextStyle(color: Colors.grey))),
    );
  }
}