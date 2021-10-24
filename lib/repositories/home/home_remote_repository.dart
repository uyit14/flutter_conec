import 'dart:convert';
import 'dart:io';

import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/avatar_response.dart';
import 'package:conecapp/models/response/comment/comment_response.dart';
import 'package:conecapp/models/response/comment/follow_response.dart';
import 'package:conecapp/models/response/delete_response.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/models/response/latest_item.dart';
import 'package:conecapp/models/response/latest_response.dart';
import 'package:conecapp/models/response/member2/follower2_response.dart';
import 'package:conecapp/models/response/member2/member2_detail_response.dart';
import 'package:conecapp/models/response/member2/member2_response.dart';
import 'package:conecapp/models/response/nearby_response.dart';
import 'package:conecapp/models/response/news.dart';
import 'package:conecapp/models/response/news_reponse.dart';
import 'package:conecapp/models/response/notify/notify_response.dart';
import 'package:conecapp/models/response/notify/number_response.dart';
import 'package:conecapp/models/response/page/hidden_response.dart';
import 'package:conecapp/models/response/page/page_response.dart';
import 'package:conecapp/models/response/slider.dart';
import 'package:conecapp/models/response/slider_response.dart';
import 'package:conecapp/models/response/sport.dart';
import 'package:conecapp/models/response/sport_response.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/models/response/topic_response.dart';

class HomeRemoteRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

//  static final _header = {
//    'authorization': "Bearer ${Helper.getToken()}",
//    'Content-Type': "application/json"
//  };

  Future<List<Topic>> fetchTopic() async {
    final response = await _helper.get("/api/topic");
    return TopicResponse.fromJson(response).topics;
  }

  Future<List<Slider>> fetchSlider() async {
    final response = await _helper.get("/api/slider");
    return SliderResponse.fromJson(response).sliders;
  }

  Future<List<LatestItem>> fetchLatestItem(double lat, double lng) async {
    if (lat == null || lng == null) {
      lat = 22.370297;
      lng = 114.173564;
    }
    final response = await _helper.get("/api/hottopic/post?lat=$lat&lng=$lng");
    return LatestResponse.fromJson(response).items;
  }

  Future<List<Sport>> fetchSport() async {
    final response = await _helper.get("/api/hottopic/ads");
    return SportResponse.fromJson(response).sports;
  }

  Future<List<News>> fetchNews() async {
    final response = await _helper.get("/api/hottopic/news");
    return NewsResponse.fromJson(response).news;
  }

  Future<List<LatestItem>> fetchAllItem(int page,
      {String province,
      String district,
      String topic,
      String club,
      String subTopic,
      String keyword}) async {
    final response = await _helper.get(
        '/api/Post/GetAll?page=$page&province=${province ?? ""}&district=${district ?? ""}&topic=${topic ?? ""}&club=${club ?? ""}&sub_topic=${subTopic ?? ""}&keyword=${keyword ?? ""}');
    return LatestResponse.fromJson(response).items;
  }

  Future<ItemDetail> fetchItemDetail(String postId) async {
    String _queryEnPoint =
        await Helper.token() != null ? "GetWithLogin" : "Get";
    dynamic _header =
        await Helper.token() != null ? await Helper.header() : null;
    final response = await _helper.get('/api/Post/$_queryEnPoint?id=$postId',
        headers: _header);
    return ItemDetailResponse.fromJson(response).itemDetail;
  }

//  Future<String> fetchItemDetailOnlyOwnerId(String postId) async {
//    String _queryEnPoint =
//    await Helper.token() != null ? "GetWithLogin" : "Get";
//    dynamic _header =
//    await Helper.token() != null ? await Helper.header() : null;
//    final response = await _helper.get('/api/Post/$_queryEnPoint?id=$postId',
//        headers: _header);
//    final post = response['post'];
//    return post['ownerId'];
//  }

  Future<List<Comment>> fetchComments(String postId) async {
    String _queryEnPoint =
        await Helper.token() != null ? "getCommentsWithLogin" : "getComments";
    dynamic _header =
        await Helper.token() != null ? await Helper.header() : null;
    final response = await _helper
        .get('/api/Comment/$_queryEnPoint?postId=$postId', headers: _header);
    return CommentResponse.fromJson(response).comments;
  }

  Future<Comment> postComment(dynamic body) async {
    final response = await _helper.post("/api/Comment/postComment",
        body: body, headers: await Helper.header());
    print(response);
    return PostCommentResponse.fromJson(response).comments;
  }

  Future<bool> deleteComment(String commentId) async {
    final response = await _helper.post("/api/Comment/deleteComment",
        body: jsonEncode(commentId), headers: await Helper.header());
    return response['status'];
  }

  Future<bool> likeComment(String commentId) async {
    final response = await _helper.post("/api/Comment/upvoteComment",
        body: jsonEncode(commentId), headers: await Helper.header());
    return response['status'];
  }

  Future<bool> unLikeComment(String commentId) async {
    final response = await _helper.post("/api/Comment/downvoteComment",
        body: jsonEncode(commentId), headers: await Helper.header());
    return response['status'];
  }

  Future<bool> ratingPost(dynamic body) async {
    final response = await _helper.post("/api/Comment/postRating",
        body: body, headers: await Helper.header());
    return response['status'];
  }

  //TODO - need update rating url
  Future<bool> ratingClub(dynamic body) async {
    final response = await _helper.post("/api/club/userRating",
        body: body, headers: await Helper.header());
    return response['status'];
  }

  Future<AvatarResponse> getUserAvatar() async {
    final response = await _helper.post("/api/account/GetAvatar",
        headers: await Helper.header());
    print(response);
    return AvatarResponse.fromJson(response);
  }

  Future<bool> likePost(String postId) async {
    final response = await _helper.post("/api/Comment/likePost?id=$postId",
        headers: await Helper.header());
    print(response);
    return response['status'];
  }

  Future<NearbyResponse> fetchNearBy(
      double lat, double lng, int distance) async {
    if (lat == null || lng == null) {
      lat = 22.370297;
      lng = 114.173564;
    }
    final response = await _helper.get(
        '/api/NearBy/GetAll?lat=$lat&lng=$lng&distance=$distance',
        headers: Helper.headerNoToken);
    return NearbyResponse.fromJson(response);
  }

  Future<List<LatestItem>> fetchNearByClub(double lat, double lng) async {
    final response = await _helper.get('/api/Post/GetPriorities');
    return LatestResponse.fromJson(response).items;
  }

  Future<PageResponse> fetchPageIntroduce(String clubId) async {
    final response = await _helper.get("/api/Club/Details?id=$clubId",
        headers: await Helper.header());
    print(response);
    return PageResponse.fromJson(response);
  }

  Future<NotifyResponse> getAllNotify(int page) async {
    final response = await _helper.get('/api/Notify/GetAll?page=$page',
        headers: await Helper.header());
    print(response);
    return NotifyResponse.fromJson(response);
  }

  Future<NumberResponse> getNumberNotify() async {
    final response = await _helper.get('/api/Notify/NotifyCounter',
        headers: await Helper.header());
    print(response);
    return NumberResponse.fromJson(response);
  }

  Future<DeleteResponse> deleteOrReadNotify(
      String notifyId, String type) async {
    final response = await _helper.post('/api/Notify/$type?id=$notifyId',
        body: jsonEncode({"id": notifyId}), headers: await Helper.header());
    print(response);
    return DeleteResponse.fromJson(response);
  }

  Future<bool> reportPost(String postId, String content, String reason) async {
    final response = await _helper.post('/api/Post/reportPost',
        headers: await Helper.header(),
        body: jsonEncode(
            {'postId': postId, 'content': content, 'reason': reason}));
    print(response);
    return response['status'];
  }

  Future<bool> giftCheck() async {
    final response = await _helper.get("/api/GiftCard/Check",
        headers: await Helper.header());
    print("giftCheck" + response.toString());
    return response['status'];
  }

  Future<bool> giftReceive() async {
    final response = await _helper.get("/api/GiftCard/Receive",
        headers: await Helper.header());
    print("giftReceive" + response.toString());
    return response['status'];
  }

  Future<HiddenResponse> getHidden(String ownerId, String userId) async {
    final response = await _helper.get(
        "/api/account/ShowProfileDetail?ownerId=$ownerId&userId=$userId",
        headers: await Helper.header());
    print("getHidden" + response.toString());
    return HiddenResponse.fromJson(response);
  }

  Future<HiddenResponse> getHiddenPostInfo(
      String ownerId, String userId, String postId) async {
    final response = await _helper.get(
        "/api/post/ShowPostContact?ownerId=$ownerId&userId=$userId&postId=$postId",
        headers: await Helper.header());
    print("getHiddenPostInfo" + response.toString());
    return HiddenResponse.fromJson(response);
  }

  Future<String> registerDeviceToken(String deviceToken, String userId) async {
    String userIdQuery = "";
    if (userId.length > 0) {
      userIdQuery = "&userId=$userId";
    }

    final response = await _helper.get(
        "/api/Account/UpdateOneSignalToken?token=$deviceToken$userIdQuery",
        headers: await Helper.header());
    print("registerDeviceTokenResponse: " + response.toString());
    return response['status'];
  }

  Future<String> getAppVersion() async {
    final response = await _helper.get("/api/ConfigSetting/GetAppVersion",
        headers: Helper.headerNoToken);
    print(response.toString());
    if (Platform.isIOS) {
      return response['iOS_Version'];
    }
    return response['android_Version'];
  }

  Future<FollowResponse> fetFollower(String postId) async {
    final response = await _helper.get("/api/post/GetFollows?id=$postId&page=1",
        headers: await Helper.header());
    print("getFollower: " + response.toString());
    return FollowResponse.fromJson(response);
  }

  //for chat
  Future<String> getConversationCounter() async {
    final response = await _helper.get(
        '/api/Conversation/loadConversationCounter',
        headers: await Helper.header());
    print(response);
    return response['conversation_counter'];
  }

  Future<Member2Response> getMember2s(int page) async {
    final response = await _helper.get(
        '/api/MemberJoined/LoadMembers?page=$page',
        headers: await Helper.header());
    print(response);
    return Member2Response.fromJson(response);
  }

  Future<Follower2Response> getFollower2s(int page) async {
    final response = await _helper.get(
        '/api/MemberJoined/LoadFollows?page=$page',
        headers: await Helper.header());
    print(response);
    return Follower2Response.fromJson(response);
  }

  Future<Member2DetailResponse> fetMember2Detail(String id) async {
    final response = await _helper.get("/api/MemberJoined/ViewMember?id=$id",
        headers: await Helper.header());
    print(response.toString());
    return Member2DetailResponse.fromJson(response);
  }

  Future<Member2DetailResponse> fetMember3Detail(String id) async {
    final response = await _helper.get("/api/MemberJoined/ViewRequest?id=$id",
        headers: await Helper.header());
    print(response.toString());
    return Member2DetailResponse.fromJson(response);
  }

  Future<bool> acceptInvite(String id) async {
    final response = await _helper.post(
        "/api/MemberJoined/AcceptedRequest?id=$id",
        headers: await Helper.header());
    print("acceptInvite" + response.toString());
    return response['status'];
  }

  Future<bool> rejectInvite(String id) async {
    final response = await _helper.post(
        "/api/MemberJoined/CancelRequest?id=$id",
        headers: await Helper.header());
    print("rejectInvite" + response.toString());
    return response['status'];
  }

  Future<bool> requestMember(dynamic body) async {
    final response = await _helper.post("/api/Club/requestMember",
        body: body, headers: await Helper.header());
    print("requestMember" + response.toString());
    return response['status'];
  }
}
