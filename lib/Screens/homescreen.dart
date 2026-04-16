import 'package:flutter/material.dart';
import 'package:s_a/Screens/IndivudelaServices.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
// Aliasing to prevent "Data" class name conflicts
import 'package:s_a/const/Modal/categoryListModal.dart' as cat;
import 'package:s_a/const/Modal/SubcategoryListModal.dart' as sub;

class CategoryGroup {
  final cat.Data category;
  final List<sub.Data> subcategories;

  CategoryGroup({required this.category, required this.subcategories});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CategoryGroup> _categoryGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  // --- 2. API LOGIC ---
  Future<void> _loadHomeData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Step A: Fetch main Categories
      final categoryResponse = await ApiService.fetchCategoryList();

      if (categoryResponse != null && categoryResponse.data != null) {
        // Step B: Fetch subcategories in parallel for all categories
        final List<CategoryGroup> tempGroups = await Future.wait(
          categoryResponse.data!.map((categoryItem) async {
            if (categoryItem.id != null) {
              final subResponse = await ApiService.fetchSubcategories(
                categoryId: categoryItem.id!,
              );

              return CategoryGroup(
                category: categoryItem, // Pass the whole object
                subcategories: subResponse?.data ?? [],
              );
            } else {
              return CategoryGroup(
                  category: categoryItem,
                  subcategories: []
              );
            }
          }),
        );

        if (mounted) {
          setState(() {
            // Only display categories that actually have sub-services
            _categoryGroups = tempGroups.where((g) => g.subcategories.isNotEmpty).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("🚨 Home Data Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHomeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildPromoBanner(),

                // --- 3. DYNAMIC CONTENT ---
                _isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Center(child: CircularProgressIndicator()),
                )
                    : _categoryGroups.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text("No services available right now."),
                )
                    : Column(
                  children: _categoryGroups.map((group) {
                    return _buildDynamicCategorySection(
                      group.category.name ?? "Service",
                      group.subcategories,
                    );
                  }).toList(),
                ),

                _buildFooterOffer(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 4. UI COMPONENTS ---

  Widget _buildDynamicCategorySection(String title, List<sub.Data> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Text("View All", style: TextStyle(color: Colors.white, fontSize: 10)),
              )
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return InkWell(
                  onTap: () => {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ServiceListScreen(subCategoryId: item.subcategoryId ?? 0, title: item.name ?? "",)))
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: SizedBox(
                      width: 75,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: (item.images != null && item.images!.isNotEmpty)
                                ? Image.network(
                              // Make sure your BaseURL is prefixed if the API returns relative paths
                              "${item.images![0]}",
                              height: 40, width: 40, fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            )
                                : const Icon(Icons.category, size: 40, color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.name ?? "Unnamed",
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white), // Using icon as fallback for missing local assets
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Hello!", style: TextStyle(color: Colors.grey, fontSize: 14)),
              const Text("Manvi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 12),
                    Text(" Ranchi ▾", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
          const Spacer(),
          _iconButton(Icons.notifications_none_outlined),
          const SizedBox(width: 10),
          _iconButton(Icons.chat_bubble_outline),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
      child: Icon(icon, color: Colors.black54),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search for Services",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 50, width: 80,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.tune, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 140, width: double.infinity,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(15)),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "Let's make a package\njust for you!",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
        ),
      ),
    );
  }

  Widget _buildFooterOffer() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Signup & get 20% OFF", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("on your first service", style: TextStyle(fontSize: 12)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
            ),
            child: const Text("Signup Now", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}