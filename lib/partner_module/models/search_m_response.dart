
import 'dart:io';

import 'package:conecapp/common/helper.dart';

class SearchMResponse {
  bool status;
  List<MemberSearch> members;

  SearchMResponse({this.status, this.members});

  SearchMResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['members'] != null) {
      members = new List<MemberSearch>();
      json['members'].forEach((v) {
        members.add(new MemberSearch.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.members != null) {
      data['members'] = this.members.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MemberSearch {
  String userId;
  String userName;
  String email;
  String phoneNumber;
  String name;
  String avatar;
  File avatarSource;

  MemberSearch({this.userId, this.userName, this.email, this.phoneNumber, this.name, this.avatarSource});

  MemberSearch.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    name = json['name'];
    avatar =
    json['avatar'] != null && !json['avatar'].contains("http")
        ? Helper.baseURL + json['avatar']
        : json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;
    data['name'] = this.name;
    return data;
  }
}
