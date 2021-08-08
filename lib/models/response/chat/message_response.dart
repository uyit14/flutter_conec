import 'package:conecapp/common/helper.dart';

class MessageResponse {
  int page;
  List<MessageChat> messages;

  MessageResponse({this.page, this.messages});

  MessageResponse.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    if (json['messages'] != null) {
      messages = new List<MessageChat>();
      json['messages'].forEach((v) {
        messages.add(new MessageChat.fromJson(v));
      });
    }
  }
}

class MessageChat {
  String id;
  String conversationId;
  String createdDate;
  String content;
  String ownerId;
  String ownerName;
  String ownerAvatar;
  bool createdByCurrentUser;

  MessageChat(
      {this.id,
        this.conversationId,
        this.createdDate,
        this.content,
        this.ownerId,
        this.ownerName,
        this.ownerAvatar,
        this.createdByCurrentUser});

  MessageChat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversationId'];
    //2021-08-08T16:18:17.9538464+07:00
    //2021-08-08T16:18:17.9538464
    createdDate = Helper.formatNotifyDate(json['createdDate']);
    content = json['content'];
    ownerId = json['ownerId'];
    ownerName = json['ownerName'];
    ownerAvatar = json['ownerAvatar'];
    createdByCurrentUser = json['createdByCurrentUser'];
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (conversationId != null) 'conversationId': conversationId,
    if (createdDate != null) 'createdDate': createdDate,
    if (content != null) 'content': content,
    if (ownerId != null) 'ownerId': ownerId,
    if (ownerName != null) 'ownerName': ownerName,
    if (ownerAvatar != null) 'ownerAvatar': ownerAvatar,
    if (createdByCurrentUser != null) 'createdByCurrentUser': createdByCurrentUser,
  };
}