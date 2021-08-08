import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/chat/conversation_response.dart';
import 'package:conecapp/models/response/chat/conversations_response.dart';
import 'package:conecapp/models/response/chat/message_response.dart';
import 'package:conecapp/models/response/chat/send_message_response.dart';

class ChatRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<ConversationsResponse> getConversation() async {
    final response = await _helper.get('/api/Conversation/loadConversations',
        headers: await Helper.header());
    print(response);
    return ConversationsResponse.fromJson(response);
  }

  Future<ConversationsResponse> searchConversation(String query) async {
    final response = await _helper.get('/api/Conversation/loadConversations?p=$query',
        headers: await Helper.header());
    print(response);
    return ConversationsResponse.fromJson(response);
  }

  Future<ConversationResponse> createConversation(String memberId,
      {String postId}) async {
    String params = postId != null ? '&postId=$postId' : "";
    final response = await _helper.post(
        '/api/Conversation/createConversation?memberId=$memberId$params',
        headers: await Helper.header());
    print(response);
    return ConversationResponse.fromJson(response);
  }

  Future<ConversationResponse> createConversationWithMessage(String memberId,
      {String postId, String mess}) async {
    String params = postId != null ? '&postId=$postId&message=$mess' : "";
    final response = await _helper.post(
        '/api/Conversation/createConversationWithMessage?memberId=$memberId$params',
        headers: await Helper.header());
    print(response);
    return ConversationResponse.fromJson(response);
  }

  Future<MessageResponse> getMessages(String conversationId, int page) async {
    final response = await _helper.get(
        '/api/Conversation/loadMessages?conversationId=$conversationId&page=$page',
        headers: await Helper.header());
    print(response);
    return MessageResponse.fromJson(response);
  }

  Future<int> seenMessage(String conversationId) async {
    final response = await _helper.get(
        '/api/Conversation/seenConversation?id=$conversationId',
        headers: await Helper.header());
    print(response);
    return response['status'];
  }

  Future<ConversationResponse> selectConversation(String conversationId) async {
    final response = await _helper.get(
        '/api/Conversation/selectConversation?id=$conversationId',
        headers: await Helper.header());
    print(response);
    return ConversationResponse.fromJson(response);
  }

  Future<SendMessageResponse> sendMessages(String conversationId, String message) async {
    final response = await _helper.post(
        '/api/Conversation/sentMessage?id=$conversationId&message=$message',
        headers: await Helper.header());
    print(response);
    return SendMessageResponse.fromJson(response);
  }
}

//TODO
//loadMessages - missing handle load more
//sentMessage - send OK
//loadMembers
