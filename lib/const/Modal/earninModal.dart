class OwnerEarningModal {
  bool? status;
  int? ownerId;
  String? ownerName;
  double? totalEarning;

  OwnerEarningModal({this.status, this.ownerId, this.ownerName, this.totalEarning});

  OwnerEarningModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    ownerId = json['owner_id'];
    ownerName = json['owner_name'];
    // Handle both int and double from API safely
    totalEarning = (json['total_earning'] as num?)?.toDouble();
  }
}