import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/comment/comment_response.dart';
import 'package:conecapp/repositories/home/home_remote_repository.dart';

class CommentBloc{
  HomeRemoteRepository _repository;

  CommentBloc() {
    _repository = HomeRemoteRepository();
  }
  //parent comment
  StreamController<ApiResponse<List<Comment>>> _parentCommentController =
  StreamController();

  Stream<ApiResponse<List<Comment>>> get parentCommentStream =>
      _parentCommentController.stream;

  //parent comment
  StreamController<ApiResponse<List<Comment>>> _childCommentController =
  StreamController();

  Stream<ApiResponse<List<Comment>>> get childCommentStream =>
      _parentCommentController.stream;

  List<Comment> allComment = [];

  void requestComment(String postId) async {
    _parentCommentController.sink.add(ApiResponse.loading());
    try {
      final comments = await _repository.fetchComments(postId);
      allComment.addAll(comments);
      final parentComment = comments.where((element) => element.parent == null).toList();
      _parentCommentController.sink.add(ApiResponse.completed(parentComment));
    } catch (e) {
      _parentCommentController.sink.addError(ApiResponse.error(e.toString()));
    }
  }

  void requestChildComment(String parentId) {
    List<Comment> list = [];
    list.addAll(allComment);
    _childCommentController.sink.add(ApiResponse.loading());
    try {
      final childComment = list.where((element) => element.parent!=null && element.parent == parentId).toList();
      print("childComment: " + childComment.length.toString());
      _childCommentController.sink.add(ApiResponse.completed(childComment));
    } catch (e) {
      _childCommentController.sink.addError(ApiResponse.error(e.toString()));
    }
  }


  void dispose(){
    _parentCommentController.close();
    _childCommentController.close();
  }
}