import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart';


class OfferItem {
  final String title;
  final String discount;
  final String code;
  final String image;
  final Color color;

  OfferItem({
    required this.title,
    required this.discount,
    required this.code,
    required this.image,
    required this.color,
  });
}

class OfferScreen extends StatelessWidget {
  const OfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── DYNAMIC DATA LIST ──
    final List<OfferItem> offers = [
      OfferItem(
        title: "Home Cleaning",
        discount: "50% OFF",
        code: "CLEAN50",
        image: "assets/images/home.png",
        color: const Color(0xFFE3F2FD),
      ),
      OfferItem(
        title: "Salon for Women",
        discount: "30% OFF",
        code: "GLAM30",
        image: "assets/images/salon.png",
        color: const Color(0xFFF3E5F5),
      ),
      OfferItem(
        title: "AC Repair",
        discount: "₹200 OFF",
        code: "COOL200",
        image: "assets/images/pop3.png",
        color: const Color(0xFFFFF3E0),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Offers", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // No back button
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── TOP FEATURED BANNER ──
            _buildFeaturedOffer(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Available Coupons",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // ── DYNAMIC LIST OF COUPONS ──
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      return _buildCouponCard(offers[index]);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. TOP HIGHLIGHT BANNER (Edge-to-Edge Style)
  Widget _buildFeaturedOffer() {
    return Container(
      width: double.infinity,
      height: 180,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: 0, top: 0, bottom: 0,
            child: Image.asset(
              'assets/images/banner_bg.png',
              fit: BoxFit.cover,
              width: 180,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Grab the best deal!",
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                const Text("60% OFF",
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const Text("on Salon Services",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. REUSABLE COUPON CARD
  Widget _buildCouponCard(OfferItem offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Service Image in a colored box
          Container(
            height: 60, width: 60,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: offer.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(offer.image),
          ),
          const SizedBox(width: 15),

          // Offer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(offer.discount, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text("Use code: ${offer.code}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),

          // Copy/Apply Button
          Column(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text("Apply", style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}