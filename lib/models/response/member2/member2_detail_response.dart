import 'package:conecapp/common/helper.dart';

class Member2DetailResponse {
  bool status;
  Member2Detail member2Detail;

  Member2DetailResponse({this.status, this.member2Detail});

  Member2DetailResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    member2Detail = json['member'] != null
        ? new Member2Detail.fromJson(json['member'])
        : null;
  }
}

class Member2Detail {
  String userId;
  String userAvatar;
  String userName;
  String name;
  String userPhoneNumber;
  String userEmail;
  String userAddress;
  String joinedDate;
  bool accepted;
  String group;
  List<Payment2> payment2s;

  Member2Detail(
      {this.userId,
      this.userAvatar,
      this.userName,
      this.name,
      this.userPhoneNumber,
      this.userEmail,
      this.userAddress,
      this.joinedDate,
      this.group,
      this.accepted,
      this.payment2s});

  Member2Detail.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userAvatar =
        json['userAvatar'] != null && !json['userAvatar'].contains("http")
            ? Helper.baseURL + json['userAvatar']
            : json['userAvatar'];
    userName = json['userName'];
    if (json['name'] != null) name = json['name'];
    if (json['accepted'] != null) accepted = json['accepted'];
    userPhoneNumber = json['userPhoneNumber'];
    userEmail = json['userEmail'];
    userAddress = json['userAddress'];
    joinedDate = json['joinedDate'] == null
        ? null
        : Helper.formatDob(json['joinedDate']);
    group = json['group'];
    if (json['payments'] != null) {
      payment2s = new List<Payment2>();
      json['payments'].forEach((v) {
        payment2s.add(new Payment2.fromJson(v));
      });
    }
  }
}

class Payment2 {
  String paymentDate;
  int amount;
  String status;

  Payment2({this.paymentDate, this.amount, this.status});

  Payment2.fromJson(Map<String, dynamic> json) {
    paymentDate = json['paymentDate'] == null
        ? null
        : Helper.formatDob(json['paymentDate']);
    amount = json['amount'];
    status = json['status'];
  }
}
