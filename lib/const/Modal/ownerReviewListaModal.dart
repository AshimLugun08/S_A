class ReviewModal {
  bool? status;
  int? totalReviews;
  List<ReviewData>? data;

  ReviewModal({this.status, this.totalReviews, this.data});

  ReviewModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    totalReviews = json['total_reviews'];
    if (json['data'] != null) {
      data = <ReviewData>[];
      json['data'].forEach((v) {
        data!.add(ReviewData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['total_reviews'] = totalReviews;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReviewData {
  int? reviewId;
  int? bookingId;
  String? customerName;
  int? customerId;
  int? serviceId;
  String? serviceName;
  int? rating;
  String? comment;
  String? createdAt;

  ReviewData({
    this.reviewId,
    this.bookingId,
    this.customerName,
    this.customerId,
    this.serviceId,
    this.serviceName,
    this.rating,
    this.comment,
    this.createdAt,
  });

  ReviewData.fromJson(Map<String, dynamic> json) {
    reviewId = json['review_id'];
    bookingId = json['booking_id'];
    customerName = json['customer_name'];
    customerId = json['customer_id'];
    serviceId = json['service_id'];
    serviceName = json['service_name'];
    rating = json['rating'];
    comment = json['comment'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['review_id'] = reviewId;
    data['booking_id'] = bookingId;
    data['customer_name'] = customerName;
    data['customer_id'] = customerId;
    data['service_id'] = serviceId;
    data['service_name'] = serviceName;
    data['rating'] = rating;
    data['comment'] = comment;
    data['created_at'] = createdAt;
    return data;
  }
}