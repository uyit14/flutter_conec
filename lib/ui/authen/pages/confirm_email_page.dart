import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/ui/authen/blocs/authen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../conec_home_page.dart';

class ConfirmEmailPage extends StatefulWidget {
  static const ROUTE_NAME = '/confirm-email-page';

  @override
  _ConfirmEmailPageState createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  String email;
  String password;
  String _apiErrorMess;
  bool _isLoading = false;
  bool _codeError = false;
  TextEditingController _codeController = TextEditingController();
  AuthenBloc _authenBloc = AuthenBloc();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    email = routeArgs['email'];
    password = routeArgs['password'];
  }

  void confirmEmail() {
    if (_codeController.text.length == 0) {
      setState(() {
        _codeError = true;
      });
      return;
    }
    //
    _authenBloc.requestConfirmEmail(
        email, password, _codeController.text.trim());
    _authenBloc.confirmEmailStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          setState(() {
            _isLoading = true;
          });
          break;
        case Status.COMPLETED:
          setState(() {
            _isLoading = false;
          });
          gotoHome(event.data);
          break;
        case Status.ERROR:
          setState(() {
            _isLoading = false;
          });
          setState(() {
            _apiErrorMess = event.message;
          });
          break;
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Xác nhận email")),
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: <Widget>[
              SizedBox(height: 32),
              TextFormField(
                maxLines: 1,
                controller: _codeController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                    hintText: "Nhập mã code 5 ký tự",
                    errorText: _codeError ? "Vui lòng nhập mã" : null,
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 1)),
                    contentPadding: EdgeInsets.only(left: 8),
                    suffixIcon: Icon(
                      Icons.code,
                      color: Colors.black,
                    ),
                    border: const OutlineInputBorder()),
              ),
              SizedBox(height: 8),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(),
              _apiErrorMess != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(_apiErrorMess,
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.red,
                              fontSize: 16)),
                    )
                  : Container(),
              SizedBox(height: 24),
              InkWell(
                onTap: confirmEmail,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 45,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Xác nhận',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
