class PushNotifyResponse{
  bool status;
  String msg;

  PushNotifyResponse({this.status, this.msg});

  PushNotifyResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
  }
}