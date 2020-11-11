class TempleData {
  List<Temple> temple;

  TempleData({this.temple});

  TempleData.fromJson(Map<String, dynamic> json) {
    if (json['temple'] != null) {
      temple = new List<Temple>();
      json['temple'].forEach((v) {
        temple.add(new Temple.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.temple != null) {
      data['temple'] = this.temple.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Temple {
  String name;
  String description;
  String file;
  String bankAccountNumber;
  String ifsc;
  String branch;
  String address;
  int id;
  String updatedAt;
  String createdAt;

  Temple(
      {this.name,
      this.description,
      this.file,
      this.bankAccountNumber,
      this.ifsc,
      this.branch,
      this.address,
      this.id,
      this.updatedAt,
      this.createdAt});

  Temple.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    file = json['file'];
    bankAccountNumber = json['bank_account_number'];
    ifsc = json['ifsc'];
    branch = json['branch'];
    address = json['address'];
    id = json['id'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['description'] = this.description;
    data['file'] = this.file;
    data['bank_account_number'] = this.bankAccountNumber;
    data['ifsc'] = this.ifsc;
    data['branch'] = this.branch;
    data['address'] = this.address;
    data['id'] = this.id;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    return data;
  }
}
