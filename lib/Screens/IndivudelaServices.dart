import 'package:flutter/material.dart';
import 'package:s_a/Screens/ServiceDetailsScreen.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/Modal/CatServiceListModal.dart' as cat_service;
import 'package:s_a/const/endpoint/endpoint.dart';

class ServiceListScreen extends StatefulWidget {
  final int subCategoryId; // The ID passed from the previous screen
  final String title;      // The title to show in the AppBar

  const ServiceListScreen({
    super.key,
    required this.subCategoryId,
    this.title = "Services"
  });

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}




class _ServiceListScreenState extends State<ServiceListScreen> {
  // Changed type to match your CatServiceListModal Data class
  List<cat_service.Data> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  // ── 1. FETCH DATA USING THE NEW METHOD ──
  Future<void> _fetchServices() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Calling the specific method you just created
      final response = await ApiService.fetchCatServiceList(widget.subCategoryId);

      if (mounted) {
        setState(() {
          // Use .cast to force the list items into the correct type
          _services = response?.data?.cast<cat_service.Data>() ?? <cat_service.Data>[];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("🚨 Error fetching services: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        onRefresh: _fetchServices,
        child: _services.isEmpty
            ? const Center(child: Text("No services found in this category."))
            : ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            return _buildServiceCard(context, _services[index]);
          },
        ),
      ),
    );
  }

  // ── 2. INDIVIDUAL SERVICE CARD ──
  Widget _buildServiceCard(BuildContext context, cat_service.Data service) {
    return InkWell(
      onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceDetailScreen(serviceId: service.id ?? 0 ,))
      )},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [

            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // --- DYNAMIC IMAGE SECTION ---
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: (service.image != null && service.image!.isNotEmpty)
                  ? Image.network(
                // Combine Base URL + Relative path
                "${ApiEndoint.baseUrlImg}${service.image}",
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                // Handle cases where the URL is valid but the image fails to load
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                // Optional: Add a loading spinner while fetching
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 90, height: 90,
                    color: AppColors.background,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
              )
                  : _buildPlaceholderImage(), // Fallback if string is null/empty
            ),

            const SizedBox(width: 15),

            // --- SERVICE DETAILS ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name ?? "Unnamed Service",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3A8C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description ?? "Quality service guaranteed",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "₹599",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

// --- PLACEHOLDER HELPER ---
  Widget _buildPlaceholderImage() {
    return Container(
      width: 90,
      height: 90,
      color: AppColors.background,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 30),
    );
  }
}