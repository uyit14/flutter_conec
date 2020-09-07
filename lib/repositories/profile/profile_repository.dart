import 'dart:convert';

import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/profile/change_password_response.dart';
import 'package:conecapp/models/response/profile/profile_response.dart';

class ProfileRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<ProfileResponse> fetchProfile() async {
    final response =
        await _helper.post("/api/Account/GetProfile", headers: await Helper.header());
    print(response);
    return ProfileResponse.fromJson(response);
  }

  Future<ProfileResponse> updateProfile(dynamic body) async {
    final response = await _helper.post("/api/Account/SaveProfile",
        headers: await Helper.header(), body: body);
    print(response);
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
}