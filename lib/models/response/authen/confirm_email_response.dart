class ConfirmEmailResponse {
  bool status;
  String token;
  String error;

  ConfirmEmailResponse({this.status, this.token, this.error});

  ConfirmEmailResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    token = json['token'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['token'] = this.token;
    data['error'] = this.error;
    return data;
  }
}