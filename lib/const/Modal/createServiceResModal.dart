class createServiceResModal {
  bool? status;
  String? message;
  Data? data;

  createServiceResModal({this.status, this.message, this.data});

  createServiceResModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? serviceId;
  String? name;
  String? amount;
  String? category;
  String? subcategory;
  Owner? owner;

  Data(
      {this.serviceId,
        this.name,
        this.amount,
        this.category,
        this.subcategory,
        this.owner});

  Data.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id'];
    name = json['name'];
    amount = json['amount'];
    category = json['category'];
    subcategory = json['subcategory'];
    owner = json['owner'] != null ? new Owner.fromJson(json['owner']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['service_id'] = this.serviceId;
    data['name'] = this.name;
    data['amount'] = this.amount;
    data['category'] = this.category;
    data['subcategory'] = this.subcategory;
    if (this.owner != null) {
      data['owner'] = this.owner!.toJson();
    }
    return data;
  }
}

class Owner {
  int? ownerId;
  String? ownerName;

  Owner({this.ownerId, this.ownerName});

  Owner.fromJson(Map<String, dynamic> json) {
    ownerId = json['owner_id'];
    ownerName = json['owner_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['owner_id'] = this.ownerId;
    data['owner_name'] = this.ownerName;
    return data;
  }
}
