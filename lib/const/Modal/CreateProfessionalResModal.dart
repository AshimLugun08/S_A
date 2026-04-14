class createProfessionalResModal {
  bool? status;
  String? message;
  Data? data;

  createProfessionalResModal({this.status, this.message, this.data});

  createProfessionalResModal.fromJson(Map<String, dynamic> json) {
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
  int? professionalId;
  int? userId;
  String? name;
  String? phone;
  String? profession;

  Data(
      {this.professionalId,
        this.userId,
        this.name,
        this.phone,
        this.profession});

  Data.fromJson(Map<String, dynamic> json) {
    professionalId = json['professional_id'];
    userId = json['user_id'];
    name = json['name'];
    phone = json['phone'];
    profession = json['profession'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['professional_id'] = this.professionalId;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['profession'] = this.profession;
    return data;
  }
}
