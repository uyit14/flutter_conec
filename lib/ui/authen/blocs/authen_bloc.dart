import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/request/signup_request.dart';
import 'package:conecapp/repositories/authen/authen_repository.dart';

class AuthenBloc{
  AuthenRepository _repository = AuthenRepository();
  StreamController _loginController;
  Stream<ApiResponse<dynamic>> get loginStream =>
      _loginController.stream;

  AuthenBloc(){
    _repository = AuthenRepository();
    _loginController = StreamController<ApiResponse<dynamic>>();
  }

  void requestLogin(String phone, String passWord) async{
    try{
      _loginController.sink.add(ApiResponse.loading());
      final token = await _repository.doLogin(phone, passWord);
      _loginController.sink.add(ApiResponse.completed(token));
    }catch(e){
      _loginController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void requestSignUp(SignUpRequest request) async{
    final result = await _repository.doSignUp(request);
    //sink result
  }

  void requestForgotPass(String email) async{
    final result = await _repository.doForgotPass(email);
    //sink to ui
  }

  void dispose() {
    //dispose stream
    _loginController?.close();
  }
}