import 'dart:convert';

import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/page/page_response.dart';
import 'package:conecapp/models/response/profile/GiftReponse.dart';
import 'package:conecapp/models/response/profile/change_password_response.dart';
import 'package:conecapp/models/response/profile/profile_response.dart';

class ProfileRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<ProfileResponse> fetchProfile() async {
    final response = await _helper.post("/api/Account/GetProfile",
        headers: await Helper.header());
    print(response);
    return ProfileResponse.fromJson(response);
  }

  Future<ProfileResponse> updateProfile(dynamic body) async {
    final response = await _helper.post("/api/Account/SaveProfile",
        headers: await Helper.header(), body: body);
    Helper.appLog(
        className: "ProfileRepository",
        functionName: "updateProfile",
        message: response.toString());
    return ProfileResponse.fromJson(response);
  }

  Future<ChangePassWordResponse> changePassword(
      String oldPass, String newPass) async {
    final response = await _helper.post("/api/Account/ChangePassword",
        headers: await Helper.header(),
        body: jsonEncode({'oldPassword': oldPass, 'newPassword': newPass}));
    print(response);
    return ChangePassWordResponse.fromJson(response);
  }

  Future<PageResponse> fetchPageInfo() async {
    final response = await _helper.get("/api/Account/GetMyPage",
        headers: await Helper.header());
    print(response);
    return PageResponse.fromJson(response);
  }

  Future<PageResponse> updatePageInfo(dynamic body) async {
    final response = await _helper.post("/api/account/SavePage",
        headers: await Helper.header(), body: body);
    print(response);
    return PageResponse.fromJson(response);
  }

  Future<bool> sendReport(dynamic body, bool isHaveToken) async {
    final response = await _helper.post('/api/feedback/create',
        headers: isHaveToken ? await Helper.header() : null, body: body);
    print(response);
    return response['status'];
  }

  Future<GiftResponse> fetchGiftResponse() async{
    final response = await _helper.get("/api/MyPost/CheckRemainPushPriority", headers: await Helper.header());
    print("fetchGiftResponse $response");
    return GiftResponse.fromJson(response);
  }
}
