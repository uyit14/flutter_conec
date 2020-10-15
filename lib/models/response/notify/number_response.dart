class NumberResponse {
  bool status;
  int notifyCounter;

  NumberResponse({this.status, this.notifyCounter});

  NumberResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    notifyCounter = json['notify_counter'];
  }
}