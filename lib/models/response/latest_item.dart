import 'package:conecapp/common/helper.dart';

class LatestItem {
  String postId;
  String title;
  String description;
  int joiningFee;
  int price;
  String joiningFeePeriod;
  String approvedDate;
  String owner;
  String thumbnail;
  String topic;
  String topicId;
  String topicMetaLink;
  String metaLink;
  String province;
  String district;
  String ward;
  String address;
  num distance;

  LatestItem(
      {this.postId,
      this.title,
      this.description,
      this.joiningFee,
        this.price,
        this.joiningFeePeriod,
      this.approvedDate,
      this.owner,
      this.thumbnail,
      this.topic,
        this.topicId,
      this.topicMetaLink,
      this.metaLink,
        this.province,
        this.district,
        this.ward,
        this.address,
        this.distance
      });

  LatestItem.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    joiningFee = json['joiningFee'];
    price = json['price'];
    joiningFeePeriod = json['joiningFeePeriod'];
    approvedDate = Helper.formatData(json['approvedDate']);
    owner = json['owner'];
    thumbnail = json['thumbnail'] !=null && !json['thumbnail'].contains("http") ? Helper.baseURL + json['thumbnail'] : json['thumbnail'];
    topic = json['topic'];
    topicId = json['topicId'];
    topicMetaLink = json['topicMetaLink'];
    metaLink = json['metaLink'];
    province = json['province'];
    district = json['district'];
    ward = json['ward'];
    address = json['address'];
    distance = json['distance'];
  }
}
