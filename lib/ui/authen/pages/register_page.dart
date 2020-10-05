import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/signup_response.dart';
import 'package:conecapp/ui/authen/blocs/authen_bloc.dart';
import 'package:conecapp/ui/authen/pages/confirm_email_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/globals.dart' as globals;

import '../../conec_home_page.dart';

class RegisterPage extends StatefulWidget {
  static const ROUTE_NAME = '/register';
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passWordController = TextEditingController();
  TextEditingController _confirmPassWordController = TextEditingController();

  FocusNode _userNameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passWordFocusNode = FocusNode();
  FocusNode _confirmPassWordFocusNode = FocusNode();

  bool _userNameValidate = false;
  bool _emailValidate = false;
  bool _passWordValidate = false;
  bool _confirmPassWordValidate = false;

  AuthenBloc _authenBloc = AuthenBloc();

  bool _loadingStatus = false;
  bool _loginFail = false;
  String _statusMessage;

  void doSignUp(){
    setState(() {
      _loginFail = false;
    });
    if(_userNameController.text.length <0){
      setState(() {
        _userNameValidate = true;
        _emailValidate = false;
        _passWordValidate = false;
        _confirmPassWordValidate = false;
      });
    }
    if (_emailController.text.length < 9) {
      setState(() {
        _confirmPassWordValidate = false;
        _userNameValidate = false;
        _passWordValidate = false;
        _emailValidate = true;
      });
      return;
    }
    if (_passWordController.text.length < 7) {
      setState(() {
        _confirmPassWordValidate = false;
        _userNameValidate = false;
        _emailValidate = false;
        _passWordValidate = true;
      });
      return;
    }
    if (_confirmPassWordController.text != _passWordController.text) {
      setState(() {
        _userNameValidate = false;
        _emailValidate = false;
        _passWordValidate = false;
        _confirmPassWordValidate = true;
      });
      return;
    }
    setState(() {
      _emailValidate = false;
      _passWordValidate = false;
      _confirmPassWordValidate = false;
    });
    //
    _authenBloc.requestSignUp(_userNameController.text, _emailController.text, _passWordController.text, _confirmPassWordController.text);
    //_authenBloc.requestLogin("chuongnh.hcm@gmail.com", "&&**14110013Hc");
    _authenBloc.signUpStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          setState(() {
            _loginFail = false;
            _loadingStatus = true;
          });
          return;
        case Status.COMPLETED:
          SignUpResponse signUpResponse = event.data;
          gotoHome(signUpResponse.token, signUpResponse.expires);
          break;
        case Status.ERROR:
          setState(() {
            _loadingStatus = false;
            _loginFail = true;
            _statusMessage = event.message;
          });
          return;
      }
    });
  }

  void gotoHome(String token, String expiredDay) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    prefs.setString('expired', expiredDay);
    Navigator.of(context).pushNamedAndRemoveUntil(
        ConecHomePage.ROUTE_NAME, (Route<dynamic> route) => false);
  }

  void saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    //call api confirm email
    _authenBloc.requestVerifyEmail(_emailController.text.trim());
    _authenBloc.verifyEmailStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          setState(() {
            _loginFail = false;
            _loadingStatus = true;
          });
          return;
        case Status.COMPLETED:
          //
        Navigator.of(context).pushNamed(ConfirmEmailPage.ROUTE_NAME, arguments: {
          'email' : _emailController.text.trim(),
          'password' : _passWordController.text.trim()
        });
          break;
        case Status.ERROR:
          setState(() {
            _loadingStatus = false;
            _loginFail = true;
            _statusMessage = event.message;
          });
          return;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _authenBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(16),
                      width: double.infinity,
                      height: Helper.getScreenHeight(context) > Helper.getScreenWidth(context)
                          ? Helper.getScreenHeight(context) * 0.2
                          : Helper.getScreenWidth(context) * 0.2,
                      decoration: BoxDecoration(
                          color: Color(0xffff3b30),
                          borderRadius: BorderRadius.only(
                              bottomLeft:
                              Radius.circular(Helper.getScreenHeight(context) * 0.3 / 2))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Image.asset("assets/images/conec_logo.png", width: 200, height: 100, fit: BoxFit.cover,),
                              ),
                          Container(
                            width: double.infinity,
                            child: Text(
                              'Kết nối thể thao',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: Helper.getScreenHeight(context) > Helper.getScreenWidth(context)
                                      ? Helper.getScreenHeight(context) * 0.035
                                      : Helper.getScreenWidth(context) * 0.035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      )),
                  Positioned(
                    child: IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                    ),
                    top: 8,
                    left: 8,
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Column(
                  children: [
                    TextFormField(
                      maxLines: 1,
                      controller: _userNameController,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(fontSize: 18),
                      keyboardType: TextInputType.text,
                      focusNode: _userNameFocusNode,
                      onFieldSubmitted: (value){
                        _emailFocusNode.requestFocus();
                      },
                      decoration: InputDecoration(
                          hintText: 'Tên đăng nhập / Số điện thoại',
                          errorText:
                          _userNameValidate ? "Tên đăng nhập không hợp lệ" : null,
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 1)),
                          contentPadding: EdgeInsets.only(left: 8),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          border: const OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      maxLines: 1,
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(fontSize: 18),
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _emailFocusNode,
                      onFieldSubmitted: (value){
                        _passWordFocusNode.requestFocus();
                      },
                      decoration: InputDecoration(
                          hintText: 'Email',
                          errorText:
                          _emailValidate ? "Email không hợp lệ" : null,
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 1)),
                          contentPadding: EdgeInsets.only(left: 8),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                          border: const OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      maxLines: 1,
                      controller: _passWordController,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(fontSize: 18),
                      obscureText: true,
                      focusNode: _passWordFocusNode,
                      onFieldSubmitted: (value){
                        _confirmPassWordFocusNode.requestFocus();
                      },
                      decoration: InputDecoration(
                          hintText: 'Mật khẩu',
                          errorText: _passWordValidate
                              ? "Mật khẩu phải lớn hơn 6 kí tự"
                              : null,
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 1)),
                          contentPadding: EdgeInsets.only(left: 8),
                          prefixIcon: Icon(
                            Icons.vpn_key,
                            color: Colors.black,
                          ),
                          border: const OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 18),
                      obscureText: true,
                      controller: _confirmPassWordController,
                      focusNode: _confirmPassWordFocusNode,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          hintText: 'Nhập lại mật khẩu',
                          errorText: _confirmPassWordValidate
                              ? "Xác nhận mật khẩu phải trùng với mật khẩu"
                              : null,
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 1)),
                          contentPadding: EdgeInsets.only(left: 8),
                          prefixIcon: Icon(
                            Icons.confirmation_number,
                            color: Colors.black,
                          ),
                          border: const OutlineInputBorder()),
                    ),
                    SizedBox(height: 32),
                    _loginFail
                        ? Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                          _statusMessage ?? "",
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.red,
                              fontSize: 16)),
                    )
                        : SizedBox(
                      height: 32,
                    ),
                    InkWell(
                      onTap: doSignUp,
                      child: Container(
                        //margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: 45,
                        child: Center(
                          child: Text(
                            'Đăng ký',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    _loadingStatus
                        ? Center(child: CircularProgressIndicator())
                        : Container(),
                  ],
                ),
              )
            ],

          ),
        ),
      ),
    );
  }
}
