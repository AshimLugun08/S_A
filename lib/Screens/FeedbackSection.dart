import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart'; // Import your ApiService

class FeedbackPage extends StatefulWidget {
  final int bookingId;
  final int userId;
  final int serviceId;
  final String serviceName;

  const FeedbackPage({
    super.key,
    required this.bookingId,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _selectedRating = 0;
  bool _isSubmitting = false;
  final TextEditingController _feedbackController = TextEditingController();

  // ─── SUBMIT LOGIC ───
  Future<void> _submitFeedback() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a star rating"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Call the API service
    final result = await ApiService.addReview(
      bookingId: widget.bookingId,
      userId: widget.userId,
      serviceId: widget.serviceId,
      rating: _selectedRating,
      comment: _feedbackController.text.trim().isEmpty
          ? "No comment provided"
          : _feedbackController.text,
    );

    setState(() => _isSubmitting = false);

    if (result != null && result['status'] == true) {
      // Show Success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Review Submitted!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Return to previous screen
      }
    } else {
      // Show Error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review already sumbitted"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_circle_left_outlined, size: 30, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Feedback', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. Service Info Card (Now using widget.serviceName)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.divider),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 80, height: 80, color: AppColors.background,
                      child: const Icon(Icons.cleaning_services, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.serviceName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text("Rate your overall experience", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'How would you rate the experience\nand service ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 24),

            // 3. Star Rating Logic
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _selectedRating ? Icons.star : Icons.star_outline,
                      size: 45,
                      color: index < _selectedRating ? Colors.orange : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 40),

            // 4. Feedback Input Field
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Tell us on how we can improve...',
                  contentPadding: EdgeInsets.all(20),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 5. Submit Button (With Loading State)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}