import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/ui/authen/blocs/authen_bloc.dart';
import 'package:conecapp/ui/authen/pages/reset_pass_page.dart';
import 'package:flutter/material.dart';

class ForGotPasswordPage extends StatefulWidget {
  static const ROUTE_NAME = '/forgot-pass';

  @override
  _ForGotPasswordPageState createState() => _ForGotPasswordPageState();
}

class _ForGotPasswordPageState extends State<ForGotPasswordPage> {
  TextEditingController _userNameController = TextEditingController();
  bool _isError = false;
  AuthenBloc _authenBloc = AuthenBloc();
  bool _apiError = false;
  bool _apiLoading = false;
  String _loginFailMessage;

  @override
  void dispose() {
    super.dispose();
    _authenBloc.dispose();
  }

  void verifyUserName(){
    if(_userNameController.text.length == 0){
      setState(() {
        _isError = true;
      });
      return;
    }else{
//      Navigator.of(context).pushNamed(ResetPasswordPage.ROUTE_NAME, arguments: {
//        'userName' : _userNameController.text.trim()
//      });
      setState(() {
        _isError = false;
      });
      _authenBloc.requestVerifyUsername(_userNameController.text.trim());
      _authenBloc.verifyUserStream.listen((event) {
        switch(event.status){
          case Status.LOADING:
            setState(() {
              _apiLoading = true;
            });
            break;
          case Status.COMPLETED:
            setState(() {
              _apiError = false;
              _apiLoading = false;
            });
            Navigator.of(context).pushNamed(ResetPasswordPage.ROUTE_NAME, arguments: {
              'userName' : _userNameController.text.trim()
            });
            break;
          case Status.ERROR:
            setState(() {
              _apiError = true;
              _apiLoading = false;
              _loginFailMessage = event.message;
            });
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Quên mật khẩu")),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                maxLines: 1,
                controller: _userNameController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                    hintText: 'Nhập tên đăng nhập',
                    errorText: _isError ? "Vui lòng nhập tên đăng nhập" : null,
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 1)),
                    contentPadding: EdgeInsets.only(left: 8),
                    suffixIcon: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    border: const OutlineInputBorder()),
              ),
              SizedBox(height: 8),
              _apiLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(),
              _apiError
                  ? Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                    _loginFailMessage ?? "",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.red,
                        fontSize: 16)),
              )
                  : Container(),
              SizedBox(height: 32),
              InkWell(
                onTap: verifyUserName,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 45,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Tiếp theo',
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
