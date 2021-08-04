import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/chat/conversation_response.dart';
import 'package:conecapp/models/response/chat/conversations_response.dart';
import 'package:conecapp/models/response/chat/message_response.dart';
import 'package:conecapp/models/response/chat/send_message_response.dart';
import 'package:conecapp/repositories/chat/chat_repository.dart';

class ChatBloc {
  ChatRepository _repository;

  ChatBloc() {
    _repository = ChatRepository();
  }

  //conversations
  StreamController<ApiResponse<List<Conversation>>> _conversationController =
      StreamController();

  Stream<ApiResponse<List<Conversation>>> get conversationStream =>
      _conversationController.stream;

  //conversations
  StreamController<ApiResponse<List<MessageChat>>> _messagesController =
      StreamController();

  Stream<ApiResponse<List<MessageChat>>> get messagesStream =>
      _messagesController.stream;

  //create conversations
  StreamController<ApiResponse<ConversationResponse>>
      _createConversationController = StreamController();

  Stream<ApiResponse<ConversationResponse>> get createConversationStream =>
      _createConversationController.stream;

  //select conversations
  StreamController<ApiResponse<ConversationResponse>>
      _selectConversationController = StreamController();

  Stream<ApiResponse<ConversationResponse>> get selectConversationStream =>
      _selectConversationController.stream;

  void requestGetConversations() async {
    _conversationController.sink.add(ApiResponse.loading());
    final result = await _repository.getConversation();
    if (result != null) {
      _conversationController.sink
          .add(ApiResponse.completed(result.conversations));
    } else {
      _conversationController.sink.addError(ApiResponse.error("Lỗi kết nối"));
    }
  }

  void requestCreateConversation(String memberId, {String postId}) async {
    _createConversationController.sink.add(ApiResponse.loading());
    try {
      final result =
          await _repository.createConversation(memberId, postId: postId);
      if (result != null) {
        _createConversationController.sink.add(ApiResponse.completed(result));
      } else {
        _createConversationController.sink
            .addError(ApiResponse.error("Lỗi kết nối"));
      }
    } catch (e) {
      _createConversationController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void requestGetMessages(String conversationId, int page) async {
    _messagesController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.getMessages(conversationId, page);
      if (result != null) {
        _messagesController.sink.add(ApiResponse.completed(result.messages));
      } else {
        _messagesController.sink.addError(ApiResponse.error("Lỗi kết nối"));
      }
    } catch (e) {
      _messagesController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  Future<int> requestSeenMessage(String conversationId) async {
    final response = await _repository.seenMessage(conversationId);
    return response;
  }

  void requestSelectConversation(String conversationId) async {
    print("enter");
    _selectConversationController.sink.add(ApiResponse.loading());
      print("start call");
      final result = await _repository.selectConversation(conversationId);
      if (result != null) {
        print("success");
        _selectConversationController.sink.add(ApiResponse.completed(result));
      } else {
        print("error");
        _selectConversationController.sink
            .addError(ApiResponse.error("Lỗi kết nối"));
      }
  }

  Future<SendMessageResponse> requestSendMessage(
      String conversationId, String message) async {
    final response = await _repository.sendMessages(conversationId, message);
    return response;
  }

  void dispose() {
    _conversationController?.close();
    _createConversationController?.close();
    _messagesController?.close();
    _selectConversationController?.close();
  }
}
