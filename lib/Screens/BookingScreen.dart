import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart';

// ─── App Colors ───────────────────────────────────────────────────────────────
// Replace with your actual import: import 'package:s_a/const/color/colors.dart';

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
    date: '25th\nDec. Wednesday',
    serviceName: 'Plumbing',
    description: 'Pipe repair',
    timeSlot: '10:00 AM – 12:00 PM',
    amount: 499.0,
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
  Booking(
    id: '4',
    date: '5th\nNov. Sunday',
    serviceName: 'Deep Cleaning',
    description: 'Full home clean',
    timeSlot: '8:00 AM – 1:00 PM',
    amount: 1199.0,
    status: BookingStatus.previous,
  ),
];

// ─── Booking Screen ───────────────────────────────────────────────────────────
class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 20,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Previous'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── Upcoming Tab ──────────────────────────────────────────────
            _BookingList(
              bookings: _sampleBookings
                  .where((b) => b.status == BookingStatus.upcoming)
                  .toList(),
              emptyMessage: 'No upcoming bookings',
              isUpcoming: true,
            ),

            // ── Previous Tab ──────────────────────────────────────────────
            _BookingList(
              bookings: _sampleBookings
                  .where((b) => b.status == BookingStatus.previous)
                  .toList(),
              emptyMessage: 'No previous bookings',
              isUpcoming: false,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Booking List ─────────────────────────────────────────────────────────────
class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final String emptyMessage;
  final bool isUpcoming;

  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUpcoming ? Icons.calendar_today_outlined : Icons.history,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => BookingCard(
        booking: bookings[index],
        isUpcoming: isUpcoming,
      ),
    );
  }
}

// ─── Booking Card ─────────────────────────────────────────────────────────────
class BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isUpcoming;

  const BookingCard({
    super.key,
    required this.booking,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date + description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.date,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        booking.description,
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        booking.timeSlot,
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),

              // Service name + amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    booking.serviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${booking.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 25),

          // ── Action Buttons ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isUpcoming) ...[
                // Cancel button for upcoming
                ElevatedButton(
                  onPressed: () => _onCancel(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cancel Booking',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                // Feedback button for previous
                ElevatedButton(
                  onPressed: () => _onFeedback(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Share Feedback',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],

              // View Details (both tabs)
              TextButton(
                onPressed: () => _onViewDetails(context),
                child: const Text(
                  'View details',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Handlers ────────────────────────────────────────────────────────────────
  void _onCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
            'Are you sure you want to cancel your ${booking.serviceName} booking?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled')),
              );
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onFeedback(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FeedbackSheet(booking: booking),
    );
  }

  void _onViewDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailScreen(booking: booking),
      ),
    );
  }
}

// ─── Feedback Bottom Sheet ────────────────────────────────────────────────────
class _FeedbackSheet extends StatefulWidget {
  final Booking booking;
  const _FeedbackSheet({required this.booking});

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  int _rating = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Rate your ${widget.booking.serviceName}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            widget.booking.date.replaceAll('\n', ' '),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Star rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = star),
                child: Icon(
                  star <= _rating ? Icons.star : Icons.star_border,
                  color: star <= _rating ? Colors.amber : Colors.grey,
                  size: 40,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write your comments here…',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _rating == 0
                  ? null
                  : () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Thank you for your feedback!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'Submit Feedback',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Booking Details',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: booking.status == BookingStatus.upcoming
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status == BookingStatus.upcoming
                      ? 'Upcoming'
                      : 'Completed',
                  style: TextStyle(
                    color: booking.status == BookingStatus.upcoming
                        ? Colors.green
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Service info card
            _DetailCard(
              title: 'Service Information',
              rows: [
                _DetailRow(label: 'Service', value: booking.serviceName),
                _DetailRow(label: 'Type', value: booking.description),
                _DetailRow(label: 'Date', value: booking.date.replaceAll('\n', ' ')),
                _DetailRow(label: 'Time', value: booking.timeSlot),
              ],
            ),
            const SizedBox(height: 16),

            // Payment card
            _DetailCard(
              title: 'Payment Summary',
              rows: [
                _DetailRow(label: 'Service Charge', value: '₹${booking.amount.toStringAsFixed(0)}'),
                const _DetailRow(label: 'Taxes & Fees', value: '₹0'),
                _DetailRow(
                  label: 'Total',
                  value: '₹${booking.amount.toStringAsFixed(0)}',
                  isBold: true,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Booking ID card
            _DetailCard(
              title: 'Booking Reference',
              rows: [
                _DetailRow(label: 'Booking ID', value: '#BK${booking.id.padLeft(6, '0')}'),
              ],
            ),
            const SizedBox(height: 30),

            // CTA
            if (booking.status == BookingStatus.upcoming)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Reschedule Booking',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Detail Card ──────────────────────────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  final String title;
  final List<_DetailRow> rows;

  const _DetailCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          const SizedBox(height: 12),
          ...rows.map((row) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(row.label,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 14)),
                Text(row.value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: row.isBold
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: Colors.black87)),
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
  final bool isBold;

  const _DetailRow(
      {required this.label, required this.value, this.isBold = false});
}

// ─── Entry Point (for standalone testing) ────────────────────────────────────
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BookingScreen(),
  ));
}