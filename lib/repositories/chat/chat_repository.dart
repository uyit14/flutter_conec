import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/chat/conversation_response.dart';
import 'package:conecapp/models/response/chat/conversations_response.dart';

class ChatRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<ConversationsResponse> getConversation() async {
    final response = await _helper.get('/api/Conversation/loadConversations',
        headers: await Helper.header());
    print(response);
    return ConversationsResponse.fromJson(response);
  }

  Future<ConversationResponse> createConversation(String memberId,
      {String postId}) async {
    String params = postId != null ? '&$postId' : "";
    final response = await _helper.post(
        '/api/Conversation/createConversation?memberId=$memberId$params',
        headers: await Helper.header());
    print(response);
    return ConversationResponse.fromJson(response);
  }
}
