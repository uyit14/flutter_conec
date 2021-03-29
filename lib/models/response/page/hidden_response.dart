class HiddenResponse {
  bool status;
  String message;

  HiddenResponse({this.status, this.message});

  HiddenResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }
}