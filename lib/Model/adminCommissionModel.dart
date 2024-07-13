class AdminCommissionResponse {
  bool? error;
  String? message;
  AdminCommissionData? data;

  AdminCommissionResponse({this.error, this.message, this.data});

  AdminCommissionResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    data = json['data'] != null ? new AdminCommissionData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AdminCommissionData {
  String? commissionType;
  String? commissionValue;

  AdminCommissionData({this.commissionType, this.commissionValue});

  AdminCommissionData.fromJson(Map<String, dynamic> json) {
    commissionType = json['commission_type'];
    commissionValue = json['commission_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['commission_type'] = this.commissionType;
    data['commission_value'] = this.commissionValue;
    return data;
  }
}
