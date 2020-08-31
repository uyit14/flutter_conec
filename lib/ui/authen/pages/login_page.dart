import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/ui/authen/blocs/authen_bloc.dart';
import 'package:conecapp/ui/authen/pages/forgot_password_page.dart';
import 'package:conecapp/ui/authen/pages/register_page.dart';
import 'package:conecapp/ui/authen/pages/signup_page.dart';
import 'package:conecapp/ui/conec_home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String _loginFailMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_authenBloc = Provider.of<AuthenBloc>(context);
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
    if (_passWordController.text.length < 7) {
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
          gotoHome(event.data);
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

  void gotoHome(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    Navigator.of(context).pushNamedAndRemoveUntil(
        ConecHomePage.ROUTE_NAME, (Route<dynamic> route) => false);
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
                      gradient: LinearGradient(
                          colors: [Colors.red, Colors.redAccent[200]],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(screenHeight * 0.3 / 2))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: FlutterLogo(
                        size: screenHeight > screenWidth
                            ? screenHeight * 0.1
                            : screenWidth * 0.1,
                      )),
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
                          hintText: 'Nhập tài khoản của bạn',
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
                      obscureText: true,
                      decoration: InputDecoration(
                          hintText: 'Nhập mật khẩu của bạn',
                          errorText: _passWordValidate
                              ? "Mật khẩu phải lớn hơn 6 kí tự"
                              : null,
                          enabledBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1)),
                          focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.green, width: 1)),
                          contentPadding: EdgeInsets.only(left: 8),
                          suffixIcon: Icon(
                            Icons.vpn_key,
                            color: Colors.black,
                          ),
                          border: const OutlineInputBorder()),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(ForGotPasswordPage.ROUTE_NAME);
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
                            child: Text(
                                _loginFailMessage ?? "",
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
