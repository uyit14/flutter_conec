import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/profile/profile_response.dart';
import 'package:conecapp/repositories/profile/profile_repository.dart';

class ProfileBloc {
  ProfileRepository _repository;

  ProfileBloc() {
    _repository = ProfileRepository();
  }

  //profile
  StreamController<ApiResponse<Profile>> _profileController =
  StreamController();
  Stream<ApiResponse<Profile>> get profileStream => _profileController.stream;

  //profile updated
  StreamController<ApiResponse<Profile>> _updateProfileController =
  StreamController();
  Stream<ApiResponse<Profile>> get updateProfileStream => _updateProfileController.stream;

  //
  StreamController<ApiResponse<String>> _changePassController =
  StreamController();
  Stream<ApiResponse<String>> get changePassStream => _changePassController.stream;


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

  void requestUpdateProfile(dynamic body) async {
    _updateProfileController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.updateProfile(body);
      if(result.status){
        _updateProfileController.sink.add(ApiResponse.completed(result.profile));
      }else{
        _updateProfileController.sink.addError(ApiResponse.error(result.error));
      }
    } catch (e) {
      _updateProfileController.sink.addError(ApiResponse.error(e.toString()));
    }
  }

  void requestChangePassword(String oldPass, String newPass) async {
    _changePassController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.changePassword(oldPass, newPass);
      if(result.status){
        _changePassController.sink.add(ApiResponse.completed(result.token));
      }else{
        print("sink----:> ${result.errors[0].description}");
        _changePassController.sink.add(ApiResponse.error(result.errors[0].description));
      }
    } catch (e) {
      _changePassController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void dispose(){
    _profileController.close();
    _updateProfileController.close();
    _changePassController.close();
  }
}