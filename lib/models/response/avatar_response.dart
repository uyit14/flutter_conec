class AvatarResponse {
  bool status;
  String error;
  String avatar;

  AvatarResponse({this.status, this.error, this.avatar});

  AvatarResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    avatar = json['avatar'] !=null ? "http://149.28.140.240:8088" + json['avatar'] : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['error'] = this.error;
    data['avatar'] = this.avatar;
    return data;
  }
}