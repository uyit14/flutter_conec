import 'package:conecapp/common/helper.dart';

class News {
  String postId;
  String title;
  String description;
  String approvedDate;
  String owner;
  String thumbnail;
  String topic;
  String topicMetaLink;
  String metaLink;

  News(
      {this.postId,
      this.title,
      this.description,
      this.approvedDate,
      this.owner,
      this.thumbnail,
      this.topic,
      this.topicMetaLink,
      this.metaLink});

  News.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    approvedDate = Helper.formatData(json['approvedDate']);
    owner = json['owner'];
    thumbnail = json['thumbnail'] !=null && !json['thumbnail'].contains("http") ? Helper.baseURL + json['thumbnail'] : json['thumbnail'];
    topic = json['topic'];
    topicMetaLink = json['topicMetaLink'];
    metaLink = json['metaLink'];
  }
}
