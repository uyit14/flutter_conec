import 'package:conecapp/common/helper.dart';

class PNotifyResponse {
  List<PNotifyLite> pNotifyList;

  PNotifyResponse({this.pNotifyList});

  PNotifyResponse.fromJson(Map<String, dynamic> json) {
    if (json['posts'] != null) {
      pNotifyList = new List<PNotifyLite>();
      json['posts'].forEach((v) {
        pNotifyList.add(new PNotifyLite.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pNotifyList != null) {
      data['posts'] = this.pNotifyList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PNotifyLite {
  String postId;
  String topicId;
  String title;
  String description;
  String approvedDate;
  String owner;
  String thumbnail;
  String type;
  int notificationCount;

  PNotifyLite(
      {this.postId,
        this.topicId,
        this.title,
        this.description,
        this.approvedDate,
        this.owner,
        this.thumbnail,
        this.type,
        this.notificationCount});

  PNotifyLite.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    topicId = json['topicId'];
    title = json['title'];
    description = json['description'];
    approvedDate = Helper.formatNotifyDate(json['approvedDate']);
    owner = json['owner'];
    thumbnail = json['thumbnail'];
    type = json['type'];
    notificationCount = json['notificationCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['topicId'] = this.topicId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['approvedDate'] = this.approvedDate;
    data['owner'] = this.owner;
    data['thumbnail'] = this.thumbnail;
    data['type'] = this.type;
    data['notificationCount'] = this.notificationCount;
    return data;
  }
}