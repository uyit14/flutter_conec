import 'package:conecapp/common/helper.dart';

class MyPostResponse {
  List<MyPost> myPosts;

  MyPostResponse({this.myPosts});

  MyPostResponse.fromJson(Map<String, dynamic> json) {
    if (json['posts'] != null) {
      myPosts = new List<MyPost>();
      json['posts'].forEach((v) {
        myPosts.add(new MyPost.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.myPosts != null) {
      data['posts'] = this.myPosts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MyPost {
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

  MyPost(
      {this.postId,
        this.title,
        this.description,
        this.joiningFee,
        this.approvedDate,
        this.owner,
        this.thumbnail,
        this.topic,
        this.topicMetaLink,
        this.metaLink});

  MyPost.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    joiningFee = json['joiningFee'];
    approvedDate = Helper.formatData(json['approvedDate']);
    owner = json['owner'];
    thumbnail = json['thumbnail'] !=null ? "http://149.28.140.240:8088" + json['thumbnail'] : null;
    topic = json['topic'];
    topicMetaLink = json['topicMetaLink'];
    metaLink = json['metaLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['joiningFee'] = this.joiningFee;
    data['approvedDate'] = this.approvedDate;
    data['owner'] = this.owner;
    data['thumbnail'] = this.thumbnail;
    data['topic'] = this.topic;
    data['topicMetaLink'] = this.topicMetaLink;
    data['metaLink'] = this.metaLink;
    return data;
  }
}