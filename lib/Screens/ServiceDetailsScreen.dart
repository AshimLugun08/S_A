import 'package:flutter/material.dart';
import 'package:s_a/Screens/ChooseProffectional.dart';
import 'package:s_a/const/color/colors.dart'; // Ensure this matches your project structure

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── DYNAMIC ASSETS ──
  final List<String> sliderImages = [
    'assets/images/ss1.jpg',
    'assets/images/ss2.jpg',
    'assets/images/ss3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ── 1. APP BAR ──
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_circle_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Diamond Facial",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 2. IMAGE CAROUSEL ──
                  _buildImageSlider(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 3. TITLE & DESCRIPTION ──
                        const Text(
                          "Diamond Facial",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3A8C),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          height: 3,
                          width: 45,
                          color: AppColors.primary.withOpacity(0.4),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Diamond Facial is a luxurious skin treatment that gently exfoliates the skin using diamond dust to remove dead cells, improve blood circulation, and reveal a brighter, smoother, and youthful glow.",
                          style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                        ),

                        const SizedBox(height: 25),

                        // ── 4. PRICING SECTION ──
                        const Text("Pricing", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        const Divider(thickness: 1),
                        Row(
                          children: [
                            const Text("₹1299", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Text("onwards", style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── 5. RATING & DURATION ──
                        const Text("Rating", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 20),
                            const SizedBox(width: 4),
                            const Text("4.8 (23K)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text("Duration", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        const Text("45 mins", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                        const SizedBox(height: 25),

                        // ── 6. BULLET POINTS ──
                        _buildBullet("For all skin types. Lorem ipsum mask"),
                        _buildBullet("6-stem process. Including 10-mins massage"),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  // ── 7. MORE SERVICES (Dark Grey Section) ──
                  _buildCrossSellSection(),
                ],
              ),
            ),
          ),

          // ── 8. BOTTOM PROCEED BUTTON ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ChooseProfessionalScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text(
                  "Proceed",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── WIDGET: IMAGE SLIDER ──
  Widget _buildImageSlider() {
    return Column(
      children: [
        Container(
          height: 230,
          margin: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemCount: sliderImages.length,
              itemBuilder: (context, index) => Image.asset(sliderImages[index], fit: BoxFit.cover),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            sliderImages.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 10, width: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.grey : Colors.grey.shade300,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── WIDGET: BULLET POINTS ──
  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87))),
        ],
      ),
    );
  }

  // ── WIDGET: DARK CROSS-SELL SECTION ──
  Widget _buildCrossSellSection() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF757575), // Dark grey
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Choose from our more service",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _smallServiceCard("Pearl Facial", "899", "assets/images/salon.png"),
                _smallServiceCard("Gold Facial", "999", "assets/images/salon2.png"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallServiceCard(String title, String price, String img) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(img, width: 65, height: 65, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                const SizedBox(height: 2),
                Text("₹$price", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const Text("onwards", style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.add_circle, color: Colors.grey, size: 28),
        ],
      ),
    );
  }
}