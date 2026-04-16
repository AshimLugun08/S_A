import 'package:flutter/material.dart';
import 'package:s_a/Screens/LoginScreen.dart';
import 'package:s_a/Screens/Service_Provider/AddMemberScreen.dart';
import 'package:s_a/Screens/Service_Provider/EditProfilePage.dart';
import 'package:s_a/Screens/Service_Provider/Myteams.dart';
import 'package:s_a/const/Modal/ownerReviewListaModal.dart';
import 'package:s_a/const/Modal/reviewListModal.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/session/session.dart';
// Ensure these are imported
class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  // ── 1. STATE VARIABLES ──
  Map<String, dynamic> _userData = {};
  List<ReviewData> _reviews = []; // ✅ Dynamic Review List
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAndSyncProfile();
  }

  // ── 2. DATA FETCHING LOGIC ──
  Future<void> _loadAndSyncProfile() async {
    final localData = await UserPref.getUser();
    setState(() => _userData = localData);

    try {
      final int userId = localData['userId'] ?? 0;

      if (userId != 0) {
        // A. Profile Sync
        final serverResponse = await ApiService.fetchProfile(userId);
        if (serverResponse != null && serverResponse.status == true) {
          if (mounted) {
            setState(() {
              _userData = {
                "userId": serverResponse.data?.userId,
                "name": serverResponse.data?.name,
                "email": serverResponse.data?.email,
                "phone": serverResponse.data?.phone,
                "role": serverResponse.data?.role,
                "profile_image": serverResponse.data?.profileImage,
              };
            });
          }
        }

        // B. ✅ Fetch Reviews from Server
        final reviewResponse = await ApiService.ownerfetchReviews(userId);
        // ✅ Corrected Logic in _loadAndSyncProfile
        if (reviewResponse != null && reviewResponse.status == true) {
          if (mounted) {
            setState(() {
              // Direct assign karein, cast ki zarurat nahi
              _reviews = reviewResponse.data ?? [];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("💀 Profile/Review Sync Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: _isLoading && _userData.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        onRefresh: _loadAndSyncProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildProfessionalActionButtons(context),
              const SizedBox(height: 30),
              const _StatsGrid(),
              const SizedBox(height: 24),
              _buildOverallRatingCard(),
              const SizedBox(height: 16),
              _buildRatingBreakdown(),
              const SizedBox(height: 30),
              const _ClientFeedbackHeader(),
              const SizedBox(height: 16),

              // ── 3. DYNAMIC REVIEWS LIST ──
              _reviews.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No feedback received yet.", style: TextStyle(color: Colors.grey)),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  final review = _reviews[index];
                  return _buildReviewCard(
                    name: review.customerName ?? "Anonymous",
                    role: review.serviceName ?? "General Service",

                    comment: review.comment ?? "No comment provided.",
                    initials: (review.customerName ?? "U").substring(0, 1).toUpperCase(),
                    avatarColor: Colors.blue.shade100,
                    rating: review.rating ?? 5, // Pass dynamic rating
                  );
                },
              ),

              const SizedBox(height: 10),
              if (_reviews.isNotEmpty)
                TextButton.icon(
                  onPressed: () {},
                  icon: Text("View all ${_reviews.length} reviews",
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  label: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                ),
              const SizedBox(height: 100),
            ],
          ),
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
          onPressed: () async {
            await UserPref.logout();
            if (context.mounted) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            }
          },
          icon: Image.asset("assets/icons/switch.png", height: 24),
        ),
      ],
    );
  }

  // ── PROFILE HEADER ──
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (_userData['profile_image'] != null && _userData['profile_image'] != "")
                  ? NetworkImage(_userData['profile_image'])
                  : const AssetImage('assets/images/user.png') as ImageProvider,
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(_userData['name'] ?? "Loading...", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        Text(_userData['role']?.toString().toUpperCase() ?? "PRO", style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: const Text("Top Rated Pro", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // ── ACTION BUTTONS ──
  Widget _buildProfessionalActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionItem("assets/icons/developers.png", "My Team", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TeamManagementPage()))),
        _actionItem("assets/icons/worker.png", "Add Member", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProfessionalPage()))),
        _actionItem("assets/icons/customer-service.png", "Support", onTap: () {}),
      ],
    );
  }

  Widget _actionItem(String imageAssetPath, String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 52, height: 52, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.divider), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
            child: ClipOval(child: Image.asset(imageAssetPath, fit: BoxFit.cover)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ── REVIEW CARD ──
  Widget _buildReviewCard({
    required String name,
    required String role,

    required String comment,
    required String initials,
    required Color avatarColor,
    int rating = 5, // Added rating support
  }) {
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(role, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ]),
              ),
              // Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)), child: Text(date, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)))
            ],
          ),
          const SizedBox(height: 12),
          Row(children: List.generate(5, (index) => Icon(Icons.star, color: index < rating ? AppColors.primary : Colors.grey.shade300, size: 16))),
          const SizedBox(height: 10),
          Text(comment, style: const TextStyle(color: AppColors.textPrimary, height: 1.4, fontSize: 13)),
        ],
      ),
    );
  }
  // Average nikalne ke liye
  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    double sum = _reviews.fold(0, (tot, rev) => tot + (rev.rating ?? 0));
    return sum / _reviews.length;
  }

  // (Stats, Ratings logic remains same as before)
  Widget _buildOverallRatingCard() {

    double avg = averageRating; // Function call
    int total = _reviews.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          const Text("OVERALL RATING",
              style: TextStyle(letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),

          // Dynamic Rating Number
          Text(avg.toStringAsFixed(1),
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: AppColors.primary)),

          // Dynamic Stars Logic
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              if (index < avg.floor()) {
                return const Icon(Icons.star, color: AppColors.primary, size: 28);
              } else if (index < avg && (avg - avg.floor() >= 0.5)) {
                return const Icon(Icons.star_half, color: AppColors.primary, size: 28);
              } else {
                return Icon(Icons.star, color: Colors.grey.shade300, size: 28);
              }
            }),
          ),

          const SizedBox(height: 8),

          // Dynamic Review Count
          Text("Based on $total client reviews",
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
  Widget _buildRatingBreakdown() { return Container( padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)), child: Column( children: [ _ratingRow("5 Star", 0.85, "85%"), _ratingRow("4 Star", 0.12, "12%"), _ratingRow("3 Star", 0.02, "2%"), _ratingRow("2 Star", 0.01, "1%"), _ratingRow("1 Star", 0.00, "0%"), ], ), ); }
  Widget _ratingRow(String label, double val, String percent) { return Padding( padding: const EdgeInsets.symmetric(vertical: 4), child: Row( children: [ SizedBox(width: 45, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: val, minHeight: 8, backgroundColor: AppColors.background, color: AppColors.primaryLight))), const SizedBox(width: 12), Text(percent, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), ], ), ); }
}

// Stats & Feedback Header widgets remain unchanged...
class _StatsGrid extends StatelessWidget { const _StatsGrid(); @override Widget build(BuildContext context) { return GridView.count( shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.6, children: [ _statItem("99%", "On-time Completion"), _statItem("1hr", "Avg Response Time"), _statItem("42", "Repeat Clients"), _statItem("Top", "Marketplace Pro"), ], ); } Widget _statItem(String val, String label) { return Container( decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(24)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark)), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)), ]), ); } }
class _ClientFeedbackHeader extends StatelessWidget { const _ClientFeedbackHeader(); @override Widget build(BuildContext context) { return Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ const Text("Client\nFeedback", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.1)), Row(children: [_filterChip("Latest", true), const SizedBox(width: 8), _filterChip("Highest Rated", false)]), ], ); } Widget _filterChip(String label, bool isSelected) { return Container( padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: isSelected ? const Color(0xFFE8EDF2) : Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? AppColors.textPrimary : AppColors.textSecondary)), ); } }