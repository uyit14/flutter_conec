class LoginResponse {
  bool status;
  String token;
  String error;

  LoginResponse({this.status, this.token, this.error});

  LoginResponse.fromJson(Map<String, dynamic> json) {
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