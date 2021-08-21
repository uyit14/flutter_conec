import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/member2/follower2_response.dart';
import 'package:conecapp/models/response/member2/member2_detail_response.dart';
import 'package:conecapp/models/response/member2/member2_response.dart';
import 'package:conecapp/repositories/home/home_remote_repository.dart';
import 'package:flutter/material.dart';

class Member2Bloc {
  HomeRemoteRepository _repository;

  Member2Bloc() {
    _repository = HomeRemoteRepository();
  }

  StreamController<ApiResponse<List<Member2>>> _member2Controller =
      StreamController();

  Stream<ApiResponse<List<Member2>>> get member2Stream =>
      _member2Controller.stream;

  StreamController<ApiResponse<List<Follower2>>> _follower2Controller =
      StreamController();

  Stream<ApiResponse<List<Follower2>>> get follower2Stream =>
      _follower2Controller.stream;

  StreamController<ApiResponse<Member2Detail>> _member2DetailController =
      StreamController();

  Stream<ApiResponse<Member2Detail>> get member2DetailStream =>
      _member2DetailController.stream;

  void requestGetMember2(int page) async {
    print('page $page');
    _member2Controller.sink.add(ApiResponse.completed([]));
    try {
      final result = await _repository.getMember2s(page);
      print("sink page $page ${result.member2.length}");
      _member2Controller.sink.add(ApiResponse.completed(result.member2));
    } catch (e) {
      _member2Controller.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void requestGetFollower2(int page) async {
    print('page $page');
    _follower2Controller.sink.add(ApiResponse.completed([]));
    try {
      final result = await _repository.getFollower2s(page);
      print("sink page $page ${result.follower2s.length}");
      _follower2Controller.sink.add(ApiResponse.completed(result.follower2s));
    } catch (e) {
      _follower2Controller.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void requestGetMember2Detail(String id) async {
    _member2DetailController.sink.add(ApiResponse.loading());
    final result = await _repository.fetMember2Detail(id);
    if (result.status) {
      _member2DetailController.sink
          .add(ApiResponse.completed(result.member2Detail));
    } else {
      _member2DetailController.sink
          .addError(ApiResponse.error("Vui lòng thử lại"));
    }
  }

  void dispose() {
    _member2Controller?.close();
    _follower2Controller?.close();
    _member2DetailController?.close();
  }
}
