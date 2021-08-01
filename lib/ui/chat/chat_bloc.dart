import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/chat/conversation_response.dart';
import 'package:conecapp/models/response/chat/conversations_response.dart';
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
  StreamController<ApiResponse<ConversationResponse>>
      _createConversationController = StreamController();

  Stream<ApiResponse<ConversationResponse>> get createConversationStream =>
      _createConversationController.stream;

  void requestGetConversations() async {
    _conversationController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.getConversation();
      if (result != null) {
        _conversationController.sink
            .add(ApiResponse.completed(result.conversations));
      } else {
        _conversationController.sink.addError(ApiResponse.error("Lỗi kết nối"));
      }
    } catch (e) {
      _conversationController.sink.add(ApiResponse.error(e.toString()));
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

  void dispose() {
    _conversationController?.close();
    _createConversationController?.close();
  }
}
