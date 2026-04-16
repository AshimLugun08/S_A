class VerifyOtpresModal {
  bool? status;
  String? message;
  int? userId;
  String? name;
  String? phone;
  String? email;
  String? role;
  String? address;
  String? city;
  String? state;
  String? profileImage;

  VerifyOtpresModal(
      {this.status,
        this.message,
        this.userId,
        this.name,
        this.phone,
        this.email,
        this.role,
        this.address,
        this.city,
        this.state,
        this.profileImage});

  VerifyOtpresModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    userId = json['user_id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    role = json['role'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    profileImage = json['profile_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['role'] = this.role;
    data['address'] = this.address;
    data['city'] = this.city;
    data['state'] = this.state;
    data['profile_image'] = this.profileImage;
    return data;
  }
}
