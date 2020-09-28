class LoginResponse {
  bool status;
  String token;
  String error;
  String expires;

  LoginResponse({this.status, this.token, this.error, this.expires});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    token = json['token'];
    error = json['error'];
    expires = json['expires'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['token'] = this.token;
    data['error'] = this.error;
    return data;
  }
}