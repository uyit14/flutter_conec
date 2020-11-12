import 'dart:convert';
import 'dart:io';

import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/login_response.dart';
import 'package:conecapp/ui/authen/blocs/authen_bloc.dart';
import 'package:conecapp/ui/authen/pages/forgot_password_page.dart';
import 'package:conecapp/ui/authen/pages/register_page.dart';
import 'package:conecapp/ui/conec_home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_zalo_login/flutter_zalo_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginPage extends StatefulWidget {
  static const ROUTE_NAME = '/login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passWordController = TextEditingController();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passWordFocusNode = FocusNode();
  bool _emailValidate = false;
  bool _passWordValidate = false;
  AuthenBloc _authenBloc = AuthenBloc();
  bool _loadingStatus = false;
  bool _loginFail = false;
  bool _showPass = false;
  String _loginFailMessage;
  ZaloLoginResult zaloLoginResult = ZaloLoginResult(
    errorCode: -1,
    errorMessage: "",
    oauthCode: "",
    userId: "",
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleSignIn() async {
    try {
      print(_googleSignIn.clientId);
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;
      print("idToken: " + googleAuth.idToken);
      _authenBloc.requestSocialLogin(googleAuth.idToken, "GoogleLogin");
      listenLogin();
    } catch (error) {
      print(error);
    }
  }

  listenLogin() {
    _authenBloc.loginStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          setState(() {
            _loginFail = false;
            _loadingStatus = true;
          });
          return;
        case Status.COMPLETED:
          LoginResponse loginResponse = event.data;
          gotoHome(loginResponse.token, loginResponse.expires, true);
          break;
        case Status.ERROR:
          setState(() {
            _loginFailMessage = event.message;
            _loadingStatus = false;
            _loginFail = true;
          });
          _authenBloc = AuthenBloc();
          return;
      }
    });
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Future<void> _handleFbSignIn() async {
    final facebookLogin = FacebookLogin();
    if (await facebookLogin.isLoggedIn) {
      facebookLogin.logOut();
    }
    final result = await facebookLogin.logIn(['email']);
    final token = result.accessToken.token;
    print(token ?? "NULL");
    _authenBloc.requestSocialLogin(token, "FacebookLogin");
    listenLogin();
  }

  void doSignIn() async {
    setState(() {
      _loginFail = false;
    });
    if (_emailController.text.length < 1) {
      setState(() {
        _passWordValidate = false;
        _emailValidate = true;
      });
      return;
    }
    if (_passWordController.text.length < 6) {
      setState(() {
        _emailValidate = false;
        _passWordValidate = true;
      });
      return;
    }
    //{"UserName" : "chuongnh.hcm@gmail.com", "Password": "&&**14110013Hc"}
    _authenBloc.requestLogin(_emailController.text, _passWordController.text);
    //_authenBloc.requestLogin("chuongnh.hcm@gmail.com", "&&**14110013Hc");
    _authenBloc.loginStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          setState(() {
            _loginFail = false;
            _loadingStatus = true;
          });
          return;
        case Status.COMPLETED:
          LoginResponse loginResponse = event.data;
          gotoHome(loginResponse.token, loginResponse.expires, false);
          break;
        case Status.ERROR:
          setState(() {
            _loginFailMessage = event.message;
            _loadingStatus = false;
            _loginFail = true;
          });
          _authenBloc = AuthenBloc();
          return;
      }
    });
  }

  void gotoHome(String token, String expiredDay, bool isSocial) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    prefs.setString('expired', expiredDay);
    prefs.setBool('isSocial', isSocial);
    Navigator.of(context).pushNamedAndRemoveUntil(
        ConecHomePage.ROUTE_NAME, (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();
    ZaloLogin().init();
  }

  void _loginZalo() async {
    print(await ZaloLogin.channel.invokeMethod('getPlatformVersion'));
    ZaloLoginResult res = await ZaloLogin().logIn();
    print(res);
    final response = await http.get(
        "https://oauth.zaloapp.com/v3/access_token?app_id=3165417292251410919&app_secret=SBiQNJsEIyy4bH66KN6S&code=${res.oauthCode}");
    var responseJson = json.decode(response.body.toString());
    print("Zalo token: " + responseJson['access_token']);
    _authenBloc.requestSocialLogin(responseJson['access_token'], "ZaloLogin");
    listenLogin();
  }

  void _loginApple() async{
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId:
        'com.conec.applesignin',
        redirectUri: Uri.parse(
          'https://conec.vn/api/account/AppleLogin',
        ),
      ),
    );
    print("identityToken: ${credential.identityToken}");
    print("authorizationCode: ${credential.authorizationCode}");
    print("userIdentifier: ${credential.userIdentifier}");
    _authenBloc.requestSocialLogin(credential.userIdentifier, "AppleLogin");
    listenLogin();
  }

  @override
  void dispose() {
    super.dispose();
    _authenBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  height: screenHeight > screenWidth
                      ? screenHeight * 0.2
                      : screenWidth * 0.2,
                  decoration: BoxDecoration(
                      color: Color(0xffff3b30),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(screenHeight * 0.3 / 2))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Image.asset(
                          "assets/images/conec_logo.png",
                          width: 200,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Kết nối thể thao',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: screenHeight > screenWidth
                                  ? screenHeight * 0.035
                                  : screenWidth * 0.035,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  )),
              SizedBox(height: screenHeight * 0.05),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Chào mừng bạn đến với Conec Sport!',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w400)),
                    SizedBox(height: screenHeight * 0.01),
                    Text('Nhập tài khoản và mật khẩu để đăng nhập',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      maxLines: 1,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_passWordFocusNode);
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                          hintText: 'Nhập tài khoản / số điện thoại của bạn',
                          errorText:
                              _emailValidate ? "Tài khoản không hợp lệ" : null,
                          enabledBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1)),
                          focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.green, width: 1)),
                          contentPadding: EdgeInsets.only(left: 8),
                          suffixIcon: Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                          border: const OutlineInputBorder()),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    TextFormField(
                      controller: _passWordController,
                      focusNode: _passWordFocusNode,
                      textInputAction: TextInputAction.done,
                      maxLines: 1,
                      style: TextStyle(fontSize: 18),
                      obscureText: _showPass ? false : true,
                      decoration: InputDecoration(
                          hintText: 'Nhập mật khẩu của bạn',
                          errorText: _passWordValidate
                              ? "Mật khẩu phải lớn hơn 5 kí tự"
                              : null,
                          enabledBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1)),
                          focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.green, width: 1)),
                          contentPadding: EdgeInsets.only(left: 8),
                          suffixIcon: InkWell(
                            onTap: (){
                              setState(() {
                                _showPass=!_showPass;
                              });
                            },
                            child: Icon(
                              _showPass ? Icons.vpn_key : Icons.remove_red_eye,
                              color: Colors.black,
                            ),
                          ),
                          border: const OutlineInputBorder()),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(ForGotPasswordPage.ROUTE_NAME)
                            .then((value) {
                          if (value != null) {
                            print("login: $value");
                            Fluttertoast.showToast(
                                msg: "Reset mật khẩu thành công",
                                gravity: ToastGravity.CENTER,
                                textColor: Colors.black87,
                                toastLength: Toast.LENGTH_LONG);
                          }
                        });
                      },
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text("Quên mật khẩu",
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.red,
                                fontSize: 18)),
                      ),
                    ),
                    _loginFail
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(_loginFailMessage ?? "",
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.red,
                                    fontSize: 16)),
                          )
                        : SizedBox(
                            height: screenHeight * 0.05,
                          ),
                    InkWell(
                      onTap: doSignIn,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: 45,
                        width: screenWidth,
                        child: Center(
                          child: Text(
                            'Đăng nhập',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    _loadingStatus
                        ? Center(child: CircularProgressIndicator())
                        : Container(),
                    Container(
                      //padding: MediaQuery.of(context).viewInsets,
                      margin: EdgeInsets.only(top: 8),
                      width: double.infinity,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: "Bạn chưa có tài khoản? ",
                            style:
                                TextStyle(color: Colors.black45, fontSize: 18),
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Đăng ký",
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.of(context)
                                        .pushNamed(RegisterPage.ROUTE_NAME),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontSize: 18))
                            ]),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () async {
                              if (await _googleSignIn.isSignedIn()) {
                                _handleSignOut();
                              }
                              _handleSignIn();
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  AssetImage("assets/images/google.png"),
                            )),
                        SizedBox(width: 16),
                        InkWell(
                            onTap: () async {
                              _handleFbSignIn();
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  AssetImage("assets/images/facebook.png"),
                            )),
                        SizedBox(width: 13),
                        InkWell(
                            onTap: _loginZalo,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                              AssetImage("assets/images/zalo-logo.png"),
                            )),
                        SizedBox(width: 6),
                        Platform.isIOS ? InkWell(
                            onTap: _loginApple,
                            child: Image.asset("assets/images/apple.png", width: 55, height: 55, fit: BoxFit.fill,)) : Container(),
                      ],
                    ),
//                    InkWell(
//                      onTap: () async {
//                        if (await _googleSignIn.isSignedIn()) {
//                          _handleSignOut();
//                        }
//                        _handleSignIn();
//                      },
//                      child: Card(
//                        elevation: 5,
//                        child: Padding(
//                          padding: const EdgeInsets.symmetric(
//                              vertical: 6, horizontal: 32),
//                          child: Row(
//                            children: [
//                              Image.asset(
//                                "assets/images/google.png",
//                                width: 40,
//                                height: 40,
//                                fit: BoxFit.fill,
//                              ),
//                              SizedBox(width: 16),
//                              Text(
//                                "Đăng nhập với Google",
//                                style: TextStyle(
//                                    fontSize: 18,
//                                    color: Colors.black,
//                                    fontWeight: FontWeight.w500),
//                              )
//                            ],
//                          ),
//                        ),
//                      ),
//                    ),
//                    SizedBox(height: 8),
//                    InkWell(
//                      onTap: () async {
//                        _handleFbSignIn();
//                      },
//                      child: Card(
//                        elevation: 5,
//                        child: Padding(
//                          padding: const EdgeInsets.symmetric(
//                              vertical: 6, horizontal: 32),
//                          child: Row(
//                            children: [
//                              Image.asset(
//                                "assets/images/facebook.png",
//                                width: 40,
//                                height: 40,
//                                fit: BoxFit.fill,
//                              ),
//                              SizedBox(width: 16),
//                              Text(
//                                "Đăng nhập với Facebook",
//                                style: TextStyle(
//                                    fontSize: 18,
//                                    color: Colors.black,
//                                    fontWeight: FontWeight.w500),
//                              )
//                            ],
//                          ),
//                        ),
//                      ),
//                    ),
//                    SizedBox(height: 8),
//                    InkWell(
//                      onTap: () async {
//                        _handleFbSignIn();
//                      },
//                      child: Card(
//                        elevation: 5,
//                        child: Padding(
//                          padding: const EdgeInsets.symmetric(
//                              vertical: 6, horizontal: 32),
//                          child: Row(
//                            children: [
//                              Image.asset(
//                                "assets/images/zalo.png",
//                                width: 40,
//                                height: 40,
//                                fit: BoxFit.fill,
//                              ),
//                              SizedBox(width: 16),
//                              Text(
//                                "Đăng nhập với Zalo",
//                                style: TextStyle(
//                                    fontSize: 18,
//                                    color: Colors.black,
//                                    fontWeight: FontWeight.w500),
//                              )
//                            ],
//                          ),
//                        ),
//                      ),
//                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
