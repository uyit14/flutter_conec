import 'dart:convert';

import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/models/request/signup_request.dart';
import 'package:conecapp/models/response/login_response.dart';
import 'package:conecapp/models/response/signup_response.dart';

class AuthenRepository {
  ApiBaseHelper _helper = ApiBaseHelper();
  final header = {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  };

  Future<LoginResponse> doLogin(String phone, String passWord) async {
    final response = await _helper.post("/api/account/login",
        body: jsonEncode({'UserName': phone, 'Password': passWord}),
        headers: header);
    print(response.toString());
    return LoginResponse.fromJson(response);
  }

  Future<SignUpResponse> doSignUp(String userName, String email, String passWord, String confirmPass) async {
    final response = await _helper.post("/api/account/register",
        body: jsonEncode({'userName': userName, 'email': email, 'password': passWord, "confirmPassword": confirmPass}),
        headers: header);
    return SignUpResponse.fromJson(response);
  }

  Future<bool> doForgotPass(String email) async {
    final response = await _helper.post("https://google.com/getcategory",
        body: {'email': email}, headers: header);
    return true;
  }
}
