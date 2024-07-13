class BankDetailsResponse {
  bool? error;
  String? message;
  List<BankDetailData>? data;

  BankDetailsResponse({this.error, this.message, this.data});

  BankDetailsResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BankDetailData>[];
      json['data'].forEach((v) {
        data!.add(new BankDetailData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BankDetailData {
  String? id;
  String? userId;
  String? bankName;
  String? accountHolderName;
  String? accountNumber;
  String? ifscCode;
  String? branchName;
  String? upiId;
  String? createdAt;
  String? updatedAt;
  bool? isSelected ;

  BankDetailData(
      {this.id,
        this.isSelected,
        this.userId,
        this.bankName,
        this.accountHolderName,
        this.accountNumber,
        this.ifscCode,
        this.branchName,
        this.upiId,
        this.createdAt,
        this.updatedAt});

  BankDetailData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    bankName = json['bank_name'];
    accountHolderName = json['account_holder_name'];
    accountNumber = json['account_number'];
    ifscCode = json['ifsc_code'];
    branchName = json['branch_name'];
    upiId = json['upi_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isSelected = false ;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['bank_name'] = this.bankName;
    data['account_holder_name'] = this.accountHolderName;
    data['account_number'] = this.accountNumber;
    data['ifsc_code'] = this.ifscCode;
    data['branch_name'] = this.branchName;
    data['upi_id'] = this.upiId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
