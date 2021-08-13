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
  StreamController<ApiResponse<List<Conversation>>> _searchConversationController =
  StreamController();

  Stream<ApiResponse<List<Conversation>>> get searchConversationStream =>
      _searchConversationController.stream;

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

  //create conversations with mess
  StreamController<ApiResponse<ConversationResponse>>
  _createConversationWithMessageController = StreamController();

  Stream<ApiResponse<ConversationResponse>> get createConversationWithMessageStream =>
      _createConversationWithMessageController.stream;

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

  void requestSearchGetConversations(String query) async {
    _searchConversationController.sink.add(ApiResponse.loading());
    final result = await _repository.searchConversation(query);
    if (result != null) {
      _searchConversationController.sink
          .add(ApiResponse.completed(result.conversations));
    } else {
      _searchConversationController.sink.addError(ApiResponse.error("Lỗi kết nối"));
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

  void requestCreateConversationWithMessage(String memberId, {String postId, String mess}) async {
    _createConversationWithMessageController.sink.add(ApiResponse.loading());
    try {
      final result =
      await _repository.createConversationWithMessage(memberId, postId: postId, mess: mess);
      if (result != null) {
        _createConversationWithMessageController.sink.add(ApiResponse.completed(result));
      } else {
        _createConversationWithMessageController.sink
            .addError(ApiResponse.error("Lỗi kết nối"));
      }
    } catch (e) {
      _createConversationWithMessageController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void requestGetMessages(String conversationId, int page) async {
    print('page $page');
    _messagesController.sink.add(ApiResponse.completed([]));
    try {
      final result = await _repository.getMessages(conversationId, page);
      if (result != null) {
        _messagesController.sink.add(ApiResponse.completed(result.messages.reversed.toList()));
        print("sink page $page ${result.messages.length}");
      } else {
        _messagesController.sink.addError(ApiResponse.error("Lỗi kết nối"));
      }
    } catch (e) {
      _messagesController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  /*
  void requestGetNotify(int page) async {
    print('page $page');
    _notifyController.sink.add(ApiResponse.completed([]));
    try {
      final result = await _repository.getPartnerNotifies(page);
      print("sink page $page ${result.pNotifyList.length}");
      _notifyController.sink.add(ApiResponse.completed(result.pNotifyList));
    } catch (e) {
      _notifyController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }
  */

  Future<int> requestSeenMessage(String conversationId) async {
    final response = await _repository.seenMessage(conversationId);
    return response;
  }

  Future<bool> requestDeleteConversation(String conversationId) async {
    final response = await _repository.deleteConversation(conversationId);
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
    _createConversationWithMessageController?.close();
    _searchConversationController?.close();
  }
}
