import 'dart:async';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/comment/comment_response.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/models/response/latest_item.dart';
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
  StreamController<ApiResponse<List<LatestItem>>> _allItemController =
      StreamController();

  Stream<ApiResponse<List<LatestItem>>> get allItemStream =>
      _allItemController.stream;

  //item detail
  StreamController<ApiResponse<ItemDetail>> _itemDetailController =
      StreamController();

  Stream<ApiResponse<ItemDetail>> get itemDetailStream =>
      _itemDetailController.stream;
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

  void requestGetAllItem(int page, {String province, String district, String topic, String club}) async {
    if(page != 0){
      final items = await _repository.fetchAllItem(page, province: province, district: district, club: club, topic: topic);
      _originalItems.addAll(items);
      _allItemController.sink.add(ApiResponse.completed(items));
    }else{
      _allItemController.sink.add(ApiResponse.loading());
      try {
        final items = await _repository.fetchAllItem(page, province: province, district: district, club: club, topic: topic);
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
    try {
      final itemDetail = await _repository.fetchItemDetail(postId);
      _itemDetailController.sink.add(ApiResponse.completed(itemDetail));
    } catch (e) {
      print(e.toString());
      _itemDetailController.sink.addError(ApiResponse.error(e.toString()));
    }
  }

  void requestComment(String postId) async {
    _parentCommentController.sink.add(ApiResponse.loading());
    try {
      final comments = await _repository.fetchComments(postId);
      allComments.addAll(comments);
      parentComment = comments.where((element) => element.parent == null).toList();
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
    print("item deleted 2: " + parentComment[parentComment.indexWhere((element) => element.id == commentId)].content);
    parentComment.removeWhere((element) => element.id==commentId);
    _parentCommentController.sink.add(ApiResponse.completed(parentComment));
    return response;
  }

  Future<bool> requestLikeComment(String commentId) async{
    final response = await _repository.likeComment(commentId);
    return response;
  }

  Future<bool> requestUnLikeComment(String commentId) async{
    final response = await _repository.unLikeComment(commentId);
    return response;
  }

  Future<bool> requestLikePost(String postId) async{
    final response = await _repository.likePost(postId);
    return response;
  }

  Future<bool> requestRating(dynamic body) async{
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

//  void requestCommentByParentId(String parentID) async{
//    final childList = allComments.where((element) => element.parent == parentID).toList();
//
//    if(childList.length > 0){
//      debugPrint("parentID: " + parentID + "------" + "childList: " + childList.length.toString());
//      _childCommentController.sink.add(childList);
//    }
//  }

//  //
//  List<String> _totalList = List();
//
//  void requestLoadList(bool isLoadMore) async {
//    if (!isLoadMore)
//      _itemController.sink.add(ApiResponse.loading("Loading..."));
//    List<String> imgList = List();
//    int currentLengthList = _totalList.length;
//    try {
//      if (!isLoadMore) {
//        imgList = DummyData.imgListLoadmore.sublist(currentLengthList, 6);
//      } else {
//        if (currentLengthList < DummyData.imgListLoadmore.length) {
//          imgList = DummyData.imgListLoadmore.sublist(
//              currentLengthList,
//              currentLengthList + 6 <= DummyData.imgListLoadmore.length
//                  ? currentLengthList + 6
//                  : DummyData.imgListLoadmore.length);
//        }
//      }
//      _totalList.addAll(imgList);
//      _itemController.sink.add(ApiResponse.completed(_totalList));
//    } on Exception catch (e) {
//      _itemController.sink.addError(ApiResponse.error(e.toString()));
//      debugPrint(e.toString());
//    }
//  }
//
//  void requestSearch(String query) {
//    _itemController.sink.add(ApiResponse.loading("Loading..."));
//    List<String> _searchList = List();
//    if (query.isNotEmpty) {
//      List<String> dummyListData = List();
//      _totalList.forEach((element) {
//        if (element.toLowerCase().contains(query)) {
//          dummyListData.add(element);
//        }
//      });
//      _searchList.addAll(dummyListData);
//      _itemController.sink.add(ApiResponse.completed(_searchList));
//    } else {
//      _itemController.sink.add(ApiResponse.completed(_totalList));
//    }
//  }
//
//  void requestCancel() {
//    _itemController.sink.add(ApiResponse.completed(_totalList));
//  }

//  void filterByCategory(String topicName){
//    List<LatestItem> _filterResult = List<LatestItem>();
//    _filterResult = _originalItems.where((element) => element.topic.toLowerCase() == topicName).toList();
//    _allItemController.sink.add(ApiResponse.completed(_filterResult));
//  }

  void clearSearch(){
    _allItemController.sink.add(ApiResponse.completed(_originalItems));
  }

  void searchAction(String keyWord){
    List<LatestItem> _searchResult = List<LatestItem>();
    _originalItems.forEach((item) {
      if(_search(item, keyWord)){
        print(item.title);
        _searchResult.add(item);
      }
    });
    _allItemController.sink.add(ApiResponse.completed(_searchResult));
  }
  bool _search(LatestItem item, String txtSearch){
    if (TiengViet.parse(item.title).toLowerCase().contains(txtSearch.toLowerCase())) {
      return true;
    }
    return false;
  }

  // void filterCity(String cityName){
  //   var filterList = _originalItems.where((element) => element.province.toLowerCase() == cityName).toList();
  //   _allItemController.sink.add(ApiResponse.completed(filterList));
  // }
  //
  // void filterDistrict(String districtName){
  //   var filterList = _originalItems.where((element) => element.district.toLowerCase() == districtName || element.district.toLowerCase() == 'quận $districtName').toList();
  //   _allItemController.sink.add(ApiResponse.completed(filterList));
  // }
  //
  // void filterTopic(String topicName){
  //   var filterList = _originalItems.where((element) => element.topic.toLowerCase() == topicName.toLowerCase()).toList();
  //   print("filter with $topicName ==> data: " + filterList.length.toString());
  //   _allItemController.sink.add(ApiResponse.completed(filterList));
  // }

  void dispose() {
    _allItemController?.close();
    _itemDetailController?.close();
    _parentCommentController?.close();
    //_childCommentController?.close();
  }
}
