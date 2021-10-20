class RequestMemberResponse {
  List<Request> requests;

  RequestMemberResponse({this.requests});

  RequestMemberResponse.fromJson(Map<String, dynamic> json) {
    if (json['requests'] != null) {
      requests = new List<Request>();
      json['requests'].forEach((v) {
        requests.add(new Request.fromJson(v));
      });
    }
  }
}

class Request {
  String id;
  String memberId;
  String name;
  String phoneNumber;
  String email;
  String createdDate;
  String notes;

  Request(
      {this.id,
      this.memberId,
      this.name,
      this.phoneNumber,
      this.email,
      this.createdDate,
      this.notes});

  Request.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    memberId = json['memberId'];
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
    createdDate = json['createdDate'];
    notes = json['notes'];
  }
}
