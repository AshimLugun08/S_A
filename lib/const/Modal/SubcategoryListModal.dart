class SubcategoryListModal {
  bool? status;
  String? message;
  List<Data>? data;

  SubcategoryListModal({this.status, this.message, this.data});

  SubcategoryListModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
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
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? subcategoryId;
  String? name;
  String? description;
  String? amount;
  int? categoryId;
  String? categoryName;
  List<String>? images;

  Data(
      {this.subcategoryId,
        this.name,
        this.description,
        this.amount,
        this.categoryId,
        this.categoryName,
        this.images});

  Data.fromJson(Map<String, dynamic> json) {
    subcategoryId = json['subcategory_id'];
    name = json['name'];
    description = json['description'];
    amount = json['amount'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    images = json['images'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subcategory_id'] = this.subcategoryId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['amount'] = this.amount;
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    data['images'] = this.images;
    return data;
  }
}
