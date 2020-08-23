import 'dart:convert';

import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/models/request/signup_request.dart';

class AuthenRepository {
  ApiBaseHelper _helper = ApiBaseHelper();
  final header = {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  };

  Future<String> doLogin(String phone, String passWord) async {
    final response = await _helper.post("/api/token",
        body: jsonEncode({'UserName': phone, 'Password': passWord}),
        headers: header);
    return Future.value(response['token']);
  }

  Future<bool> doSignUp(SignUpRequest request) async {
    final response = await _helper.post("https://google.com/getcategory",
        body: request.toJsonClub(), headers: header);
    return true;
  }

  Future<bool> doForgotPass(String email) async {
    final response = await _helper.post("https://google.com/getcategory",
        body: {'email': email}, headers: header);
    return true;
  }
}
