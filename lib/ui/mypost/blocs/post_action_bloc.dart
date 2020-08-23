import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
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

  //delete image
  StreamController<ApiResponse<String>> _deleteImageController =
      StreamController();

  Stream<ApiResponse<String>> get deleteImageStream =>
      _deleteMyPostController.stream;

  //topic
  StreamController<ApiResponse<List<Topic>>> _topicController =
  StreamController();
  Stream<ApiResponse<List<Topic>>> get topicStream => _topicController.stream;

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

  void requestDeleteMyPost(String postId) async {
    _deleteMyPostController.sink.add(ApiResponse.loading());
    final result = await _repository.deleteMyPost(postId);
    if (result.status) {
      _deleteMyPostController.sink
          .add(ApiResponse.completed("Xóa thành công"));
    } else {
      _deleteMyPostController.sink.add(ApiResponse.completed(result.message));
    }
  }

  void requestDeleteImage(String id) async {
    _deleteImageController.sink.add(ApiResponse.loading());
    final result = await _repository.deleteImage(id);
    if (result.status) {
      _deleteImageController.sink
          .add(ApiResponse.completed("Xóa thành công"));
    } else {
      _deleteImageController.sink.add(ApiResponse.completed(result.message));
    }
  }

  void requestAddMyPost(dynamic body, String type) async {
    _addPostController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.postMyPost(body, type);
      _addPostController.sink.add(ApiResponse.completed(result));
    } catch (e) {
      _addPostController.sink.add(ApiResponse.error(e.toString()));
      print("ERROR: " + e.toString());
    }
  }

  void requestUpdateMyPost(dynamic body) async {
    _updatePostController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.updateMyPost(body);
      _updatePostController.sink.add(ApiResponse.completed(result));
    } catch (e) {
      _updatePostController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void dispose() {
    _deleteMyPostController.close();
    _deleteImageController.close();
    _addPostController.close();
    _updatePostController.close();
    _provincesController.close();
    _wardsController.close();
    _districtsController.close();
    _topicController.close();
  }
}
