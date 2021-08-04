import 'package:conecapp/models/response/chat/message_response.dart';

class SendMessageResponse {
  int status;
  MessageChat message;

  SendMessageResponse({this.status, this.message});

  SendMessageResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'] != null
        ? new MessageChat.fromJson(json['message'])
        : null;
  }
}
