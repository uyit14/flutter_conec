import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/profile/profile_response.dart';
import 'package:conecapp/repositories/profile/profile_repository.dart';

class ProfileBloc {
  ProfileRepository _repository;

  ProfileBloc() {
    _repository = ProfileRepository();
  }

  //topic
  StreamController<ApiResponse<Profile>> _profileController =
  StreamController();
  Stream<ApiResponse<Profile>> get profileStream => _profileController.stream;

  void requestGetProfile() async {
    _profileController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.fetchProfile();
      if(result.status){
        _profileController.sink.add(ApiResponse.completed(result.profile));
      }else{
        _profileController.sink.addError(ApiResponse.error(result.error));
      }
    } catch (e) {
      _profileController.sink.addError(ApiResponse.error(e.toString()));
    }
  }

  void dispose(){
    _profileController.close();
  }
}