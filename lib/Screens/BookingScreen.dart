import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart';

// ─── App Colors ───────────────────────────────────────────────────────────────
// Note: If using your actual project, use: import 'package:s_a/const/color/colors.dart';


// ─── Models ───────────────────────────────────────────────────────────────────
enum BookingStatus { upcoming, previous, cancelled }

class Booking {
  final String id;
  final String date;
  final String serviceName;
  final String description;
  final String timeSlot;
  final double amount;
  final BookingStatus status;

  const Booking({
    required this.id,
    required this.date,
    required this.serviceName,
    required this.description,
    required this.timeSlot,
    required this.amount,
    required this.status,
  });
}

// ─── Sample Data ──────────────────────────────────────────────────────────────
const List<Booking> _sampleBookings = [
  Booking(
    id: '1',
    date: '12th\nApr. Sunday',
    serviceName: 'Diamond Facial',
    description: 'Skin treatment',
    timeSlot: '07:30 PM',
    amount: 1499.0,
    status: BookingStatus.upcoming,
  ),
  Booking(
    id: '2',
    date: '30th\nDec. Monday',
    serviceName: 'Electrician',
    description: 'Wiring check',
    timeSlot: '2:00 PM – 4:00 PM',
    amount: 349.0,
    status: BookingStatus.upcoming,
  ),
  Booking(
    id: '3',
    date: '19th\nNov. Saturday',
    serviceName: 'AC Service',
    description: 'General service',
    timeSlot: '9:00 AM – 11:00 AM',
    amount: 599.0,
    status: BookingStatus.previous,
  ),
];

// ─── Reschedule Success Dialog (Matches Image) ────────────────────────────────
void _showSuccessDialog(BuildContext context, String service, String date, String time) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Checkmark Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFECEFF1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 60, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            // Header
            const Text(
              'Booking Rescheduled!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            // Body Text with Bold highlights
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                children: [
                  const TextSpan(text: 'Dear Manvi you have successfully re-scheduled your booking of '),
                  TextSpan(
                    text: '$service ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: 'for the new date '),
                  TextSpan(
                    text: '$date at $time',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '\nOur service provider will contact you soon.'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close Dialog
                  Navigator.pop(context); // Return to list
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Booking Screen ───────────────────────────────────────────────────────────
class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 4,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            tabs: [Tab(text: 'Upcoming'), Tab(text: 'Previous')],
          ),
        ),
        body: TabBarView(
          children: [
            _BookingList(
              bookings: _sampleBookings.where((b) => b.status == BookingStatus.upcoming).toList(),
              isUpcoming: true,
            ),
            _BookingList(
              bookings: _sampleBookings.where((b) => b.status == BookingStatus.previous).toList(),
              isUpcoming: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final bool isUpcoming;

  const _BookingList({required this.bookings, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) return const Center(child: Text('No bookings found'));
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => BookingCard(booking: bookings[index], isUpcoming: isUpcoming),
    );
  }
}

// ─── Booking Card ─────────────────────────────────────────────────────────────
class BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isUpcoming;

  const BookingCard({super.key, required this.booking, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.date, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(booking.description, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              Text(booking.serviceName, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isUpcoming)
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel Booking', style: TextStyle(color: AppColors.primary)),
                ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: booking)));
                },
                child: const Text('View details', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Booking Detail Screen ────────────────────────────────────────────────────
class BookingDetailScreen extends StatelessWidget {
  final Booking booking;
  const BookingDetailScreen({super.key, required this.booking});

  // Handle Reschedule Logic
  Future<void> _handleReschedule(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 30),
    );

    if (pickedTime == null) return;

    // Formatting for Dialog
    String formattedDate = "${pickedDate.day} ${_getMonth(pickedDate.month)}";
    String formattedTime = pickedTime.format(context).toLowerCase();

    if (context.mounted) {
      _showSuccessDialog(context, booking.serviceName, formattedDate, formattedTime);
    }
  }

  String _getMonth(int month) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return m[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Booking Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _DetailCard(
              title: 'Service Information',
              rows: [
                _DetailRow(label: 'Service', value: booking.serviceName),
                _DetailRow(label: 'Date', value: booking.date.replaceAll('\n', ' ')),
                _DetailRow(label: 'Time', value: booking.timeSlot),
              ],
            ),
            const Spacer(),
            if (booking.status == BookingStatus.upcoming)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleReschedule(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Reschedule Booking',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets for Detail Screen ─────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  final String title;
  final List<_DetailRow> rows;
  const _DetailCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 12),
          ...rows.map((r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(r.label, style: TextStyle(color: Colors.grey.shade600)),
                Text(r.value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}



class _DetailRow {
  final String label;
  final String value;
  _DetailRow({required this.label, required this.value});
}

