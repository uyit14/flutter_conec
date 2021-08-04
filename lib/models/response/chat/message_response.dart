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
    createdDate = json['createdDate'];
    content = json['content'];
    ownerId = json['ownerId'];
    ownerName = json['ownerName'];
    ownerAvatar = json['ownerAvatar'];
    createdByCurrentUser = json['createdByCurrentUser'];
  }
}