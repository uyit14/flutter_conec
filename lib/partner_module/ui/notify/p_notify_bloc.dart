import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/partner_module/models/p_notify_detail.dart';
import 'package:conecapp/partner_module/models/p_notify_reponse.dart';
import 'package:conecapp/partner_module/repository/partner_repository.dart';
import 'package:flutter/material.dart';

class PNotifyBloc {
  PartnerRepository _repository;

  PNotifyBloc() {
    _repository = PartnerRepository();
  }

  //notify list
  StreamController<ApiResponse<List<PNotifyLite>>> _notifyController =
      StreamController();

  Stream<ApiResponse<List<PNotifyLite>>> get notifyStream =>
      _notifyController.stream;

  //notify detail
  StreamController<ApiResponse<PNotifyFull>> _notifyFullController =
      StreamController();

  Stream<ApiResponse<PNotifyFull>> get notifyFullStream =>
      _notifyFullController.stream;

  //add notify
  StreamController<ApiResponse<PNotifyFull>> _addPNotifyController =
      StreamController();

  Stream<ApiResponse<PNotifyFull>> get addPNotifyStream =>
      _addPNotifyController.stream;

  //add notify
  StreamController<ApiResponse<PNotifyFull>> _updatePNotifyController =
      StreamController();

  Stream<ApiResponse<PNotifyFull>> get updatePNotifyStream =>
      _updatePNotifyController.stream;

  void requestGetNotify(int page) async {
    print('page $page');
    _notifyController.sink.add(ApiResponse.completed([]));
    try {
      final result = await _repository.getPartnerNotifies(page);
      print("sink page $page ${result.pNotifyList.length}");
      _notifyController.sink.add(ApiResponse.completed(result.pNotifyList));
    } catch (e) {
      _notifyController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void requestGetPNotifyDetail(String postId) async {
    _notifyFullController.sink.add(ApiResponse.loading());
    try {
      final pNotify = await _repository.fetchPartnerNotifyDetail(postId);
      _notifyFullController.sink.add(ApiResponse.completed(pNotify.notifyFull));
    } catch (e) {
      _notifyFullController.sink.addError(ApiResponse.error(e.toString()));
    }
  }

  Future<bool> requestDeleteNotify(String notifyId) async {
    final response = await _repository.deletePNotify(notifyId);
    return response;
  }

  void requestAddPNotify(dynamic body) async {
    _addPNotifyController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.addPNotify(body);
      _addPNotifyController.sink.add(ApiResponse.completed(result));
    } catch (e) {
      _addPNotifyController.sink.add(ApiResponse.error(e.toString()));
      print("Add_Notify_Error: " + e.toString());
    }
  }

  Future<String> requestPushNotify(String id) async {
    final response = await _repository.pushNotify(id);
    if(response.status){
      return response.msg;
    }
    return "Vui lòng thử lại";
  }

  void requestUpdatePNotify(dynamic body) async {
    _updatePNotifyController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.updatePNotify(body);
      _updatePNotifyController.sink.add(ApiResponse.completed(result));
    } catch (e) {
      _updatePNotifyController.sink.add(ApiResponse.error(e.toString()));
      print("Update_Notify_Error: " + e.toString());
    }
  }

  void dispose() {
    _notifyController?.close();
    _notifyFullController?.close();
    _addPNotifyController?.close();
    _updatePNotifyController?.close();
  }
}
