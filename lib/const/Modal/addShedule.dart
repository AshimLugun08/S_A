class addSherdule {
  bool? status;
  String? message;
  int? scheduleId;

  addSherdule({this.status, this.message, this.scheduleId});

  addSherdule.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    scheduleId = json['schedule_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['schedule_id'] = this.scheduleId;
    return data;
  }
}
