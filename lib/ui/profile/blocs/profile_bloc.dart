import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/profile/change_password_response.dart';
import 'package:conecapp/models/response/profile/gift_response.dart';
import 'package:conecapp/models/response/profile/profile_response.dart';
import 'package:conecapp/repositories/profile/profile_repository.dart';

import '../../../models/response/page/page_response.dart' as page;

class ProfileBloc {
  ProfileRepository _repository;

  ProfileBloc() {
    _repository = ProfileRepository();
  }

  //profile
  StreamController<ApiResponse<Profile>> _profileController =
      StreamController();

  Stream<ApiResponse<Profile>> get profileStream => _profileController.stream;

  //
  //profile
  StreamController<ApiResponse<page.Profile>> _pageController =
      StreamController();

  Stream<ApiResponse<page.Profile>> get pageStream => _pageController.stream;

  //profile updated
  StreamController<ApiResponse<Profile>> _updateProfileController =
      StreamController();

  Stream<ApiResponse<Profile>> get updateProfileStream =>
      _updateProfileController.stream;

  //profile updated
  StreamController<ApiResponse<page.Profile>> _updatePageController =
      StreamController();

  Stream<ApiResponse<page.Profile>> get updatePageStream =>
      _updatePageController.stream;

  //
  StreamController<ApiResponse<ChangePassWordResponse>> _changePassController =
      StreamController();

  Stream<ApiResponse<ChangePassWordResponse>> get changePassStream =>
      _changePassController.stream;

  //
  StreamController<ApiResponse<GiftResponse>> _giftResponseController =
      StreamController.broadcast();

  Stream<ApiResponse<GiftResponse>> get giftResponseStream =>
      _giftResponseController.stream;

  void requestGetProfile() async {
    _profileController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.fetchProfile();
      if (result.status) {
        _profileController.sink.add(ApiResponse.completed(result.profile));
      } else {
        _profileController.sink.addError(ApiResponse.error(result.error));
      }
    } catch (e) {
      _profileController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void requestGetPage() async {
    _pageController.sink.add(ApiResponse.loading());
    final result = await _repository.fetchPageInfo();
    if (result.status) {
      _pageController.sink.add(ApiResponse.completed(result.profile));
    } else {
      _pageController.sink.add(ApiResponse.error(result.error));
    }
  }

  void requestUpdateProfile(dynamic body) async {
    _updateProfileController.sink.add(ApiResponse.loading());
    final result = await _repository.updateProfile(body);
    if (result.status) {
      _updateProfileController.sink.add(ApiResponse.completed(result.profile));
    } else {
      _updateProfileController.sink.add(ApiResponse.error(result.error));
    }
  }

  void requestUpdatePage(dynamic body) async {
    _updatePageController.sink.add(ApiResponse.loading());
    final result = await _repository.updatePageInfo(body);
    if (result.status) {
      _updatePageController.sink.add(ApiResponse.completed(result.profile));
    } else {
      _updatePageController.sink.add(ApiResponse.error(result.error));
    }
  }

  void requestChangePassword(String oldPass, String newPass) async {
    _changePassController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.changePassword(oldPass, newPass);
      if (result.status) {
        _changePassController.sink.add(ApiResponse.completed(result));
      } else {
        print("sink----:> ${result.errors[0].description}");
        _changePassController.sink
            .add(ApiResponse.error(result.errors[0].description));
      }
    } catch (e) {
      _changePassController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  Future<bool> requestReport(dynamic body, bool isHaveToken) async {
    final response = await _repository.sendReport(body, isHaveToken);
    return response;
  }

  Future<bool> deleteAccount() async {
    final response = await _repository.deleteAccount();
    return response;
  }

  void requestGetGiftResponse() async {
    _giftResponseController.sink.add(ApiResponse.loading());
    final result = await _repository.fetchGiftResponse();
    if (result.status) {
      _giftResponseController.sink.add(ApiResponse.completed(result));
    } else {
      _giftResponseController.sink
          .add(ApiResponse.error("Có lỗi xảy ra, xin vui lòng thử lại"));
    }
  }

  void dispose() {
    _profileController.close();
    _updateProfileController.close();
    _changePassController.close();
    _updatePageController.close();
    _giftResponseController?.close();
  }

  void disposePage() {
    _pageController.close();
  }
}
