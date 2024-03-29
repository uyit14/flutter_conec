import 'dart:convert';

import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/authen/authen_response.dart';
import 'package:conecapp/models/response/authen/confirm_email_response.dart';
import 'package:conecapp/models/response/authen/reset_password_response.dart';
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

  Future<LoginResponse> doLoginWithSocial(String tokenId, socialType) async {
    final response = await _helper.post("/api/account/$socialType",
        body: jsonEncode({'idToken': tokenId}),
        headers: header);
    print(response.toString());
    return LoginResponse.fromJson(response);
  }

  Future<SignUpResponse> doSignUp(String userName, String email, String passWord, String confirmPass) async {
    final response = await _helper.post("/api/account/register",
        body: jsonEncode({'userName': userName, 'email': email, 'password': passWord, "confirmPassword": confirmPass}),
        headers: header);
    print(response.toString());
    return SignUpResponse.fromJson(response);
  }

  Future<VerifyUserNameResponse> verifyUserName(String userName) async {
    final response = await _helper.post("/api/Account/ForgotPassword",
        body: jsonEncode({'userName': userName}), headers: header);
    print(response.toString());
    return VerifyUserNameResponse.fromJson(response);
  }

  Future<ResetResponse> resetPassword(String userName, String newPassword, String code) async {
    final response = await _helper.post("/api/Account/ResetPassword",
        body: jsonEncode({'userName': userName, 'password': newPassword, 'code': code}), headers: header);
    print(response.toString());
    return ResetResponse.fromJson(response);
  }

  Future<VerifyUserNameResponse> verifyEmail(String email) async {
    final response = await _helper.post("/api/Account/VerificationEmail",
        headers: await Helper.header(),
        body: jsonEncode({'email': email}));
    print(response.toString());
    return VerifyUserNameResponse.fromJson(response);
  }

  Future<ConfirmEmailResponse> confirmEmail(String email, String passWord, String code) async {
    final response = await _helper.post("/api/Account/VerificationEmail",
        headers: await Helper.header(),
        body: jsonEncode({'email': email, 'password': passWord, 'code': code}));
    print(response.toString());
    return ConfirmEmailResponse.fromJson(response);
  }
}
