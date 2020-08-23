import 'package:conecapp/common/helper.dart';

class Sport {
  String postId;
  String title;
  String description;
  String publishedDate;
  String owner;
  int price;
  String generalCondition;
  String thumbnail;
  String topic;
  String topicMetaLink;
  String metaLink;
  String province;
  String district;
  String ward;
  String address;

  Sport(
      {this.postId,
      this.title,
      this.description,
      this.publishedDate,
      this.owner,
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
      });

  Sport.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    publishedDate = Helper.formatData(json['publishedDate']);
    owner = json['owner'];
    price = json['price'];
    generalCondition = json['generalCondition'];
    thumbnail = json['thumbnail'] !=null ? "http://149.28.140.240:8088" + json['thumbnail'] : null;
    topic = json['topic'];
    topicMetaLink = json['topicMetaLink'];
    metaLink = json['metaLink'];
    province = json['province'];
    district = json['district'];
    ward = json['ward'];
    address = json['address'];
  }
}
