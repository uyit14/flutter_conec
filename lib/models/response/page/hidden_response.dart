class HiddenResponse {
  bool status;
  String message;
  int userViewPostCount = 0;

  HiddenResponse({this.status, this.message});

  HiddenResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    userViewPostCount = json['userViewPostCount'];
  }
}