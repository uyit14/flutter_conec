import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/mypost_response.dart';
import 'package:conecapp/repositories/mypost/mypost_repository.dart';

class MyPostBloc{
  MyPostRepository _repository;
  MyPostBloc(){
    _repository = MyPostRepository();
  }

  //pending
  StreamController<ApiResponse<List<MyPost>>> _pendingController =
  StreamController();

  Stream<ApiResponse<List<MyPost>>> get pendingStream =>
      _pendingController.stream;
  //aechive
  StreamController<ApiResponse<List<MyPost>>> _archiveController =
  StreamController();

  Stream<ApiResponse<List<MyPost>>> get archiveStream =>
      _archiveController.stream;
  //approve
  StreamController<ApiResponse<List<MyPost>>> _approveController =
  StreamController();

  Stream<ApiResponse<List<MyPost>>> get approveStream =>
      _approveController.stream;
  //hidden
  StreamController<ApiResponse<List<MyPost>>> _hiddenController =
  StreamController();

  Stream<ApiResponse<List<MyPost>>> get hiddenStream =>
      _hiddenController.stream;
  //rejected
  StreamController<ApiResponse<List<MyPost>>> _rejectController =
  StreamController();

  Stream<ApiResponse<List<MyPost>>> get rejectStream =>
      _rejectController.stream;

  void requestGetPending(int page) async{
    _pendingController.sink.add(ApiResponse.loading());
    try{
      final result = await _repository.getMyPostByType(page, "Pending");
      _pendingController.sink.add(ApiResponse.completed(result));
    }catch(e){
      _pendingController.sink.add(ApiResponse.error(e.toString()));
    }
  }
  //archive
  void requestGetArchive(int page) async{
    _archiveController.sink.add(ApiResponse.completed([]));
    if(page != 0){
      final result = await _repository.getMyPostByType(page, "Archive");
      _archiveController.sink.add(ApiResponse.completed(result));
    }else{
      _archiveController.sink.add(ApiResponse.loading());
      try{
        final result = await _repository.getMyPostByType(page, "Archive");
        _archiveController.sink.add(ApiResponse.completed(result));
      }catch(e){
        _archiveController.sink.add(ApiResponse.error(e.toString()));
      }
    }
  }
  //hidden
  void requestGetHidden(int page) async{
    _hiddenController.sink.add(ApiResponse.loading());
    try{
      final result = await _repository.getMyPostByType(page, "Hiden");
      _hiddenController.sink.add(ApiResponse.completed(result));
    }catch(e){
      _hiddenController.sink.add(ApiResponse.error(e.toString()));
    }
  }
  //rejected
  void requestGetReject(int page) async{
    _rejectController.sink.add(ApiResponse.loading());
    try{
      final result = await _repository.getMyPostByType(page, "Reject");
      _rejectController.sink.add(ApiResponse.completed(result));
    }catch(e){
      _rejectController.sink.add(ApiResponse.error(e.toString()));
    }
  }
  //approve
  void requestApprove(int page) async{
    _approveController.sink.add(ApiResponse.loading());
    try{
      final result = await _repository.getMyPostByType(page, "Approve");
      _approveController.sink.add(ApiResponse.completed(result));
    }catch(e){
      _approveController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void dispose(){
    _pendingController.close();
    _archiveController.close();
    _hiddenController.close();
    _rejectController.close();
    _approveController.close();
  }
}