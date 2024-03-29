import 'package:conecapp/common/helper.dart';

class Sport {
  String postId;
  String title;
  String description;
  String approvedDate;
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
      this.approvedDate,
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
    approvedDate = Helper.formatData(json['approvedDate']);
    owner = json['owner'];
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
  }
}
