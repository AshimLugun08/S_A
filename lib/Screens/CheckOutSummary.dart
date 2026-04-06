import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart';

// ── CUSTOM COLORS ──


class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  // ── 1. THE SUCCESS DIALOG LOGIC ──
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                // The White Ticket Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      const Text("Payment Successful", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 25),
                      _dialogInfoRow("Payment mode", "UPI"),
                      _dialogInfoRow("Total Amount", "₹1249"),
                      _dialogInfoRow("Pay Date", "Apr 10, 2026"),
                      _dialogInfoRow("Pay Time", "10:45am"),
                      const SizedBox(height: 20),

                      _buildTicketSeparator(context), // Perforated line effect

                      // Light Blue Bottom Section
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                        ),
                        child: Column(
                          children: const [
                            Text("Total Pay", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text("₹1249", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Floating Checkmark
                Positioned(
                  top: -45,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            _actionButton("Done", () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_circle_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Summary", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── ADDRESS CARD ──
            _whiteCard(
              child: Column(
                children: [
                  _iconInfoRow(Icons.home, "Plot No. 209, Kavuri Hills, White Filed,\nBangalore, Karnataka\nPh. : +91 000 0000 000"),
                  const Divider(height: 30),
                  _iconInfoRow(Icons.access_time, "Sat, Apr 10 - 06:30 PM"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── SERVICE CARD (BLUE) ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(25)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Selected Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.asset('assets/images/ss1.jpg', width: 80, height: 80, fit: BoxFit.cover)),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Diamond Facial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("₹1299", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _bullet("45 mins"),
                  _bullet("For all skin types. Pinacolada mask."),
                  _bullet("6-step process. Includes 10-min massage"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── PROFESSIONAL CARD ──
            _whiteCard(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  const CircleAvatar(radius: 25, backgroundImage: AssetImage('assets/images/user.png')),
                  const SizedBox(width: 12),
                  const Expanded(child: Text("Pankaj Kumar (Salon Classic)\n5 yrs Exp | 30 mins", style: TextStyle(fontSize: 13))),
                  const Icon(Icons.edit_outlined, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── PAYMENT SUMMARY ──
            _whiteCard(
              child: Column(
                children: [
                  _paymentRow("Item Total", "₹1299"),
                  _paymentRow("Item Discount", "- ₹100", isRed: true),
                  _paymentRow("Service Free", "₹50"),
                  const Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("GRAND TOTAL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("₹1249", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: _actionButton("Pay ₹1249", () => _showSuccessDialog(context)),
      ),
    );
  }

  // ── REUSABLE WIDGETS ──
  Widget _whiteCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey.shade200)),
      child: child,
    );
  }

  Widget _iconInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 15),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.grey, height: 1.4))),
        const Icon(Icons.edit_outlined, size: 20),
      ],
    );
  }

  Widget _paymentRow(String label, String value, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: isRed ? Colors.red : Colors.black))]),
    );
  }

  Widget _actionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      height: 55, width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  Widget _dialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }

  Widget _buildTicketSeparator(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(children: List.generate(30, (i) => Expanded(child: Container(height: 1, color: i % 2 == 0 ? Colors.transparent : Colors.grey.shade300)))),
          Positioned(left: -20, child: CircleAvatar(radius: 20, backgroundColor: Colors.black.withOpacity(0.5))),
          Positioned(right: -20, child: CircleAvatar(radius: 20, backgroundColor: Colors.black.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [const Icon(Icons.circle, size: 5, color: Colors.grey), const SizedBox(width: 10), Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13))]),
    );
  }
}