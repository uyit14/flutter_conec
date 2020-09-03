import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/repositories/authen/authen_repository.dart';

class AuthenBloc{
  AuthenRepository _repository = AuthenRepository();

  StreamController _loginController;
  Stream<ApiResponse<dynamic>> get loginStream =>
      _loginController.stream;

  StreamController _signUpController = StreamController<ApiResponse<dynamic>>();
  Stream<ApiResponse<dynamic>> get signUpStream => _signUpController.stream;

  StreamController _verifyUserController = StreamController<ApiResponse<dynamic>>();
  Stream<ApiResponse<dynamic>> get verifyUserStream => _verifyUserController.stream;

  StreamController _verifyEmailController = StreamController<ApiResponse<dynamic>>();
  Stream<ApiResponse<dynamic>> get verifyEmailStream => _verifyEmailController.stream;

  StreamController _resetPassController = StreamController<ApiResponse<dynamic>>();
  Stream<ApiResponse<dynamic>> get resetPassStream => _resetPassController.stream;

  StreamController _confirmEmailController = StreamController<ApiResponse<dynamic>>();
  Stream<ApiResponse<dynamic>> get confirmEmailStream => _confirmEmailController.stream;

  AuthenBloc(){
    _repository = AuthenRepository();
    _loginController = StreamController<ApiResponse<dynamic>>();
  }

  void requestLogin(String phone, String passWord) async{
    try{
      _loginController.sink.add(ApiResponse.loading());
      final result = await _repository.doLogin(phone, passWord);
      if(result.status){
        _loginController.sink.add(ApiResponse.completed(result.token));
      }else{
        _loginController.sink.add(ApiResponse.error(result.error ?? ""));
      }
    }catch(e){
      _loginController.sink.add(ApiResponse.error(e.toString()));
    }
  }

    void requestSignUp(String userName, String email, String passWord, String confirmPassWord) async{
    _signUpController.sink.add(ApiResponse.loading());
    try{
      final result = await _repository.doSignUp(userName, email, passWord, confirmPassWord);
      if(result.status){
        _signUpController.sink.add(ApiResponse.completed(result.token));
      }else{
        _signUpController.sink.add(ApiResponse.error(result.errors[0].description ?? ""));
      }
    }catch(e){
      _signUpController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void requestVerifyUsername(String userName) async{
    _verifyUserController.sink.add(ApiResponse.loading());
    final result = await _repository.verifyUserName(userName);
    if(result.status){
      _verifyUserController.sink.add(ApiResponse.completed(Helper.verifyMessage));
    }else{
      _verifyUserController.sink.add(ApiResponse.error(result.error));
    }
  }

  void requestVerifyEmail(String email) async{
    _verifyEmailController.sink.add(ApiResponse.loading());
    final result = await _repository.verifyEmail(email);
    if(result.status){
      _verifyEmailController.sink.add(ApiResponse.completed(Helper.verifyMessage));
    }else{
      _verifyEmailController.sink.add(ApiResponse.error(result.error));
    }
  }

  void requestResetPass(String userName, String newPassword, String code) async{
    _resetPassController.sink.add(ApiResponse.loading());
    final result = await _repository.resetPassword(userName, newPassword, code);
    if(result.status){
      _resetPassController.sink.add(ApiResponse.completed(result.status));
    }else{
      _resetPassController.sink.add(ApiResponse.error(result.errors[0].description));
    }
  }

  void requestConfirmEmail(String email, String passWord, String code) async{
    _confirmEmailController.sink.add(ApiResponse.loading());
    final result = await _repository.confirmEmail(email, passWord, code);
    if(result.status){
      _confirmEmailController.sink.add(ApiResponse.completed(result.token));
    }else{
      _confirmEmailController.sink.add(ApiResponse.error(result.error));
    }
  }

  void dispose() {
    //dispose stream
    _loginController?.close();
    _signUpController?.close();
    _verifyUserController?.close();
    _resetPassController?.close();
    _verifyEmailController?.close();
    _confirmEmailController?.close();
  }
}