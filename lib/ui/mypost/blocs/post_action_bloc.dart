import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/request/post_action_request.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/models/response/location/city_response.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/repositories/mypost/mypost_repository.dart';
import 'package:flutter/material.dart';

class PostActionBloc {
  MyPostRepository _repository;

  PostActionBloc() {
    _repository = MyPostRepository();
  }

  //cityList
  StreamController<ApiResponse<List<Province>>> _provincesController = StreamController();
  Stream<ApiResponse<List<Province>>> get provincesStream =>
      _provincesController.stream;
  //districtList
  StreamController<ApiResponse<List<Province>>> _districtsController = StreamController();
  Stream<ApiResponse<List<Province>>> get districtsStream =>
      _districtsController.stream;
  //wardList
  StreamController<ApiResponse<List<Province>>> _wardsController = StreamController();
  Stream<ApiResponse<List<Province>>> get wardsStream =>
      _wardsController.stream;

  //add mypost
  StreamController<ApiResponse<ItemDetail>> _addPostController =
      StreamController();

  Stream<ApiResponse<ItemDetail>> get addMyPostStream =>
      _addPostController.stream;

  //add mypost
  StreamController<ApiResponse<ItemDetail>> _updatePostController =
  StreamController();

  Stream<ApiResponse<ItemDetail>> get updateMyPostStream =>
      _updatePostController.stream;

  //delete mypost
  StreamController<ApiResponse<String>> _deleteMyPostController =
      StreamController();

  Stream<ApiResponse<String>> get deleteMyPostStream =>
      _deleteMyPostController.stream;

  //delete mypost
  StreamController<ApiResponse<String>> _pushMyPostController =
  StreamController();

  Stream<ApiResponse<String>> get pushMyPostStream =>
      _pushMyPostController.stream;

//  //delete image
//  StreamController<ApiResponse<String>> _deleteImageController =
//      StreamController();
//
//  Stream<ApiResponse<String>> get deleteImageStream =>
//      _deleteMyPostController.stream;

  //topic
  StreamController<ApiResponse<List<Topic>>> _topicController =
  StreamController();
  Stream<ApiResponse<List<Topic>>> get topicStream => _topicController.stream;

  //topic
  StreamController<ApiResponse<List<Topic>>> _subTopicController =
  StreamController.broadcast();
  Stream<ApiResponse<List<Topic>>> get subTopicStream => _subTopicController.stream;

  void requestGetTopicWithHeader() async {
    _topicController.sink.add(ApiResponse.loading());
    try {
      final topics = await _repository.fetchTopicWithHeader();
      _topicController.sink.add(ApiResponse.completed(topics));
    } catch (e) {
      _topicController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void requestGetSubTopicWithHeader(bool isTopic, {String topicId}) async {
    _subTopicController.sink.add(ApiResponse.loading());
    try {
      final topics = await _repository.fetchSubTopicWithHeader(isTopic, topicId: topicId);
      _subTopicController.sink.add(ApiResponse.completed(topics));
    } catch (e) {
      _subTopicController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  Future<String> requestGetTitle(String topicId) async{
    final title = await _repository.fetchTitle(topicId);
    return title;
  }

  void requestGetProvinces() async{
    _provincesController.sink.add(ApiResponse.loading());
    try{
      final result = await _repository.getListProvince();
      _provincesController.sink.add(ApiResponse.completed(result));
    }catch(e){
      print(e.toString());
      _provincesController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void requestGetDistricts(String provinceId) async{
    _districtsController.sink.add(ApiResponse.loading());
    try{
      final result = await _repository.getListDistrict(provinceId);
      _districtsController.sink.add(ApiResponse.completed(result));
    }catch(e){
      print(e.toString());
      _districtsController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void requestGetWards(String districtId) async{
    _wardsController.sink.add(ApiResponse.loading());
    try{
      final result = await _repository.getListWard(districtId);
      _wardsController.sink.add(ApiResponse.completed(result));
    }catch(e){
      print(e.toString());
      _wardsController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void requestDeleteMyPost(String postId, String type) async {
    _deleteMyPostController.sink.add(ApiResponse.loading());
    final result = await _repository.deleteMyPost(postId, type);
    if (result.status) {
      _deleteMyPostController.sink
          .add(ApiResponse.completed(type == "Delete" ? "Xóa thành công" : ""));
    } else {
      _deleteMyPostController.sink.add(ApiResponse.error(result.message));
    }
  }

  void requestPushMyPost(String postId, {bool isPush, bool isPriority}) async {
    _pushMyPostController.sink.add(ApiResponse.loading());
    final result = await _repository.deleteMyPost(postId, "Push", isPush: isPush, isPriority: isPriority);
    if (result.status) {

      _pushMyPostController.sink
          .add(ApiResponse.completed(result.message));
    } else {
      _pushMyPostController.sink.add(ApiResponse.error(result.message));
    }
  }

  void requestDeleteImage(String id, String type) async {
    final result = await _repository.deleteImage(id, type);
    if (result.status) {
      print("Success");
    } else {
     print("Fail");
    }
  }

  void requestAddMyPost(dynamic body, String type) async {
    _addPostController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.postMyPost(body, type);
      _addPostController.sink.add(ApiResponse.completed(result));
    } catch (e) {
      _addPostController.sink.add(ApiResponse.error(Helper.errorMessage));
      print("ERROR: " + e.toString());
    }
  }

//  void requestUpdateMyPost(dynamic body) async {
//    _updatePostController.sink.add(ApiResponse.loading());
//    try {
//      final result = await _repository.updateMyPost(body);
//      _updatePostController.sink.add(ApiResponse.completed(result));
//    } catch (e) {
//      _updatePostController.sink.add(ApiResponse.error(e.toString()));
//    }
//  }

  void dispose() {
    _deleteMyPostController?.close();
    //_deleteImageController.close();
    _addPostController?.close();
    _updatePostController?.close();
    _provincesController?.close();
    _wardsController?.close();
    _districtsController?.close();
    _topicController?.close();
    _pushMyPostController?.close();
    _subTopicController?.close();
  }
}
