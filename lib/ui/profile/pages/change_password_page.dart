import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePassWordPage extends StatefulWidget {
  static const ROUTE_NAME = '/change-pass';

  @override
  _ChangePassWordPageState createState() => _ChangePassWordPageState();
}

class _ChangePassWordPageState extends State<ChangePassWordPage> {
  TextEditingController _oldPassController = TextEditingController();
  TextEditingController _newPassController = TextEditingController();
  TextEditingController _confirmNewPassController = TextEditingController();
  ProfileBloc _profileBloc = ProfileBloc();
  bool _oldPassError = false;
  bool _newPassError = false;
  bool _confirmNewPassError = false;
  bool _isLoading = false;
  bool _apiError = false;
  String _errorMessage;

  void changePassword() {
    if (_oldPassController.text.length == 0) {
      setState(() {
        _oldPassError = true;
        _newPassError = false;
        _confirmNewPassError = false;
      });
      return;
    }
    if (_newPassController.text.length < 7) {
      setState(() {
        _oldPassError = false;
        _newPassError = true;
        _confirmNewPassError = false;
      });
      return;
    }
    if (_confirmNewPassController.text != _newPassController.text) {
      setState(() {
        _oldPassError = false;
        _newPassError = false;
        _confirmNewPassError = true;
      });
      return;
    }
    //
    setState(() {
      _apiError = false;
      _confirmNewPassError = false;
    });
    _profileBloc.requestChangePassword(
        _oldPassController.text.trim(), _newPassController.text.trim());
    _profileBloc.changePassStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          setState(() {
            _isLoading = true;
          });
          break;
        case Status.COMPLETED:
          setState(() {
            _apiError = false;
            _isLoading = false;
          });
          Fluttertoast.showToast(msg: "Đổi mật khẩu thành công", textColor: Colors.black87);
          Navigator.of(context).pop(event.data);
          break;
        case Status.ERROR:
          print("---> ${event.message}");
          setState(() {
            _apiError = true;
            _isLoading = false;
            _errorMessage = event.message;
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Đổi mật khẩu")),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 18, vertical: 32),
          child: Column(
            children: [
              TextFormField(
                maxLines: 1,
                style: TextStyle(fontSize: 18),
                textInputAction: TextInputAction.next,
                obscureText: true,
                controller: _oldPassController,
                decoration: InputDecoration(
                    hintText: 'Mật khẩu cũ',
                    errorText:
                        _oldPassError ? "Vui lòng nhập mật khẩu cũ" : null,
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
                controller: _newPassController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    hintText: 'Mật khẩu mới',
                    errorText: _newPassError
                        ? "Mật khẩu mới phải lớn hơn 7 ký tự"
                        : null,
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 1)),
                    contentPadding: EdgeInsets.only(left: 8),
                    prefixIcon: Icon(
                      Icons.confirmation_number,
                      color: Colors.green,
                    ),
                    border: const OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextFormField(
                maxLines: 1,
                style: TextStyle(fontSize: 18),
                obscureText: true,
                textInputAction: TextInputAction.done,
                controller: _confirmNewPassController,
                decoration: InputDecoration(
                    hintText: 'Nhập lại mật khẩu mới',
                    errorText: _confirmNewPassError
                        ? "Xác nhận mật khẩu không đúng"
                        : null,
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 1)),
                    contentPadding: EdgeInsets.only(left: 8),
                    prefixIcon: Icon(
                      Icons.confirmation_number,
                      color: Colors.green,
                    ),
                    border: const OutlineInputBorder()),
              ),
              SizedBox(height: 8),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(),
              _apiError
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(_errorMessage ?? "",
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.red,
                              fontSize: 16)),
                    )
                  : Container(),
              SizedBox(height: 32),
              InkWell(
                onTap: changePassword,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 45,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Đổi mật khẩu',
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
