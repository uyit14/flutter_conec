import 'package:conecapp/common/helper.dart';

class NotifyResponse {
  List<Notify> notifyList;

  NotifyResponse({this.notifyList});

  NotifyResponse.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      notifyList = new List<Notify>();
      json['items'].forEach((v) {
        notifyList.add(new Notify.fromJson(v));
      });
    }
  }
}

class Notify {
  String id;
  String type;
  String title;
  String content;
  String createdDate;
  String createdBy;
  String link;
  bool read;
  String readText;

  Notify(
      {this.id,
        this.type,
        this.title,
        this.content,
        this.createdDate,
        this.createdBy,
        this.link,
        this.read,
        this.readText});

  Notify.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    content = json['content'];
    createdDate = Helper.formatNotifyDate(json['createdDate']);
    createdBy = json['createdBy'];
    link = json['link'];
    read = json['read'];
    readText = json['read_Text'];
  }
}