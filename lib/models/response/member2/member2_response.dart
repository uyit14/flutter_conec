import 'package:conecapp/common/helper.dart';

import '../topic.dart';

class Member2Response {
  bool status;
  List<Member2> member2;

  Member2Response({this.status, this.member2});

  Member2Response.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['users'] != null) {
      member2 = new List<Member2>();
      json['users'].forEach((v) {
        member2.add(new Member2.fromJson(v));
      });
    }
  }
}

class Member2 {
  String id;
  String title;
  String group;
  String approvedDate;
  String followedDate;
  String thumbnail;
  Topic topic;
  String province;
  String district;
  String ward;
  String address;
  String getAddress;
  String getPartAddress;
  String getFullAddress;

  Member2(
      {this.id,
        this.title,
        this.group,
        this.approvedDate,
        this.followedDate,
        this.thumbnail,
        this.topic,
        this.province,
        this.district,
        this.ward,
        this.address,
        this.getAddress,
        this.getPartAddress,
        this.getFullAddress});

  Member2.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    group = json['group'];
    approvedDate = json['approvedDate'];
    followedDate = json['followedDate'];
    thumbnail = json['thumbnail'] !=null && !json['thumbnail'].contains("http") ? Helper.baseURL + json['thumbnail'] : json['thumbnail'];
    topic = json['topic'];
    province = json['province'];
    district = json['district'];
    ward = json['ward'];
    address = json['address'];
    getAddress = json['getAddress'];
    getPartAddress = json['getPartAddress'];
    getFullAddress = json['getFullAddress'];
  }
}