import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart'; // Ensure path is correct

class PaymentOptionsScreen extends StatefulWidget {
  const PaymentOptionsScreen({super.key});

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  // Track which payment method is selected
  String _selectedMethod = "PhonePe";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_circle_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payment Options",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. UPI SECTION ──
                  const Text("UPI", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _paymentMethodTile(
                    id: "Paytm",
                    title: "Paytm UPI",
                    iconPath: 'assets/images/paytm_logo.png', // Update your assets
                  ),
                  _paymentMethodTile(
                    id: "PhonePe",
                    title: "PhonePe",
                    iconPath: 'assets/images/phonepe_logo.png',
                  ),
                  _paymentMethodTile(
                    id: "GPay",
                    title: "GPay",
                    iconPath: 'assets/images/gpay_logo.png',
                  ),

                  const Divider(height: 40),

                  // ── 2. CARDS SECTION ──
                  const Text("Cards", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _paymentMethodTile(
                    id: "Mastercard",
                    title: "************2575",
                    prefixIcon: Icons.credit_card, // Fallback icon
                    iconPath: 'assets/images/mastercard_logo.png',
                  ),

                  const Divider(height: 40),

                  // ── 3. CASH SECTION ──
                  const Text("Cash", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _paymentMethodTile(
                    id: "COD",
                    title: "Cash on Delivery",
                    prefixIcon: Icons.money,
                    iconPath: 'assets/images/cash_icon.png',
                  ),
                ],
              ),
            ),
          ),

          // ── 4. PROCEED BUTTON ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text(
                  "Proceed to Pay",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── REUSABLE PAYMENT TILE ──
  Widget _paymentMethodTile({
    required String id,
    required String title,
    String? iconPath,
    IconData? prefixIcon,
  }) {
    bool isSelected = _selectedMethod == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Custom Radio Circle
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 15),

            // Branding Logo (if Mastercard, show logo next to radio)
            if (id == "Mastercard" && iconPath != null)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Image.asset(iconPath, width: 35),
              ),

            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),

            // Trailing Logo/Icon
            if (id != "Mastercard" && iconPath != null)
              Image.asset(iconPath, width: 40, height: 40, fit: BoxFit.contain),
            if (iconPath == null && prefixIcon != null)
              Icon(prefixIcon, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}