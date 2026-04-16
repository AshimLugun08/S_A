import 'package:flutter/material.dart';
import 'package:s_a/Screens/ChooseProffectional.dart';
import 'package:s_a/const/Modal/serviceDetailModal.dart';
import 'package:s_a/const/Modal/reviewListModal.dart' as rev_modal;
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/endpoint/endpoint.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  BusDetailsModal? _serviceDetails;
  List<rev_modal.Data> _reviews = [];
  bool _isLoading = true;
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── 1. CALCULATION LOGIC ──
  double _getAverageRating() {
    if (_reviews.isEmpty) return 0.0;
    double total = 0;
    for (var review in _reviews) {
      total += (review.rating ?? 0).toDouble();
    }
    return total / _reviews.length;
  }

  // ── 2. API CALLS ──
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.fetchServiceDetails(widget.serviceId);

      if (mounted && result != null) {
        setState(() {
          _serviceDetails = result;
          _isLoading = false;
        });

        // Note: Assuming reviews are fetched via ownerId as per previous ApiService logic
        if (result.data?.ownerId != null) {
          _loadReviews(widget.serviceId);
        }
      }
    } catch (e) {
      debugPrint("🚨 Error loading service details: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReviews(int ownerId) async {
    setState(() => _isLoadingReviews = true);
    try {
      final revResult = await ApiService.fetchReviews(ownerId);
      if (mounted && revResult != null) {
        setState(() {
          _reviews = revResult.data ?? [];
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint("🚨 Error loading reviews: $e");
      setState(() => _isLoadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _serviceDetails?.data;
    double averageRating = _getAverageRating();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          data?.name ?? "Service Details",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : data == null
          ? const Center(child: Text("Service details not found."))
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageHeader(data.image),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name ?? "Unnamed Service",
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2E3A8C)),
                        ),
                        Container(margin: const EdgeInsets.symmetric(vertical: 4), height: 3, width: 45, color: AppColors.primary.withOpacity(0.4)),
                        const SizedBox(height: 10),
                        Text(data.description ?? "No description available.", style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4)),

                        const SizedBox(height: 25),

                        // ── PRICING & DYNAMIC RATING ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Pricing", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    Text("₹${data.price ?? '0'}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 4),
                                    const Text("onwards", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("Avg. Rating", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.orange, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      averageRating == 0.0 ? "N/A" : averageRating.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    Text(" (${_reviews.length})", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 40),
                      ],
                    ),
                  ),

                  _buildCrossSellSection(data.subcategoryName ?? "Related"),
                  _buildReviewSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomButton(data.ownerId ?? 0, widget.serviceId),
        ],
      ),
    );
  }

  // ── WIDGET: REVIEWS SECTION ──
  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Customer Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          if (_isLoadingReviews)
            const Center(child: CircularProgressIndicator())
          else if (_reviews.isEmpty)
            const Text("No reviews yet.", style: TextStyle(color: Colors.grey, fontSize: 13))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length > 3 ? 3 : _reviews.length, // Show top 3 reviews initially
              separatorBuilder: (context, index) => const Divider(height: 30),
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return _buildReviewCard(review);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(rev_modal.Data review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(review.customerName ?? "Anonymous", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            _buildStarIcons(review.rating ?? 0),
          ],
        ),
        const SizedBox(height: 8),
        Text(review.comment ?? "No comment.", style: const TextStyle(color: Colors.black87, fontSize: 13)),
      ],
    );
  }

  Widget _buildStarIcons(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.orange, size: 14);
      }),
    );
  }

  Widget _buildImageHeader(String? imageUrl) {
    return Container(
      height: 250, width: double.infinity, margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.grey[100]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: imageUrl != null
            ? Image.network("${ApiEndoint.baseUrlImg}$imageUrl", fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey))
            : const Icon(Icons.image, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildCrossSellSection(String subName) {
    return Container(
      width: double.infinity, color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("More from $subName", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          const Text("Explore similar treatments in this category.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBottomButton(int ownerId, int servidId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30), color: Colors.white,
      child: SizedBox(
        width: double.infinity, height: 55,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChooseProfessionalScreen(servidId: servidId, ownerId: ownerId)));
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          child: const Text("Proceed", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}