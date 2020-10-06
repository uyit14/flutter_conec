import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/ui/authen/blocs/authen_bloc.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  static const ROUTE_NAME = '/reset-pass';

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController _userNameController;
  TextEditingController _newPassController = TextEditingController();
  TextEditingController _confirmPassController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  AuthenBloc _authenBloc = AuthenBloc();

  //
  bool _newPassError = false;
  bool _codeError = false;
  bool _confirmPassError = false;
  var username;
  String _apiErrorMess;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    username = routeArgs['userName'];
    _userNameController = TextEditingController(text: username);
  }

  @override
  void dispose() {
    super.dispose();
    _authenBloc.dispose();
  }

  void resetPassword() {
    if (_newPassController.text.length < 7) {
      setState(() {
        _newPassError = true;
        _codeError = false;
        _confirmPassError = false;
      });
      return;
    }
    if(_confirmPassController.text != _newPassController.text){
      setState(() {
        _newPassError = false;
        _codeError = false;
        _confirmPassError = true;
      });
      return;
    }
    if (_codeController.text.length == 0) {
      setState(() {
        _codeError = true;
        _newPassError = false;
        _confirmPassError = false;
      });
      return;
    }
    //
    setState(() {
      _codeError = false;
      _newPassError = false;
      _confirmPassError = false;
    });
    _authenBloc.requestResetPass(
        username, _newPassController.text.trim(), _codeController.text.trim());
    listenStream();
  }

  void listenStream() {
    _authenBloc.resetPassStream.listen((event) {
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
          if (event.data) {
            Navigator.of(context).pop(true);
            Navigator.of(context).pop(true);
            print("reset success");
          }
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Reset mật khẩu")),
        resizeToAvoidBottomPadding: false,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: <Widget>[
              SizedBox(height: 32),
              TextFormField(
                maxLines: 1,
                enabled: false,
                textInputAction: TextInputAction.done,
                controller: _userNameController,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
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
              SizedBox(height: 16),
              TextFormField(
                maxLines: 1,
                controller: _newPassController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                    hintText: "Nhập mật khẩu mới",
                    errorText:
                        _newPassError ? "Mật khẩu phải nhiều hơn 7 ký tự" : null,
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 1)),
                    contentPadding: EdgeInsets.only(left: 8),
                    suffixIcon: Icon(
                      Icons.vpn_key,
                      color: Colors.black,
                    ),
                    border: const OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextFormField(
                maxLines: 1,
                controller: _confirmPassController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                    hintText: "Xác nhận mật khẩu",
                    errorText:
                    _confirmPassError ? "Xác nhận mật khẩu không đúng" : null,
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 1)),
                    contentPadding: EdgeInsets.only(left: 8),
                    suffixIcon: Icon(
                      Icons.vpn_key,
                      color: Colors.black,
                    ),
                    border: const OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextFormField(
                maxLines: 1,
                controller: _codeController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                    hintText: "Nhập mã code 5 ký tự được gửi đến email của bạn",
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
                onTap: resetPassword,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 45,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Reset mật khẩu',
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
