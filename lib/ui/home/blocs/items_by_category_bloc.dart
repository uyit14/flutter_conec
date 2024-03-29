import 'dart:async';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/comment/comment_response.dart';
import 'package:conecapp/models/response/comment/follow_response.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/models/response/latest_item.dart';
import 'package:conecapp/models/response/page/hidden_response.dart';
import 'package:conecapp/repositories/home/home_remote_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:tiengviet/tiengviet.dart';

class ItemsByCategoryBloc {
  HomeRemoteRepository _repository;

  ItemsByCategoryBloc() {
    _repository = HomeRemoteRepository();
  }

  List<LatestItem> _originalItems = List<LatestItem>();

  //all item
  StreamController<ApiResponse<String>> _avatarController = StreamController();

  Stream<ApiResponse<String>> get avatarStream => _avatarController.stream;

  //all item
  StreamController<ApiResponse<List<LatestItem>>> _allItemController =
      StreamController();

  Stream<ApiResponse<List<LatestItem>>> get allItemStream =>
      _allItemController.stream;

  //item detail
  StreamController<ApiResponse<ItemDetail>> _itemDetailController =
      StreamController();

  Stream<ApiResponse<ItemDetail>> get itemDetailStream =>
      _itemDetailController.stream;

  //item detail
  StreamController<ApiResponse<ItemDetail>> _itemDetailController2 =
  StreamController();

  Stream<ApiResponse<ItemDetail>> get itemDetailStream2 =>
      _itemDetailController2.stream;

  //follower
  StreamController<ApiResponse<List<Follower>>> _followerController =
      StreamController.broadcast();

  Stream<ApiResponse<List<Follower>>> get followerStream =>
      _followerController.stream;

  //
  final List<Comment> allComments = List();

  //parent comment
  StreamController<ApiResponse<List<Comment>>> _parentCommentController =
      StreamController();

  Stream<ApiResponse<List<Comment>>> get parentCommentStream =>
      _parentCommentController.stream;
  List<Comment> parentComment = List();

//  //child by parent id
//  StreamController<List<Comment>> _childCommentController =
//  StreamController();
//
//  Stream<List<Comment>> get childCommentStream =>
//      _childCommentController.stream;

  void requestGetAllItem(int page, String subTopic,
      {String province,
      String district,
      String topic,
      String club,
      String keyword}) async {
    _allItemController.sink.add(ApiResponse.completed([]));
    if (page != 1) {
      final items = await _repository.fetchAllItem(page,
          province: province,
          district: district,
          club: club,
          topic: topic,
          keyword: keyword,
          subTopic: subTopic);
      _originalItems.addAll(items);
      _allItemController.sink.add(ApiResponse.completed(items));
    } else {
      //_allItemController.sink.add(ApiResponse.loading());
      _originalItems.clear();
      try {
        final items = await _repository.fetchAllItem(page,
            province: province,
            district: district,
            club: club,
            topic: topic,
            keyword: keyword,
            subTopic: subTopic);
        _originalItems.addAll(items);
        _allItemController.sink.add(ApiResponse.completed(items));
      } catch (e) {
        _allItemController.sink.addError(ApiResponse.error(e.toString()));
        debugPrint(e.toString());
      }
    }
  }

  void requestItemDetail(String postId) async {
    _itemDetailController.sink.add(ApiResponse.loading());

    final itemDetail = await _repository.fetchItemDetail(postId);
    _itemDetailController.sink.add(ApiResponse.completed(itemDetail));
    _itemDetailController2.sink.add(ApiResponse.completed(itemDetail));
  }

  void requestGetFollower(String postId) async {
    final result = await _repository.fetFollower(postId);
    if (result.status)
      _followerController.sink.add(ApiResponse.completed(result.followers));
  }

//  Future<String> requestItemDetailOnly(String postId) async {
//    final ownerId = await _repository.fetchItemDetailOnlyOwnerId(postId);
//    return ownerId;
//  }

  void requestGetAvatar() async {
    _avatarController.sink.add(ApiResponse.loading());
    final avatar = await _repository.getUserAvatar();
    if (avatar.status) {
      _avatarController.sink.add(ApiResponse.completed(avatar.avatar));
    } else {
      _avatarController.sink.addError(ApiResponse.error(avatar.error));
    }
  }

  void requestComment(String postId) async {
    _parentCommentController.sink.add(ApiResponse.loading());
    try {
      final comments = await _repository.fetchComments(postId);
      allComments.addAll(comments);
      parentComment =
          comments.where((element) => element.parent == null).toList();
      debugPrint("parentComment: " + parentComment.length.toString());
      debugPrint("all: " + allComments.length.toString());
      _parentCommentController.sink.add(ApiResponse.completed(parentComment));
    } catch (e) {
      _parentCommentController.sink.addError(ApiResponse.error(e.toString()));
    }
  }

  Future<bool> requestDeleteComment(String commentId) async {
    final response = await _repository.deleteComment(commentId);
    print("bloc delete at: " +
        parentComment
            .indexWhere((element) => element.id == commentId)
            .toString());
    print("with id: " + commentId);
    print("item deleted: " + parentComment[0].content);
    print("item deleted 2: " +
        parentComment[
                parentComment.indexWhere((element) => element.id == commentId)]
            .content);
    parentComment.removeWhere((element) => element.id == commentId);
    _parentCommentController.sink.add(ApiResponse.completed(parentComment));
    return response;
  }

  Future<bool> requestLikeComment(String commentId) async {
    final response = await _repository.likeComment(commentId);
    return response;
  }

  Future<bool> requestUnLikeComment(String commentId) async {
    final response = await _repository.unLikeComment(commentId);
    return response;
  }

  Future<bool> requestLikePost(String postId) async {
    final response = await _repository.likePost(postId);
    return response;
  }

  Future<bool> requestRating(dynamic body) async {
    final response = await _repository.ratingPost(body);
    return response;
  }

  Future<Comment> requestPostComment(dynamic body) async {
    //parentComment = List();
    Comment result = await _repository.postComment(body);
    return result;
//    if(result.content!=null){
//      allComments.add(result);
//      if(result.parent == null){
//        parentComment.add(result);
//        debugPrint("cmd: " + parentComment[0].content);
//        _parentCommentController.sink.add(ApiResponse.completed(parentComment));
//      }else{
//        print("add comment");
//      }
//    }
//
//    if (result.content != null) return true;
//    return false;
  }

  void clearSearch() {
    _allItemController.sink.add(ApiResponse.completed(_originalItems));
  }

  void searchAction(String keyWord) {
    List<LatestItem> _searchResult = List<LatestItem>();
    _originalItems.forEach((item) {
      if (_search(item, keyWord)) {
        print(item.title);
        _searchResult.add(item);
      }
    });
    _allItemController.sink.add(ApiResponse.completed(_searchResult));
  }

  bool _search(LatestItem item, String txtSearch) {
    if (TiengViet.parse(item.title)
        .toLowerCase()
        .contains(txtSearch.toLowerCase())) {
      return true;
    }
    return false;
  }

  Future<HiddenResponse> requestHiddenPostInfo(
      String ownerId, String userId, String postId) async {
    final response =
        await _repository.getHiddenPostInfo(ownerId, userId, postId);
    return response;
  }

  void dispose() {
    _allItemController?.close();
    _itemDetailController?.close();
    _parentCommentController?.close();
    _avatarController?.close();
    _followerController?.close();
    _itemDetailController2?.close();
    //_childCommentController?.close();
  }
}
