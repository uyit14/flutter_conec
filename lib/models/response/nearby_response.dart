import 'package:conecapp/common/helper.dart';

class NearbyResponse {
  Data data;

  NearbyResponse({this.data});

  NearbyResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  List<Users> users;
  List<Posts> posts;

  Data({this.users, this.posts});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = new List<Users>();
      json['users'].forEach((v) {
        users.add(new Users.fromJson(v));
      });
    }
    if (json['posts'] != null) {
      posts = new List<Posts>();
      json['posts'].forEach((v) {
        posts.add(new Posts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.users != null) {
      data['users'] = this.users.map((v) => v.toJson()).toList();
    }
    if (this.posts != null) {
      data['posts'] = this.posts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  String id;
  String name;
  String avatar;
  String getAddress;
  num lat;
  num lng;
  int ratingCount;
  int ratingAvg;
  String ratingHtml;
  String joinedDate;
  String type;
  String dob;
  String gender;
  String phoneNumber;
  String email;

  Users(
      {this.id,
        this.name,
        this.avatar,
        this.getAddress,
        this.lat,
        this.lng,
        this.ratingCount,
        this.ratingAvg,
        this.ratingHtml,
        this.joinedDate,
        this.type,
        this.dob,
        this.gender,
        this.phoneNumber,
        this.email});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar'];
    getAddress = json['getAddress'];
    lat = json['lat'];
    lng = json['lng'];
    ratingCount = json['ratingCount'];
    ratingAvg = json['ratingAvg'];
    ratingHtml = json['rating_Html'];
    joinedDate = json['joinedDate'];
    type = json['type'];
    dob = json['dob'];
    gender = json['gender'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    data['getAddress'] = this.getAddress;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['ratingCount'] = this.ratingCount;
    data['ratingAvg'] = this.ratingAvg;
    data['rating_Html'] = this.ratingHtml;
    data['joinedDate'] = this.joinedDate;
    data['type'] = this.type;
    data['dob'] = this.dob;
    data['gender'] = this.gender;
    data['phoneNumber'] = this.phoneNumber;
    data['email'] = this.email;
    return data;
  }
}

class Posts {
  String postId;
  String topicId;
  String title;
  String description;
  int joiningFee;
  String approvedDate;
  String owner;
  String thumbnail;
  String topic;
  String topicMetaLink;
  String metaLink;
  String province;
  String district;
  String ward;
  String address;
  String getAddress;
  double lat;
  double lng;
  String type;
  int ratingAvg;
  int ratingCount;

  Posts(
      {this.postId,
        this.topicId,
        this.title,
        this.description,
        this.joiningFee,
        this.approvedDate,
        this.owner,
        this.thumbnail,
        this.topic,
        this.topicMetaLink,
        this.metaLink,
        this.province,
        this.district,
        this.ward,
        this.address,
        this.getAddress,
        this.lat,
        this.lng,
        this.type,
        this.ratingAvg,
        this.ratingCount});

  Posts.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    topicId = json['topicId'];
    title = json['title'];
    description = json['description'];
    joiningFee = json['joiningFee'];
    approvedDate = approvedDate = Helper.formatData(json['approvedDate']);
    owner = json['owner'];
    thumbnail = json['thumbnail'] !=null && !json['thumbnail'].contains("http") ? "http://149.28.140.240:8088" + json['thumbnail'] : json['thumbnail'];
    topic = json['topic'];
    topicMetaLink = json['topicMetaLink'];
    metaLink = json['metaLink'];
    province = json['province'];
    district = json['district'];
    ward = json['ward'];
    address = json['address'];
    getAddress = json['getAddress'];
    lat = json['lat'];
    lng = json['lng'];
    type = json['type'];
    ratingAvg = json['ratingAvg'];
    ratingCount = json['ratingCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['topicId'] = this.topicId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['joiningFee'] = this.joiningFee;
    data['approvedDate'] = this.approvedDate;
    data['owner'] = this.owner;
    data['thumbnail'] = this.thumbnail;
    data['topic'] = this.topic;
    data['topicMetaLink'] = this.topicMetaLink;
    data['metaLink'] = this.metaLink;
    data['province'] = this.province;
    data['district'] = this.district;
    data['ward'] = this.ward;
    data['address'] = this.address;
    data['getAddress'] = this.getAddress;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['type'] = this.type;
    data['ratingAvg'] = this.ratingAvg;
    data['ratingCount'] = this.ratingCount;
    return data;
  }
}