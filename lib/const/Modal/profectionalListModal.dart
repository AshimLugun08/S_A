class ProffectionalModal {
  bool? status;
  int? count;
  List<Data>? data;

  ProffectionalModal({this.status, this.count, this.data});

  ProffectionalModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = json['count'];
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
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? profession;
  String? phone;
  int? experience;
  String? address;
  String? description;
  String? image;
  int? ownerId;
  String? ownerName;
  String? ownerPhone;

  Data(
      {this.id,
        this.name,
        this.profession,
        this.phone,
        this.experience,
        this.address,
        this.description,
        this.image,
        this.ownerId,
        this.ownerName,
        this.ownerPhone});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profession = json['profession'];
    phone = json['phone'];
    experience = json['experience'];
    address = json['address'];
    description = json['description'];
    image = json['image'];
    ownerId = json['owner_id'];
    ownerName = json['owner_name'];
    ownerPhone = json['owner_phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['profession'] = this.profession;
    data['phone'] = this.phone;
    data['experience'] = this.experience;
    data['address'] = this.address;
    data['description'] = this.description;
    data['image'] = this.image;
    data['owner_id'] = this.ownerId;
    data['owner_name'] = this.ownerName;
    data['owner_phone'] = this.ownerPhone;
    return data;
  }
}
