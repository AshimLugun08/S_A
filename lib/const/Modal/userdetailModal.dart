class UserProfileModal {
  bool? status;
  Data? data;

  UserProfileModal({this.status, this.data});

  UserProfileModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? userId;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? role;
  String? profileImage;

  Data(
      {this.userId,
        this.name,
        this.email,
        this.phone,
        this.address,
        this.role,
        this.profileImage});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    role = json['role'];
    profileImage = json['profile_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['role'] = this.role;
    data['profile_image'] = this.profileImage;
    return data;
  }
}
