class GiftResponse {
  bool status;
  int remainPush;
  int remainPriority;

  GiftResponse({this.status, this.remainPush, this.remainPriority});

  GiftResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    remainPush = json['remain_push'];
    remainPriority = json['remain_priority'];
  }
}
