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
  num lat;
  num lng;
  int ratingAvg;
  int ratingAvg2;

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
        this.ratingAvg2,
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
    ratingAvg2 = json['ratingAvg2'];
  }
}