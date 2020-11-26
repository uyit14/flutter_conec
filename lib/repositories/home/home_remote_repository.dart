import 'dart:convert';

import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/avatar_response.dart';
import 'package:conecapp/models/response/comment/comment_response.dart';
import 'package:conecapp/models/response/delete_response.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/models/response/latest_item.dart';
import 'package:conecapp/models/response/latest_response.dart';
import 'package:conecapp/models/response/nearby_club_response.dart';
import 'package:conecapp/models/response/nearby_response.dart';
import 'package:conecapp/models/response/news.dart';
import 'package:conecapp/models/response/news_reponse.dart';
import 'package:conecapp/models/response/notify/notify_response.dart';
import 'package:conecapp/models/response/notify/number_response.dart';
import 'package:conecapp/models/response/page/page_response.dart';
import 'package:conecapp/models/response/slider.dart';
import 'package:conecapp/models/response/slider_response.dart';
import 'package:conecapp/models/response/sport.dart';
import 'package:conecapp/models/response/sport_response.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/models/response/topic_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<List<LatestItem>> fetchLatestItem() async {
    final response = await _helper.get("/api/hottopic/post");
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
      String keyword}) async {
    final response = await _helper.get(
        '/api/Post/GetAll?page=$page&province=${province ?? ""}&district=${district ?? ""}&topic=${topic ?? ""}&club=${club ?? ""}&keyword=${keyword ?? ""}');
    return LatestResponse.fromJson(response).items;
  }

  Future<ItemDetail> fetchItemDetail(String postId) async {
    String _queryEnPoint = await Helper.token()!=null ? "GetWithLogin" : "Get";
    final response = await _helper.get('/api/Post/$_queryEnPoint?id=$postId');
    return ItemDetailResponse.fromJson(response).itemDetail;
  }

  Future<List<Comment>> fetchComments(String postId) async {
    String _queryEnPoint = await Helper.token()!=null ? "getCommentsWithLogin" : "getComments";
    final response =
        await _helper.get('/api/Comment/$_queryEnPoint?postId=$postId');
    return CommentResponse.fromJson(response).comments;
  }

  Future<Comment> postComment(dynamic body) async {
    final response = await _helper.post("/api/Comment/postComment",
        body: body, headers: await Helper.header());
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
    return response['status'];
  }

  Future<NearbyResponse> fetchNearBy(
      double lat, double lng, int distance) async {
    final response = await _helper
        .get('/api/NearBy/GetAll?lat=$lat&lng=$lng&distance=$distance');
    return NearbyResponse.fromJson(response);
  }

  Future<List<LatestItem>> fetchNearByClub(double lat, double lng) async {
    final response = await _helper.get('/api/Post/GetPriorities');
    return LatestResponse.fromJson(response).items;
  }

  Future<PageResponse> fetchPageIntroduce(String clubId) async {
    final response = await _helper.get("/api/Club/Details?id=$clubId");
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
}
