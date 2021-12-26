import 'dart:io';

import 'package:conecapp/common/helper.dart';

class MemberInfoResponse {
  bool status;
  MemberInfo memberInfo;

  MemberInfoResponse({this.status, this.memberInfo});

  MemberInfoResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    memberInfo = json['request'] != null
        ? new MemberInfo.fromJson(json['request'])
        : null;
  }
}

class MemberInfo {
  String id;
  String memberId;
  String avatar;
  String userName;
  String name;
  String email;
  String phoneNumber;
  int amount;
  String joinedDate;
  String created;
  String joiningFeePeriod;
  String notes;
  File avatarSource;

  MemberInfo(
      {this.id,
      this.memberId,
      this.avatar,
      this.userName,
      this.name,
      this.email,
      this.phoneNumber,
      this.amount,
      this.joinedDate,
      this.created,
      this.joiningFeePeriod,
      this.notes,
      this.avatarSource});

  MemberInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    memberId = json['memberId'];
    avatar = json['avatar'] !=null && !json['avatar'].contains("http") ? Helper.baseURL + json['avatar'] : json['avatar'];
    userName = json['userName'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    amount = json['amount'];
    joinedDate = json['joinedDate'];
    created = json['created'];
    joiningFeePeriod = json['joiningFeePeriod'];
    notes = json['notes'];
  }
}
