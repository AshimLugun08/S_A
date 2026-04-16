class BusDetailsModal {
  bool? status;
  String? message;
  Data? data;

  BusDetailsModal({this.status, this.message, this.data});

  BusDetailsModal.fromJson(Map<String, dynamic> json) {
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
  int? id;
  int? ownerId;
  String? ownerName;
  String? name;
  String? price;
  String? image;
  String? description;
  int? subcategoryId;
  String? subcategoryName;

  Data(
      {this.id,
        this.ownerId,
        this.ownerName,
        this.name,
        this.price,
        this.image,
        this.description,
        this.subcategoryId,
        this.subcategoryName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['owner_id'];
    ownerName = json['owner_name'];
    name = json['name'];
    price = json['price'];
    image = json['image'];
    description = json['description'];
    subcategoryId = json['subcategory_id'];
    subcategoryName = json['subcategory_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['owner_id'] = this.ownerId;
    data['owner_name'] = this.ownerName;
    data['name'] = this.name;
    data['price'] = this.price;
    data['image'] = this.image;
    data['description'] = this.description;
    data['subcategory_id'] = this.subcategoryId;
    data['subcategory_name'] = this.subcategoryName;
    return data;
  }
}
