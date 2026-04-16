import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:s_a/const/Modal/categoryListModal.dart' as cat;
import 'package:s_a/const/Modal/SubcategoryListModal.dart' as sub;
import 'package:s_a/const/Modal/OwnerServiceListModal.dart' as owner;
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/session/session.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  List<File> _selectedImages = [];
  bool _isCreatingService = false;

  List<cat.Data> _categories = [];
  int? _selectedCategoryId;
  bool _isFetchingCategories = false;

  List<sub.Data> _subcategories = [];
  int? _selectedSubCategoryId;
  bool _isFetchingSubCategories = false;

  List<owner.Data> _myServices = [];
  bool _isLoadingMyServices = false;

  // --- NEW EARNINGS STATE ---
  double _totalEarnings = 0.0;
  String _ownerDisplayName = "Pro";

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    _loadCategories();
    _fetchMyServices();
    _fetchEarnings(); // Fresh earnings fetch
  }

  // --- 1. FETCH EARNINGS ---
  Future<void> _fetchEarnings() async {
    try {
      final userData = await UserPref.getUser();
      final ownerId = userData['userId'] ?? 0;

      if (ownerId != 0) {
        final result = await ApiService.fetchOwnerEarnings(ownerId);
        if (result != null && result.status == true) {
          setState(() {
            _totalEarnings = result.totalEarning ?? 0.0;
            _ownerDisplayName = result.ownerName ?? "Pro";
          });
        }
      }
    } catch (e) {
      debugPrint("Earning Sync Error: $e");
    }
  }

  Future<void> _handleDeleteService(int serviceId) async {
    // Show Loading
    setState(() => _isLoadingMyServices = true);

    final response = await ApiService().deleteService(serviceId);

    if (response != null && response['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Deleted!"), backgroundColor: Colors.green),
      );
      _fetchMyServices(); // List refresh karein
    } else {
      setState(() => _isLoadingMyServices = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete service"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _fetchMyServices() async {
    if (!mounted) return;
    setState(() => _isLoadingMyServices = true);
    try {
      final userData = await UserPref.getUser();
      final ownerId = userData['userId'] ?? 0;

      final response = await ApiService().getOwnerServices(ownerId: ownerId);
      if (response != null && response.status == true) {
        final List<owner.Data> services = response.data?.map<owner.Data>((item) {
          return owner.Data.fromJson(item.toJson());
        }).toList() ?? [];
        setState(() => _myServices = services);
      }
    } catch (e) {
      debugPrint("Error fetching owner services: $e");
    } finally {
      if (mounted) setState(() => _isLoadingMyServices = false);
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isFetchingCategories = true);
    try {
      final response = await ApiService.fetchCategoryList();
      if (response != null && response.status == true) {
        setState(() => _categories = response.data ?? []);
      }
    } catch (e) {
      debugPrint("Category Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isFetchingCategories = false);
    }
  }

  Future<void> _loadSubCategories(int categoryId, StateSetter setModalState) async {
    setModalState(() => _isFetchingSubCategories = true);
    try {
      final response = await ApiService.fetchSubcategories(categoryId: categoryId);
      if (response != null && response.status == true) {
        setModalState(() {
          _subcategories = response.data ?? [];
          _selectedSubCategoryId = null;
        });
      }
    } catch (e) {
      debugPrint("Subcategory Fetch Error: $e");
    } finally {
      if (mounted) setModalState(() => _isFetchingSubCategories = false);
    }
  }

  Future<void> _pickImages(StateSetter setModalState) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty) {
      setModalState(() {
        _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
      });
    }
  }

  Future<void> _handleCreateService(StateSetter setModalState) async {
    final String title = _titleController.text.trim();
    final String price = _priceController.text.trim();

    if (title.isEmpty || price.isEmpty || _selectedSubCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title, Price, and Subcategory are required")));
      return;
    }

    setModalState(() => _isCreatingService = true);
    try {
      final userData = await UserPref.getUser();
      final ownerId = userData['userId'] ?? 0;

      final response = await ApiService().addService(
        name: title,
        description: _descController.text.trim(),
        category: _selectedCategoryId,
        subcategory: _selectedSubCategoryId,
        ownerId: ownerId,
        amount: price,
        images: _selectedImages,
      );

      if (response != null && response.status == true) {
        Navigator.pop(context);
        _clearFields();
        _fetchMyServices();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Service Created Successfully!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint("Submit Error: $e");
    } finally {
      if (mounted) setModalState(() => _isCreatingService = false);
    }
  }

  void _clearFields() {
    _titleController.clear();
    _priceController.clear();
    _descController.clear();
    _selectedImages = [];
    _selectedCategoryId = null;
    _selectedSubCategoryId = null;
    _subcategories = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData, // Now refreshes services AND earnings
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Good morning,\n$_ownerDisplayName.", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
              const SizedBox(height: 25),
              _buildEarningsCard(),
              const SizedBox(height: 16),
              _buildPerformanceCard(),
              const SizedBox(height: 30),
              const Text("My Services", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _isLoadingMyServices
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  : _myServices.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _myServices.length,
                itemBuilder: (context, index) {
                  final service = _myServices[index];
                  return _buildJobCard(
                    title: service.name ?? "Unnamed",
                    category: service.category ?? "Service",
                    status: service.isActive == true ? "ACTIVE" : "INACTIVE", // Status wapas aa gaya
                    price: "₹${service.amount}",
                    icon: Icons.auto_awesome_mosaic_outlined,
                    onEdit: () {
                      // Navigator.push to Edit Page
                    },
                    onDelete: () => _confirmDelete(service.serviceId ?? 0),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


  // ─── DELETE CONFIRMATION DIALOG ───
  void _confirmDelete(int serviceId) {
    showDialog(
      context: context,
      barrierDismissible: false, // User ko button click karna hi hoga
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text("Delete Service?", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            "Kya aap waqai is service ko delete karna chahte hain? Delete hone ke baad ye wapas nahi aayegi.",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            // CANCEL BUTTON
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            // DELETE BUTTON
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Dialog band karein
                  _handleDeleteService(serviceId); // API call trigger karein
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJobCard({
    required String title,
    required String category,
    required String status, // Wapas String status le rahe hain
    required String price,
    required IconData icon,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    bool isActive = status.toUpperCase() == "ACTIVE";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── ICON WITH LIGHT BG ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 15),

              // ── TITLE & CATEGORY ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // ── STATUS TAG (AS REQUESTED) ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── CREATIVE REPLACEMENT FOR BUTTON (ACTION BAR) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price Display
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Service Price", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary)),
                ],
              ),

              // Quick Actions Group
              Row(
                children: [

                  const SizedBox(width: 12),
                  // Delete Action
                  _buildCircularAction(
                    icon: Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

// ── HELPER FOR CREATIVE ACTION BUTTONS ──
  Widget _buildCircularAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

// ── HELPER FOR MINI CHIPS ──
  Widget _buildMiniChip({required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
  // --- REUSABLE WIDGETS ---

  Widget _buildEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Earnings", style: TextStyle(color: Colors.grey)),
          Text("₹${_totalEarnings.toStringAsFixed(2)}", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  // Other UI helpers remain the same...
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent, elevation: 0,
      leading: const Padding(padding: EdgeInsets.all(8.0), child: CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a'))),
      title: const Text("Provider Console", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // Deep Blue/Purple Gradient
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_outlined, color: Colors.white, size: 28),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Top Rated Professional",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("98% Job Completion Rate",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
  Widget _primaryButton(String label, VoidCallback onTap) {
    return SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(label, style: const TextStyle(color: Colors.white))));
  }

  Widget _buildEmptyState() {
    return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Column(children: [Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey), SizedBox(height: 10), Text("No services added yet.", style: TextStyle(color: Colors.grey))])));
  }

  // Add Service Dialog & fields...
  void _showAddServiceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                const Text("Add New Service", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text("Service Images", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 10),
                _buildImagePickerRow(setModalState),
                const SizedBox(height: 20),
                _buildTextField(_titleController, "Service Title", Icons.work_outline),
                const SizedBox(height: 15),
                _buildCategoryDropdown(setModalState),
                const SizedBox(height: 15),
                _buildSubCategoryDropdown(setModalState),
                const SizedBox(height: 15),
                _buildTextField(_priceController, "Base Price (₹)", Icons.attach_money, keyboard: TextInputType.number),
                const SizedBox(height: 15),
                _buildTextField(_descController, "Detailed Description", Icons.description_outlined, maxLines: 3),
                const SizedBox(height: 30),
                _buildSubmitButton(setModalState),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.searchBar, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonFormField<int>(
        value: _selectedCategoryId,
        hint: Text(_isFetchingCategories ? "Loading..." : "Select Category", style: const TextStyle(fontSize: 14)),
        isExpanded: true,
        decoration: const InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary, size: 20)),
        items: _categories.map((catItem) => DropdownMenuItem<int>(value: catItem.id, child: Text(catItem.name ?? "Unknown", style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: (value) {
          if (value != null) {
            setModalState(() => _selectedCategoryId = value);
            _loadSubCategories(value, setModalState);
          }
        },
      ),
    );
  }

  Widget _buildSubCategoryDropdown(StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.searchBar, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonFormField<int>(
        value: _selectedSubCategoryId,
        disabledHint: const Text("Select category first", style: TextStyle(fontSize: 14)),
        hint: Text(_isFetchingSubCategories ? "Loading..." : "Select Subcategory", style: const TextStyle(fontSize: 14)),
        isExpanded: true,
        decoration: const InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.subdirectory_arrow_right, color: AppColors.primary, size: 20)),
        items: _subcategories.map((subItem) => DropdownMenuItem<int>(value: subItem.subcategoryId, child: Text(subItem.name ?? "Unknown", style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: _selectedCategoryId == null ? null : (value) => setModalState(() => _selectedSubCategoryId = value),
      ),
    );
  }

  Widget _buildImagePickerRow(StateSetter setModalState) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length + 1,
        itemBuilder: (context, index) {
          if (index == _selectedImages.length) {
            return GestureDetector(
              onTap: () => _pickImages(setModalState),
              child: Container(
                width: 100, margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
                child: const Icon(Icons.add_a_photo, color: AppColors.primary),
              ),
            );
          }
          return Stack(
            children: [
              Container(
                width: 100, margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), image: DecorationImage(image: FileImage(_selectedImages[index]), fit: BoxFit.cover)),
              ),
              Positioned(right: 5, top: 5, child: GestureDetector(onTap: () => setModalState(() => _selectedImages.removeAt(index)), child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 14, color: Colors.white))))
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton(StateSetter setModalState) {
    return SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _isCreatingService ? null : () => _handleCreateService(setModalState), style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _isCreatingService ? const CircularProgressIndicator(color: Colors.white) : const Text("Create Service", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller, maxLines: maxLines, keyboardType: keyboard,
      decoration: InputDecoration(prefixIcon: Icon(icon, color: AppColors.primary, size: 20), hintText: hint, filled: true, fillColor: AppColors.searchBar, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    );
  }
}