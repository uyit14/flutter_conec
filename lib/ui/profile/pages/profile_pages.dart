import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/models/response/profile/change_password_response.dart';
import 'package:conecapp/models/response/profile/profile_response.dart';
import 'package:conecapp/ui/authen/pages/login_page.dart';
import 'package:conecapp/ui/others/open_letter_page.dart';
import 'package:conecapp/ui/others/terms_condition_page.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:conecapp/ui/profile/pages/detail_profile_page.dart';
import 'package:conecapp/ui/profile/pages/change_password_page.dart';
import 'package:conecapp/ui/profile/pages/info_page.dart';
import 'package:conecapp/ui/profile/widgets/custom_profile_clipper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileBloc _profileBloc = ProfileBloc();
  String _name;
  String _address;
  String _province;
  String _avatar;
  String _token;
  bool _isTokenExpired = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  void getToken() async {
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
    });
    if (token != null && !expired) {
      _profileBloc.requestGetProfile();
      _profileBloc.profileStream.listen((event) {
        switch (event.status) {
          case Status.LOADING:
            setState(() {
              _isLoading = true;
            });
            break;
          case Status.COMPLETED:
            Profile profile = event.data;
            setState(() {
              _isLoading = false;
              _name = profile.name;
              _province = profile.province;
              _address = '${profile.district ?? ""} ${profile.province}';
              _avatar = profile.avatar;
            });
            break;
          case Status.ERROR:
            setState(() {
              _isLoading = false;
            });
            Fluttertoast.showToast(
                msg: "Không tải được thông tin", gravity: ToastGravity.CENTER);
            break;
        }
      });
    }
  }

  void updateToken(String token, String expiredDay) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    prefs.setString('expired', expiredDay);
    _profileBloc.requestGetProfile();
  }

  @override
  void dispose() {
    super.dispose();
    _profileBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: AppTheme.appBarSize),
      child: _isLoading
          ? Container(
              height: Helper.getScreenHeight(context),
              child: UILoadingOpacity())
          : Column(
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
                      child: _token != null && !_isTokenExpired
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
                                    Navigator.of(context).pushNamed(
                                        DetailProfilePage.ROUTE_NAME);
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
                                Text(_isTokenExpired ? "Phiên đăng nhập hết hạn" : "Bạn chưa đăng nhập",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500)),
                                FlatButton.icon(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushReplacementNamed(
                                              LoginPage.ROUTE_NAME);
                                    },
                                    color: Colors.white,
                                    textColor: Colors.red,
                                    icon: Icon(Icons.assignment_ind),
                                    label: Text(_isTokenExpired ? "Đăng nhập lại": 'Đăng nhập ngay',
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(TermConditionPage.ROUTE_NAME);
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ),
                _token != null && !_isTokenExpired ? SizedBox(height: 8) : Container(),
                _token != null && !_isTokenExpired
                    ? InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(InfoPage.ROUTE_NAME);
                  },
                  child: Row(
                    children: <Widget>[
                      RawMaterialButton(
                        onPressed: () {},
                        elevation: 2.0,
                        fillColor: Colors.white,
                        child: Icon(
                          Icons.insert_drive_file,
                          color: Colors.cyan,
                          size: 30,
                        ),
                        padding: EdgeInsets.all(15.0),
                        shape: CircleBorder(),
                      ),
                      Text(
                        "Thông tin trang",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                )
                    : Container(),
                _token != null && !_isTokenExpired ? SizedBox(height: 8) : Container(),
                _token != null && !_isTokenExpired
                    ? InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(ChangePassWordPage.ROUTE_NAME)
                              .then((value) {
                            if (value != null) {
                              ChangePassWordResponse changePassWordResponse = value;
                              updateToken(changePassWordResponse.token, changePassWordResponse.expires);
                            }
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            RawMaterialButton(
                              onPressed: () {},
                              elevation: 2.0,
                              fillColor: Colors.white,
                              child: Icon(
                                Icons.swap_horizontal_circle,
                                color: Colors.purple,
                                size: 30,
                              ),
                              padding: EdgeInsets.all(15.0),
                              shape: CircleBorder(),
                            ),
                            Text(
                              "Đổi mật khẩu",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      )
                    : Container(),
                SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('token', null);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        LoginPage.ROUTE_NAME, (Route<dynamic> route) => false);
                  },
                  child: _token != null && !_isTokenExpired
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
