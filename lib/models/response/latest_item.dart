import 'package:conecapp/common/helper.dart';

class LatestItem {
  String postId;
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

  LatestItem(
      {this.postId,
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
      });

  LatestItem.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    joiningFee = json['joiningFee'];
    approvedDate = Helper.formatData(json['approvedDate']);
    owner = json['owner'];
    thumbnail = json['thumbnail'] !=null && !json['thumbnail'].contains("http") ? "http://149.28.140.240:8088" + json['thumbnail'] : json['thumbnail'];
    topic = json['topic'];
    topicMetaLink = json['topicMetaLink'];
    metaLink = json['metaLink'];
    province = json['province'];
    district = json['district'];
    ward = json['ward'];
    address = json['address'];
  }
}
