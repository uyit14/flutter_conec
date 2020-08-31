import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/request/signup_request.dart';
import 'package:conecapp/repositories/authen/authen_repository.dart';

class AuthenBloc{
  AuthenRepository _repository = AuthenRepository();

  StreamController _loginController;
  Stream<ApiResponse<dynamic>> get loginStream =>
      _loginController.stream;

  StreamController _signUpController = StreamController<ApiResponse<dynamic>>();
  Stream<ApiResponse<dynamic>> get signUpStream => _signUpController.stream;

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

  void requestForgotPass(String email) async{
    final result = await _repository.doForgotPass(email);
    //sink to ui
  }

  void dispose() {
    //dispose stream
    _loginController?.close();
    _signUpController?.close();
  }
}