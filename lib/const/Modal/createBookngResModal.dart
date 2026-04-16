class CreateBookingResModal {
  bool? status;
  String? message;
  BookingData? data;

  CreateBookingResModal({this.status, this.message, this.data});

  CreateBookingResModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? BookingData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    result['status'] = status;
    result['message'] = message;
    if (data != null) {
      result['data'] = data!.toJson();
    }
    return result;
  }
}

class BookingData {
  int? bookingId;
  String? customerName;
  String? serviceName;
  String? vendorName;
  int? customerId;
  int? serviceId;
  String? date;
  String? time;
  String? area;
  String? status;

  BookingData({
    this.bookingId,
    this.customerName,
    this.serviceName,
    this.vendorName,
    this.customerId,
    this.serviceId,
    this.date,
    this.time,
    this.area,
    this.status,
  });

  BookingData.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    customerName = json['customer_name'];
    serviceName = json['service_name'];
    vendorName = json['vendor_name'];
    customerId = json['customer_id'];
    serviceId = json['service_id'];
    date = json['date'];
    time = json['time'];
    area = json['area'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = bookingId;
    data['customer_name'] = customerName;
    data['service_name'] = serviceName;
    data['vendor_name'] = vendorName;
    data['customer_id'] = customerId;
    data['service_id'] = serviceId;
    data['date'] = date;
    data['time'] = time;
    data['area'] = area;
    data['status'] = status;
    return data;
  }
}