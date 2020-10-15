import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/notify/notify_response.dart';
import 'package:conecapp/repositories/home/home_remote_repository.dart';
import 'package:flutter/material.dart';

class NotifyBloc {
  HomeRemoteRepository _repository;

  NotifyBloc() {
    _repository = HomeRemoteRepository();
  }

  //topic
  StreamController<ApiResponse<List<Notify>>> _notifyController =
      StreamController();

  Stream<ApiResponse<List<Notify>>> get notifyStream =>
      _notifyController.stream;

  void requestGetNotify(int page) async {
    _notifyController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.getAllNotify(page);
      _notifyController.sink.add(ApiResponse.completed(result.notifyList));
    } catch (e) {
      _notifyController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void requestDeleteOrRead(String notifyId, String type)async{
    var result = await _repository.deleteOrReadNotify(notifyId, type);
    if(result.status){
      print("$type success with id = $notifyId");
    }else{
      print("$type fail with id = $notifyId");
    }
  }

  void dispose() {
    _notifyController.close();
  }
}
