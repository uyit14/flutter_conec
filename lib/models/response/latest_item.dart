import 'package:conecapp/common/helper.dart';

class LatestItem {
  String postId;
  String title;
  String description;
  int joiningFee;
  String publishedDate;
  String owner;
  String thumbnail;
  String topic;
  String topicMetaLink;
  String metaLink;

  LatestItem(
      {this.postId,
      this.title,
      this.description,
      this.joiningFee,
      this.publishedDate,
      this.owner,
      this.thumbnail,
      this.topic,
      this.topicMetaLink,
      this.metaLink});

  LatestItem.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    joiningFee = json['joiningFee'];
    publishedDate = Helper.formatData(json['publishedDate']);
    owner = json['owner'];
    thumbnail = json['thumbnail'] !=null ? "http://149.28.140.240:8088" + json['thumbnail'] : null;
    topic = json['topic'];
    topicMetaLink = json['topicMetaLink'];
    metaLink = json['metaLink'];
  }
}
