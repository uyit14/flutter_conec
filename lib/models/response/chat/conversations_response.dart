import 'package:conecapp/common/helper.dart';

import 'message_response.dart';

class ConversationsResponse {
  List<Conversation> conversations;

  ConversationsResponse({this.conversations});

  ConversationsResponse.fromJson(Map<String, dynamic> json) {
    if (json['conversations'] != null) {
      conversations = new List<Conversation>();
      json['conversations'].forEach((v) {
        conversations.add(new Conversation.fromJson(v));
      });
    }
  }
}

class Conversation {
  String id;
  String lastMessage;
  String lastMessageDate;
  Member member;
  List<MessageChat> messages;
  bool seen;
  Post post;

  Conversation(
      {this.id,
        this.lastMessage,
        this.lastMessageDate,
        this.member,
        this.messages,
        this.seen,
        this.post});

  Conversation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lastMessage = json['lastMessage'];
    lastMessageDate = json['lastMessageDate'];
    member =
    json['member'] != null ? new Member.fromJson(json['member']) : null;
    if (json['messages'] != null) {
      messages = new List<MessageChat>();
      json['messages'].forEach((v) {
        messages.add(new MessageChat.fromJson(v));
      });
    }
    seen = json['seen'];
    post = json['post'] != null ? new Post.fromJson(json['post']) : null;
  }
}

class Member {
  String memberId;
  String memberName;
  String memberAvatar;
  String address;
  String phoneNumber;
  String email;

  Member(
      {this.memberId,
        this.memberName,
        this.memberAvatar,
        this.address,
        this.phoneNumber,
        this.email});

  Member.fromJson(Map<String, dynamic> json) {
    memberId = json['memberId'];
    memberName = json['memberName'];
    memberAvatar = json['memberAvatar'] !=null && !json['memberAvatar'].contains("http") ? Helper.baseURL + json['memberAvatar'] : json['memberAvatar'];
    address = json['address'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
  }

}

class Post {
  String id;
  String image;
  String joinFee;
  String title;
  String link;

  Post({this.id, this.image, this.joinFee, this.title, this.link});

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'] !=null && !json['image'].contains("http") ? Helper.baseURL + json['image'] : json['image'];
    joinFee = json['joinFee'];
    title = json['title'];
    link = json['link'];
  }
}