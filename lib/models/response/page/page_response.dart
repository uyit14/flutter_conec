import 'package:conecapp/common/helper.dart';

class PageResponse {
  bool status;
  String error;
  Profile profile;

  PageResponse({this.status, this.error, this.profile});

  PageResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    profile =
    json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['error'] = this.error;
    if (this.profile != null) {
      data['profile'] = this.profile.toJson();
    }
    return data;
  }
}

class Profile {
  String id;
  String name;
  String email;
  String avatar;
  String gender;
  String dob;
  String phoneNumber;
  String type;
  String province;
  String district;
  String ward;
  String address;
  String getAddress;
  num lat;
  num lng;
  num ratingAvg;
  num ratingCount;
  String about;
  String videoLink;
  List<Images> images;
  List<Posts> posts;

  Profile(
      {this.id,
        this.name,
        this.email,
        this.avatar,
        this.gender,
        this.dob,
        this.phoneNumber,
        this.type,
        this.province,
        this.district,
        this.ward,
        this.address,
        this.getAddress,
        this.lat,
        this.lng,
        this.ratingAvg,
        this.ratingCount,
        this.about,
        this.videoLink,
        this.images,
        this.posts});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    avatar = json['avatar'] == null ? null : Helper.baseURL + json['avatar'];
    gender = json['gender'];
    dob = json['dob'] == null ? null : Helper.formatDob(json['dob']);
    phoneNumber = json['phoneNumber'];
    type = json['type'];
    province = json['province'];
    district = json['district'];
    ward = json['ward'];
    address = json['address'];
    getAddress = json['getAddress'];
    lat = json['lat'];
    lng = json['lng'];
    ratingAvg = json['ratingAvg'];
    ratingCount = json['ratingCount'];
    about = json['about'];
    videoLink = json['videoLink'] !=null ? Helper.baseURL + json['videoLink'] : null;
    if (json['images'] != null) {
      images = new List<Images>();
      json['images'].forEach((v) {
        images.add(new Images.fromJson(v));
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
    data['name'] = this.name;
    data['email'] = this.email;
    data['avatar'] = this.avatar;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['phoneNumber'] = this.phoneNumber;
    data['type'] = this.type;
    data['province'] = this.province;
    data['district'] = this.district;
    data['ward'] = this.ward;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['ratingAvg'] = this.ratingAvg;
    data['about'] = this.about;
    data['videoLink'] = this.videoLink;
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
    if (this.posts != null) {
      data['posts'] = this.posts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Images {
  String id;
  String fileName;

  Images({this.id, this.fileName});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fileName = json['fileName'] !=null ? Helper.baseURL + json['fileName'] : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['fileName'] = this.fileName;
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
  num lat;
  num lng;
  String type;
  num ratingAvg;
  num ratingCount;

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
    approvedDate = json['approvedDate'];
    owner = json['owner'];
    thumbnail = json['thumbnail'] !=null ? Helper.baseURL + json['thumbnail'] : null;
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