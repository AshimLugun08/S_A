import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/endpoint/endpoint.dart';
import 'package:s_a/const/session/session.dart';
import 'package:s_a/const/Modal/profectionalListModal.dart' as cat_pro;
import 'package:s_a/const/Modal/serviceDetailModal.dart' as service_detail;



class SummaryScreen extends StatefulWidget {
  final cat_pro.Data professional;
  final String houseNumber;
  final String landmark;
  final String addressType;
  final String date;
  final String time;
  final int serviceId;

  const SummaryScreen({
    super.key,
    required this.professional,
    required this.houseNumber,
    required this.landmark,
    required this.addressType,
    required this.date,
    required this.time,
    required this.serviceId,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  service_detail.Data? _serviceData;
  bool _isLoading = true;
  bool _isBooking = false; // To show loading on the Pay button

  @override
  void initState() {
    super.initState();
    _fetchServiceDetails();
  }

  // ── 1. FETCH SERVICE DETAILS ──
  Future<void> _fetchServiceDetails() async {
    final response = await ApiService.fetchServiceDetails(widget.serviceId);
    if (mounted) {
      setState(() {
        _serviceData = response?.data;
        _isLoading = false;
      });
    }
  }

  // ── 2. CREATE BOOKING API LOGIC ──
  Future<void> _handleBooking() async {
    // 1. Show loading spinner on the button
    setState(() => _isBooking = true);

    try {
      // 2. Fetch User ID from local session
      final userData = await UserPref.getUser();
      final int userId = userData['userId'] ?? 0;

      if (userId == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User session expired. Please login again.")),
          );
        }
        return;
      }

      debugPrint("📡 [Booking] Initiating API call for User: $userId");

      // 3. Call the API Service
      // Note: Ensure your ApiService.createBooking uses the correct keys (customer/service)
      final response = await ApiService().createBooking(
        userId: userId,
        serviceId: widget.serviceId,
        date: widget.date, // Format: 2026-04-16
        time: widget.time, // Format: 10:30
        address: "${widget.houseNumber}, ${widget.landmark}",
      );

      // Guard: Don't use context if the user navigated away during the await
      if (!mounted) return;

      // 4. Handle the Response
      if (response != null && response.status == true) {
        debugPrint("✅ [Booking] Success! ID: ${response.data?.bookingId}");

        // Access bookingId from the nested 'data' object
        int bookingId = response.data?.bookingId ?? 0;

        // Show the Success Dialog with the new ID
        _showSuccessDialog(context, bookingId);

      } else {
        // Show server-side error message (e.g., "Slot already booked")
        String errorMsg = response?.message ?? "Booking failed. Please try again.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("💥 [Booking Exception]: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connection error. Check your internet.")),
        );
      }
    } finally {
      // 5. Hide loading spinner regardless of success or failure
      if (mounted) setState(() => _isBooking = false);
    }
  }

  // ── 3. SUCCESS DIALOG ──
  void _showSuccessDialog(BuildContext context, int bookingId) {
    double price = double.tryParse(_serviceData?.price ?? "0") ?? 0;
    double grandTotal = price - 100 + 50;

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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                  child: Column(
                    children: [
                      const Text("Payment Successful", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("Booking ID: #$bookingId", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 25),
                      _dialogInfoRow("Payment mode", "UPI"),
                      _dialogInfoRow("Total Amount", "₹${grandTotal.toStringAsFixed(0)}"),
                      _dialogInfoRow("Pay Date", widget.date),
                      _dialogInfoRow("Pay Time", widget.time),
                      const SizedBox(height: 20),
                      _buildTicketSeparator(context),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                        ),
                        child: Column(
                          children: [
                            const Text("Total Paid", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text("₹${grandTotal.toStringAsFixed(0)}",
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -45,
                  child: CircleAvatar(
                    radius: 45, backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 35, backgroundColor: AppColors.primary,
                      child: const Icon(Icons.check, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            _actionButton("Done", () {
              Navigator.popUntil(context, (route) => route.isFirst);
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double price = double.tryParse(_serviceData?.price ?? "0") ?? 0;
    double grandTotal = price - 100 + 50;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Summary", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── ADDRESS CARD ──
            _whiteCard(
              child: Column(
                children: [
                  _iconInfoRow(Icons.home,
                      "${widget.addressType}: ${widget.houseNumber}, ${widget.landmark}\nWhite Field, Bangalore"),
                  const Divider(height: 30),
                  _iconInfoRow(Icons.access_time, "${widget.date} - ${widget.time}"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── SERVICE CARD ──
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
                      ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            "${ApiEndoint.baseUrl}${_serviceData?.image}",
                            width: 80, height: 80, fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: Colors.grey[300]),
                          )
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_serviceData?.name ?? "Service", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("₹${_serviceData?.price}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _bullet("45 mins duration"),
                  _bullet(_serviceData?.description ?? "Professional salon service at home"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── PROFESSIONAL CARD ──
            _whiteCard(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 25,
                      backgroundImage: widget.professional.image != null
                          ? NetworkImage("${ApiEndoint.baseUrl}${widget.professional.image}")
                          : const AssetImage('assets/images/user.png') as ImageProvider
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(
                          "${widget.professional.name} (${widget.professional.ownerName})\n${widget.professional.experience} yrs Exp | ${widget.professional.profession}",
                          style: const TextStyle(fontSize: 13)
                      )
                  ),
                  const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── PAYMENT SUMMARY ──
            _whiteCard(
              child: Column(
                children: [
                  _paymentRow("Item Total", "₹${price.toStringAsFixed(0)}"),
                  _paymentRow("Item Discount", "- ₹100", isRed: true),
                  _paymentRow("Service Fee", "₹50"),
                  const Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("GRAND TOTAL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("₹${grandTotal.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _isLoading ? null : Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: _isBooking
            ? const Center(child: CircularProgressIndicator())
            : _actionButton("Pay ₹${grandTotal.toStringAsFixed(0)}", _handleBooking),
      ),
    );
  }

  // ── REUSABLE WIDGETS ──

  Widget _whiteCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity, padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey.shade200)),
      child: child,
    );
  }

  Widget _iconInfoRow(IconData icon, String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: Colors.grey, size: 20),
      const SizedBox(width: 15),
      Expanded(child: Text(text, style: const TextStyle(color: Colors.grey, height: 1.4))),
      const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
    ]);
  }

  Widget _paymentRow(String label, String value, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: isRed ? Colors.red : Colors.black))
      ]),
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
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
      ]),
    );
  }

  Widget _buildTicketSeparator(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(children: List.generate(30, (i) => Expanded(child: Container(height: 1, color: i % 2 == 0 ? Colors.transparent : Colors.grey.shade300)))),
          const Positioned(left: -20, child: CircleAvatar(radius: 20, backgroundColor: AppColors.background)),
          const Positioned(right: -20, child: CircleAvatar(radius: 20, backgroundColor: AppColors.background)),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        const Icon(Icons.circle, size: 5, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)))
      ]),
    );
  }
}