import 'package:conecapp/models/response/chat/conversations_response.dart';

class ConversationResponse {
  bool isNew;
  Conversation conversation;

  ConversationResponse({this.isNew, this.conversation});

  ConversationResponse.fromJson(Map<String, dynamic> json) {
    isNew = json['is_new'];
    conversation = json['conversation'] != null
        ? new Conversation.fromJson(json['conversation'])
        : null;
  }

}

