import 'package:flutter/material.dart';
import 'package:s_a/const/Modal/BookingDetailsResModal.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:url_launcher/url_launcher.dart';



class Utils {
  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print("Could not launch dialer for $phoneNumber");
    }
  }
}

class BookingDetailPage extends StatelessWidget {
  final int bookingId;

  const BookingDetailPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        title: Text("Booking #$bookingId", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<BookingItem?>(
        // Yahan API call Stateless widget ke andar hi trigger ho rahi hai
        future: ApiService.getBookingDetails(bookingId),
        builder: (context, snapshot) {

          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
          }

          // 2. Error or Empty State
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Booking details not found!"));
          }

          // 3. Success State (Data mil gaya)
          final booking = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildStatusHeader(booking.status ?? "pending"),
                const SizedBox(height: 20),

                _buildSectionCard("Service Information", [
                  _rowInfo(Icons.cleaning_services, "Service", booking.serviceName ?? "N/A"),
                  _rowInfo(Icons.event, "Date", booking.date ?? "N/A"),
                  _rowInfo(Icons.schedule, "Time", booking.time ?? "N/A"),
                ]),

                const SizedBox(height: 15),

                _buildSectionCard("Customer & Pro", [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(booking.userImage ?? ""),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.professionalName ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(booking.phone ?? "No phone", style: const TextStyle(color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                  const Divider(height: 30),
                  _rowInfo(Icons.location_on, "Address", booking.address == "" ? "Ranchi, Jharkhand" : booking.address!),
                ]),

                const SizedBox(height: 30),

                // Call Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      if (booking.phone != null && booking.phone!.isNotEmpty) {
                        Utils.makePhoneCall(booking.phone!); // Yahan se dialer open hoga
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Phone number not available"))
                        );
                      }
                    },
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text("CONTACT CUSTOMER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildStatusHeader(String status) {
    Color statusColor = status == "pending" ? Colors.orange : Colors.green;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.stars, color: statusColor),
          const SizedBox(width: 10),
          Text("Status: ${status.toUpperCase()}", style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _rowInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        // Icon ko top par align karne ke liye (agar text multiline ho)
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 12),

          // Expanded use karne se text automatically wrap ho jayega
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)
                ),
                const SizedBox(height: 2), // Thoda sa gap label aur value ke beech
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3, // Lines ke beech space ke liye
                  ),
                  // softWrap: true default hota hai, Expanded ke sath multiline kaam karega
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}