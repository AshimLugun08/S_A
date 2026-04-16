import 'package:flutter/material.dart';
import 'package:s_a/Screens/ChooseProffectional.dart';
import 'package:s_a/const/Modal/serviceDetailModal.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/endpoint/endpoint.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId; // Accept the ID to fetch specific details

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  BusDetailsModal? _serviceDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── 1. API CALL ──
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.fetchServiceDetails(widget.serviceId);
      if (mounted) {
        setState(() {
          _serviceDetails = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("🚨 Error loading service details: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Shorthand for easier data access
    final data = _serviceDetails?.data;

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
                  // ── 2. DYNAMIC IMAGE ──
                  _buildImageHeader(data.image),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 3. DYNAMIC TITLE & DESCRIPTION ──
                        Text(
                          data.name ?? "Unnamed Service",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3A8C),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          height: 3, width: 45,
                          color: AppColors.primary.withOpacity(0.4),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data.description ?? "No description available for this service.",
                          style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                        ),

                        const SizedBox(height: 25),

                        // ── 4. DYNAMIC PRICING ──
                        const Text("Pricing", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        const Divider(thickness: 1),
                        Row(
                          children: [
                            Text("₹${data.price ?? '0'}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Text("onwards", style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── 5. STATIC RATING & DURATION (Or add to API later) ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Rating", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Row(
                                  children: const [
                                    Icon(Icons.star, color: Colors.orange, size: 20),
                                    SizedBox(width: 4),
                                    Text("4.8 (23K)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Duration", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                const Text("45 mins", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),
                        _buildBullet("For all skin types. Tested process."),
                        _buildBullet("Includes consultation with specialist."),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  // ── 6. DYNAMIC CATEGORY INFO ──
                  _buildCrossSellSection(data.subcategoryName ?? "Related"),
                ],
              ),
            ),
          ),

          // ── 7. BOTTOM PROCEED BUTTON ──
          _buildBottomButton(data.ownerId ?? 0 , widget.serviceId),
        ],
      ),
    );
  }

  // ── WIDGET: IMAGE HEADER ──
  Widget _buildImageHeader(String? imageUrl) {
    return Container(
      height: 250,
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: imageUrl != null
            ? Image.network(
          "${ApiEndoint.baseUrlImg}$imageUrl",
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        )
            : const Icon(Icons.image, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.circle, size: 6, color: Colors.black54)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildCrossSellSection(String subName) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
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

  Widget _buildBottomButton(int ownerId , int servidId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          // onPressed does not take arguments
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChooseProfessionalScreen(
                  servidId: servidId ,
                  ownerId: ownerId, // Use the variable passed to the parent function
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text(
            "Proceed",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}