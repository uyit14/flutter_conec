import 'dart:convert';

import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/models/response/comment/comment_response.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/models/response/latest_item.dart';
import 'package:conecapp/models/response/latest_response.dart';
import 'package:conecapp/models/response/news.dart';
import 'package:conecapp/models/response/news_reponse.dart';
import 'package:conecapp/models/response/slider.dart';
import 'package:conecapp/models/response/slider_response.dart';
import 'package:conecapp/models/response/sport.dart';
import 'package:conecapp/models/response/sport_response.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/models/response/topic_response.dart';
import '../../common/globals.dart' as globals;

class HomeRemoteRepository {
  ApiBaseHelper _helper = ApiBaseHelper();
  static final _header = {
    'authorization': "Bearer ${globals.token}",
    'Content-Type': "application/json"
  };

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

  Future<List<LatestItem>> fetchAllItem(int page) async {
    final response = await _helper.get('/api/Post/GetAll?page=$page');
    return LatestResponse.fromJson(response).items;
  }

  Future<ItemDetail> fetchItemDetail(String postId) async {
    final response = await _helper.get('/api/Post/Get?id=$postId');
    return ItemDetailResponse.fromJson(response).itemDetail;
  }

  Future<List<Comment>> fetchComments(String postId) async {
    final response =
        await _helper.get('/api/Comment/getComments?postId=$postId');
    return CommentResponse.fromJson(response).comments;
  }

  Future<Comment> postComment(dynamic body) async {
    final response = await _helper.post("/api/Comment/postComment",
        body: body, headers: _header);
    return PostCommentResponse.fromJson(response).comments;
  }

  Future<bool> deleteComment(String commentId) async {
    final response = await _helper.post("/api/Comment/deleteComment",
        body: jsonEncode(commentId), headers: _header);
    return response['status'];
  }

  Future<bool> likeComment(String commentId) async{
    final response = await _helper.post("/api/Comment/upvoteComment",
        body: jsonEncode(commentId), headers: _header);
    return response['status'];
  }

  Future<bool> unLikeComment(String commentId) async{
    final response = await _helper.post("/api/Comment/downvoteComment",
        body: jsonEncode(commentId), headers: _header);
    return response['status'];
  }

  Future<bool> ratingPost(dynamic body) async{
    final response = await _helper.post("/api/Comment/postRating",
        body: body, headers: _header);
    return response['status'];
  }

  Future<bool> likePost(String postId) async{
    final response = await _helper.post("/api/Comment/likePost",
        body: jsonEncode(postId), headers: _header);
    return response['status'];
  }
}
