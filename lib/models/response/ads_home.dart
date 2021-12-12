import 'package:conecapp/common/helper.dart';

class AdsHome {
  List<Ads> ads;

  AdsHome({this.ads});

  AdsHome.fromJson(Map<String, dynamic> json) {
    if (json['ads'] != null) {
      ads = new List<Ads>();
      json['ads'].forEach((v) {
        ads.add(new Ads.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.ads != null) {
      data['ads'] = this.ads.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Ads {
  String postId;
  String title;
  String description;
  String approvedDate;
  String owner;
  String ownerId;
  num price;
  String generalCondition;
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
  int ratingAvg;

  Ads(
      {this.postId,
        this.title,
        this.description,
        this.approvedDate,
        this.owner,
        this.ownerId,
        this.price,
        this.generalCondition,
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
        this.ratingAvg});

  Ads.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    approvedDate = Helper.formatData(json['approvedDate']);
    owner = json['owner'];
    ownerId = json['ownerId'];
    price = json['price'];
    generalCondition = json['generalCondition'];
    thumbnail = json['thumbnail'] !=null && !json['thumbnail'].contains("http") ? Helper.baseURL + json['thumbnail'] : json['thumbnail'];
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
    ratingAvg = json['ratingAvg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['approvedDate'] = this.approvedDate;
    data['owner'] = this.owner;
    data['ownerId'] = this.ownerId;
    data['price'] = this.price;
    data['generalCondition'] = this.generalCondition;
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
    data['ratingAvg'] = this.ratingAvg;
    return data;
  }
}