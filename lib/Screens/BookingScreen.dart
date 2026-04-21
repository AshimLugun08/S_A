import 'package:flutter/material.dart';
import 'package:s_a/Screens/FeedbackSection.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/session/session.dart';
import 'package:s_a/const/Modal/customerBookingListModal.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<Data> _allBookings = [];
  bool _isLoading = true;
  String? _errorMessage;
  int currentUserId = 0; // This will hold our session ID

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  // ─── CANCEL BOOKING LOGIC ───
  Future<void> _handleCancelBooking(int bookingId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: const Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() => _isLoading = true);

    bool success = await ApiService.updateBookingStatus(
        bookingId: bookingId,
        status: "cancelled"
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking cancelled successfully"), backgroundColor: Colors.green)
      );
      _fetchBookings();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to cancel booking"), backgroundColor: Colors.red)
      );
    }
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userData = await UserPref.getUser();
      // Ensure 'userId' matches the key used in your Session class
      final int userId = userData['userId'] ?? 0;

      setState(() {
        currentUserId = userId;
      });

      if (userId == 0) {
        setState(() { _errorMessage = "User not logged in"; _isLoading = false; });
        return;
      }

      final response = await ApiService.fetchCustomerBookings(userId);

      if (mounted) {
        if (response != null && response.status == true) {
          setState(() {
            _allBookings = response.data ?? [];
            _isLoading = false;
          });
        } else {
          setState(() { _errorMessage = "Failed to load bookings"; _isLoading = false; });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _errorMessage = "An error occurred: $e"; _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text("My Bookings", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [Tab(text: 'Upcoming'), Tab(text: 'Previous')],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : TabBarView(
          children: [
            _BookingList(
              bookings: _allBookings.where((b) => b.status?.toLowerCase() == 'pending').toList(),
              isUpcoming: true,
              userId: currentUserId, // Passing it down
              onRefresh: _fetchBookings,
              onCancel: _handleCancelBooking,
            ),
            _BookingList(
              bookings: _allBookings.where((b) => b.status?.toLowerCase() != 'pending').toList(),
              isUpcoming: false,
              userId: currentUserId, // Passing it down
              onRefresh: _fetchBookings,
              onCancel: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<Data> bookings;
  final bool isUpcoming;
  final int userId; // Added this
  final VoidCallback onRefresh;
  final Function(int) onCancel;

  const _BookingList({
    required this.bookings,
    required this.isUpcoming,
    required this.userId, // Added this
    required this.onRefresh,
    required this.onCancel
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            const Center(child: Text('No bookings found')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => BookingCard(
          booking: bookings[index],
          isUpcoming: isUpcoming,
          userId: userId, // Passing it down
          onCancel: () => onCancel(bookings[index].bookingId ?? 0),
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Data booking;
  final bool isUpcoming;
  final int userId; // Received from parent
  final VoidCallback onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    required this.isUpcoming,
    required this.userId, // Received from parent
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.bookingDate ?? "No Date",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.bookingTime ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  booking.serviceName ?? "Service",
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isUpcoming)
                OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FeedbackPage(
                          bookingId: booking.bookingId ?? 0,
                          userId: userId, // Correctly using the passed prop
                          serviceId: booking.serviceId ?? 0,
                          serviceName: booking.serviceName ?? "Service",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Give Feedback', style: TextStyle(color: Colors.white)),
                ),
              // TextButton(
              //   onPressed: () {
              //     // Navigate to Detail Screen
              //   },
              //   child: const Text('View details', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}