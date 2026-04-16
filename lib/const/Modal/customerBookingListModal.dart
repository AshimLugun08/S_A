class customerBookingListModal {
  bool? status;
  int? totalBookings;
  List<Data>? data;

  customerBookingListModal({this.status, this.totalBookings, this.data});

  customerBookingListModal.fromJson(Map<String, dynamic> json) {
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
  String? serviceName;
  String? category;
  String? bookingDate;
  String? bookingTime;
  String? status;
  String? address;
  int? serviceId;
  String? ownerName;
  String? professionalName;
  String? professionalPhone;

  Data(
      {this.bookingId,
        this.serviceName,
        this.category,
        this.bookingDate,
        this.bookingTime,
        this.status,
        this.address,
        this.serviceId,
        this.ownerName,
        this.professionalName,
        this.professionalPhone});

  Data.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    serviceName = json['service_name'];
    category = json['category'];
    bookingDate = json['booking_date'];
    bookingTime = json['booking_time'];
    status = json['status'];
    address = json['address'];
    serviceId = json['service_id'];
    ownerName = json['owner_name'];
    professionalName = json['professional_name'];
    professionalPhone = json['professional_phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['booking_id'] = this.bookingId;
    data['service_name'] = this.serviceName;
    data['category'] = this.category;
    data['booking_date'] = this.bookingDate;
    data['booking_time'] = this.bookingTime;
    data['status'] = this.status;
    data['address'] = this.address;
    data['service_id'] = this.serviceId;
    data['owner_name'] = this.ownerName;
    data['professional_name'] = this.professionalName;
    data['professional_phone'] = this.professionalPhone;
    return data;
  }
}
