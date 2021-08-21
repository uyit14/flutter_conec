import 'package:conecapp/common/helper.dart';

class Follower2Response {
  bool status;
  List<Follower2> follower2s;

  Follower2Response({this.status, this.follower2s});

  Follower2Response.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['posts'] != null) {
      follower2s = new List<Follower2>();
      json['posts'].forEach((v) {
        follower2s.add(new Follower2.fromJson(v));
      });
    }
  }
}

class Follower2 {
  String postId;
  String title;
  String followedDate;
  int likeCount;
  String thumbnail;
  String metaLink;
  String province;
  String district;
  String ward;
  String address;
  String getAddress;
  String getPartAddress;
  String getFullAddress;
  int imageCount;

  Follower2(
      {this.postId,
        this.title,
        this.followedDate,
        this.likeCount,
        this.thumbnail,
        this.metaLink,
        this.province,
        this.district,
        this.ward,
        this.address,
        this.getAddress,
        this.getPartAddress,
        this.getFullAddress,
        this.imageCount});

  Follower2.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    followedDate = json['followedDate'];
    likeCount = json['likeCount'];
    thumbnail = json['thumbnail'] !=null && !json['thumbnail'].contains("http") ? Helper.baseURL + json['thumbnail'] : json['thumbnail'];
    metaLink = json['metaLink'];
    province = json['province'];
    district = json['district'];
    ward = json['ward'];
    address = json['address'];
    getAddress = json['getAddress'];
    getPartAddress = json['getPartAddress'];
    getFullAddress = json['getFullAddress'];
    imageCount = json['imageCount'];
  }
}