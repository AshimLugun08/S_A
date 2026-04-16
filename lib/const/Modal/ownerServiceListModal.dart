class OwnerServiceListModal {
  bool? status;
  String? message;
  int? userId;
  int? totalServices;
  String? amount;
  List<Data>? data;

  OwnerServiceListModal(
      {this.status,
        this.message,
        this.userId,
        this.totalServices,
        this.amount,
        this.data});

  OwnerServiceListModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    userId = json['user_id'];
    totalServices = json['total_services'];
    amount = json['amount'];
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
    data['message'] = this.message;
    data['user_id'] = this.userId;
    data['total_services'] = this.totalServices;
    data['amount'] = this.amount;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? serviceId;
  String? name;
  String? description;
  String? category;
  String? subcategory;
  String? image;
  String? amount;
  bool? isActive;

  Data(
      {this.serviceId,
        this.name,
        this.description,
        this.category,
        this.subcategory,
        this.image,
        this.amount,
        this.isActive});

  Data.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id'];
    name = json['name'];
    description = json['description'];
    category = json['category'];
    subcategory = json['subcategory'];
    image = json['image'];
    amount = json['amount'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['service_id'] = this.serviceId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['category'] = this.category;
    data['subcategory'] = this.subcategory;
    data['image'] = this.image;
    data['amount'] = this.amount;
    data['is_active'] = this.isActive;
    return data;
  }
}
