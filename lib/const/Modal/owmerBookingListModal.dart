class OwnerBookingListModal {
  bool? status;
  int? totalBookings;
  List<Data>? data;

  OwnerBookingListModal({this.status, this.totalBookings, this.data});

  OwnerBookingListModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    totalBookings = json['total_bookings'];
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
    data['total_bookings'] = this.totalBookings;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? bookingId;
  int? serviceId;
  String? serviceName;
  int? professionalId;
  String? professionalName;
  String? bookingDate;
  String? bookingTime;
  String? status;
  String? address;

  Data(
      {this.bookingId,
        this.serviceId,
        this.serviceName,
        this.professionalId,
        this.professionalName,
        this.bookingDate,
        this.bookingTime,
        this.status,
        this.address});

  Data.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    serviceId = json['service_id'];
    serviceName = json['service_name'];
    professionalId = json['professional_id'];
    professionalName = json['professional_name'];
    bookingDate = json['booking_date'];
    bookingTime = json['booking_time'];
    status = json['status'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['booking_id'] = this.bookingId;
    data['service_id'] = this.serviceId;
    data['service_name'] = this.serviceName;
    data['professional_id'] = this.professionalId;
    data['professional_name'] = this.professionalName;
    data['booking_date'] = this.bookingDate;
    data['booking_time'] = this.bookingTime;
    data['status'] = this.status;
    data['address'] = this.address;
    return data;
  }
}
