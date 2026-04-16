class reviewListModal {
  bool? status;
  int? totalReviews;
  List<Data>? data;

  reviewListModal({this.status, this.totalReviews, this.data});

  reviewListModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    totalReviews = json['total_reviews'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['total_reviews'] = this.totalReviews;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? reviewId;
  int? bookingId;
  String? customerName;
  int? customerId;
  int? serviceId;
  String? serviceName;
  int? rating;
  String? comment;

  Data(
      {this.reviewId,
        this.bookingId,
        this.customerName,
        this.customerId,
        this.serviceId,
        this.serviceName,
        this.rating,
        this.comment});

  Data.fromJson(Map<String, dynamic> json) {
    reviewId = json['review_id'];
    bookingId = json['booking_id'];
    customerName = json['customer_name'];
    customerId = json['customer_id'];
    serviceId = json['service_id'];
    serviceName = json['service_name'];
    rating = json['rating'];
    comment = json['comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['review_id'] = this.reviewId;
    data['booking_id'] = this.bookingId;
    data['customer_name'] = this.customerName;
    data['customer_id'] = this.customerId;
    data['service_id'] = this.serviceId;
    data['service_name'] = this.serviceName;
    data['rating'] = this.rating;
    data['comment'] = this.comment;
    return data;
  }
}
