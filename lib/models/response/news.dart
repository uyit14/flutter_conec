import 'package:conecapp/common/helper.dart';

class News {
  String postId;
  String title;
  String description;
  String publishedDate;
  String owner;
  String thumbnail;
  String topic;
  String topicMetaLink;
  String metaLink;

  News(
      {this.postId,
      this.title,
      this.description,
      this.publishedDate,
      this.owner,
      this.thumbnail,
      this.topic,
      this.topicMetaLink,
      this.metaLink});

  News.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    publishedDate = Helper.formatData(json['publishedDate']);
    owner = json['owner'];
    thumbnail = json['thumbnail'] !=null ? "http://149.28.140.240:8088" + json['thumbnail'] : null;
    topic = json['topic'];
    topicMetaLink = json['topicMetaLink'];
    metaLink = json['metaLink'];
  }
}
