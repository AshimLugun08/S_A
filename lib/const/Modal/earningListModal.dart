class OwnerEarningListModal {
  bool? status;
  int? ownerId;
  String? ownerName;
  double? totalEarning;
  int? totalBookings;
  List<EarningItem>? data;

  OwnerEarningListModal({
    this.status,
    this.ownerId,
    this.ownerName,
    this.totalEarning,
    this.totalBookings,
    this.data,
  });

  OwnerEarningListModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    ownerId = json['owner_id'];
    ownerName = json['owner_name'];
    // num use karke double mein convert karna safe rehta hai
    totalEarning = (json['total_earning'] as num?)?.toDouble();
    totalBookings = json['total_bookings'];
    if (json['data'] != null) {
      data = <EarningItem>[];
      json['data'].forEach((v) {
        data!.add(EarningItem.fromJson(v));
      });
    }
  }
}

class EarningItem {
  int? bookingId;
  String? customerName;
  int? serviceId;
  String? serviceName;
  String? professionalName;
  String? bookingDate;
  String? bookingTime;
  double? amount;

  EarningItem({
    this.bookingId,
    this.customerName,
    this.serviceId,
    this.serviceName,
    this.professionalName,
    this.bookingDate,
    this.bookingTime,
    this.amount,
  });

  EarningItem.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    customerName = json['customer_name'];
    serviceId = json['service_id'];
    serviceName = json['service_name'];
    professionalName = json['professional_name'];
    bookingDate = json['booking_date'];
    bookingTime = json['booking_time'];
    amount = (json['amount'] as num?)?.toDouble();
  }
}