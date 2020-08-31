import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/dummy/dummy_data.dart';
import 'package:conecapp/models/response/profile/profile_response.dart';
import 'package:conecapp/ui/authen/pages/login_page.dart';
import 'package:conecapp/ui/others/open_letter_page.dart';
import 'package:conecapp/ui/others/terms_condition_page.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:conecapp/ui/profile/pages/detail_profile_page.dart';
import 'package:conecapp/ui/profile/widgets/custom_profile_clipper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/globals.dart' as globals;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileBloc _profileBloc;
  String _name;
  String _address;
  String _province;
  String _avatar;

  @override
  void initState() {
    super.initState();
    if (globals.isSigned) {
      _profileBloc = ProfileBloc();
      _profileBloc.requestGetProfile();
      _profileBloc.profileStream.listen((event) {
        switch (event.status) {
          case Status.COMPLETED:
            Profile profile = event.data;
            setState(() {
              _name = profile.name;
              _province = profile.province;
              _address = '${profile.district} ${profile.province}';
              _avatar = profile.avatar;
            });
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: AppTheme.appBarSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipPath(
                clipper: CustomProfileClipper(),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [Colors.red, Colors.red[200]],
                  )),
                ),
              ),
              Positioned(
                left: 18,
                top: 18,
                child: globals.isSigned
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_name ?? "Chưa cập nhật họ tên",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500)),
                          Text(
                              _province == null
                                  ? "Chưa cập nhật địa chỉ"
                                  : _address,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400)),
                          InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(DetailProfilePage.ROUTE_NAME);
                            },
                            child: Text("Xem trang cá nhân",
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400)),
                          )
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          Text("Bạn chưa đăng nhập",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500)),
                          FlatButton.icon(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              onPressed: () {
                                Navigator.of(context)
                                    .pushReplacementNamed(LoginPage.ROUTE_NAME);
                              },
                              color: Colors.white,
                              textColor: Colors.red,
                              icon: Icon(Icons.assignment_ind),
                              label: Text("Đăng nhập ngay",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500))),
                        ],
                      ),
              ),
              Positioned(
                right: 22,
                top: 18,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _avatar != null
                      ? CachedNetworkImageProvider(_avatar)
                      : AssetImage("assets/images/avatar.png"),
                ),
              )
            ],
          ),
          SizedBox(height: 32),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(OpenLetterPage.ROUTE_NAME);
            },
            child: Row(
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () {},
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 30,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
                Text(
                  "Thư ngỏ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            child: Row(
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () {},
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Icon(
                    Icons.add_to_home_screen,
                    color: Colors.green,
                    size: 30,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
                Text(
                  "Hướng dẫn sử dụng",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(TermConditionPage.ROUTE_NAME);
            },
            child: Row(
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () {},
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Icon(
                    Icons.verified_user,
                    color: Colors.orange,
                    size: 30,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
                Text(
                  "Chính sách & điều khoản",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('token', null);
              globals.isSigned = false;
              Navigator.of(context).pushNamedAndRemoveUntil(
                  LoginPage.ROUTE_NAME, (Route<dynamic> route) => false);
            },
            child: globals.isSigned
                ? Row(
                    children: <Widget>[
                      RawMaterialButton(
                        onPressed: () {},
                        elevation: 2.0,
                        fillColor: Colors.white,
                        child: Icon(
                          Icons.exit_to_app,
                          color: Colors.red,
                          size: 30,
                        ),
                        padding: EdgeInsets.all(15.0),
                        shape: CircleBorder(),
                      ),
                      Text(
                        "Đăng xuất",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                      )
                    ],
                  )
                : Container(),
          )
        ],
      ),
    );
  }
}

/*
return Container(
      child: Center(
          child: globals.isSigned
              ? RaisedButton(
            child: Text("Signed out"),
            onPressed: () async {
              SharedPreferences prefs =
              await SharedPreferences.getInstance();
              prefs.setString('token', null);
              globals.isSigned = false;
              Navigator.of(context).pushNamedAndRemoveUntil(
                  LoginPage.ROUTE_NAME,
                      (Route<dynamic> route) => false);
            },
          )
              : RaisedButton(
            onPressed: () {
              Navigator.of(context)
                  .pushReplacementNamed(LoginPage.ROUTE_NAME);
            },
            child: Text(
              "GOTO LOGIN",
              style: TextStyle(color: Colors.white),
            ),
          )),
    );
*/
