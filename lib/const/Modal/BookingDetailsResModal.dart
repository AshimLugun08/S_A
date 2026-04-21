import 'dart:convert';

class BookingResponse {
  bool? status;
  int? count;
  List<BookingItem>? data;

  BookingResponse({this.status, this.count, this.data});

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      status: json['status'],
      count: json['count'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => BookingItem.fromJson(v)).toList()
          : null,
    );
  }
}

class BookingItem {
  int? bookingId;
  int? userId;
  String? phone;
  String? userImage;
  String? address;
  String? serviceName;
  String? date;
  String? time;
  String? professionalName;
  String? status;

  BookingItem({
    this.bookingId,
    this.userId,
    this.phone,
    this.userImage,
    this.address,
    this.serviceName,
    this.date,
    this.time,
    this.professionalName,
    this.status,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      bookingId: json['booking_id'],
      userId: json['user_id'],
      phone: json['phone']?.toString(), // Safety toString
      userImage: json['user_image'],
      address: json['address'],
      serviceName: json['service_name'],
      date: json['date'],
      time: json['time'],
      professionalName: json['professional_name'],
      status: json['status'],
    );
  }
}