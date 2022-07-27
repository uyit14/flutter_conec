import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/models/response/profile/change_password_response.dart';
import 'package:conecapp/models/response/profile/gift_response.dart';
import 'package:conecapp/models/response/profile/profile_response.dart';
import 'package:conecapp/ui/authen/pages/login_page.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:conecapp/ui/mypost/pages/mypost_page.dart';
import 'package:conecapp/ui/others/open_letter_page.dart';
import 'package:conecapp/ui/others/terms_condition_page.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:conecapp/ui/profile/pages/change_password_page.dart';
import 'package:conecapp/ui/profile/pages/detail_profile_page.dart';
import 'package:conecapp/ui/profile/pages/guide_page.dart';
import 'package:conecapp/ui/profile/pages/help_page.dart';
import 'package:conecapp/ui/profile/widgets/custom_profile_clipper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/globals.dart' as globals;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileBloc _profileBloc = ProfileBloc();
  HomeBloc _homeBloc = HomeBloc();
  String _name;
  String _address;
  String _province;
  String _type;
  String _avatar;
  String _token;
  bool _isTokenExpired = true;
  bool _isLoading = false;
  bool _isSocial = false;
  String version = "";

  @override
  void initState() {
    super.initState();
    getVersion();
    getToken();
  }

  void getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    print("version: " + version);
  }

  void getToken() async {
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    bool isSocial = await Helper.getIsSocial();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
      _isSocial = isSocial;
    });
    if (token != null && !expired) {
      giftCheck();
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
            globals.name = profile.name;
            globals.email = profile.email;
            globals.phone = profile.phoneNumber;
            globals.type = profile.type;

            setState(() {
              _isLoading = false;
              _name = profile.name;
              _province = profile.province;
              _address = '${profile.district ?? ""} ${profile.province}';
              _avatar = profile.avatar;
              _type = profile.type;
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

  int pushNumber = 0;
  int postNumber = 0;

  void showRemindDialog(BuildContext context) {
    Helper.showMissingDialog(context, "Bạn đang có",
        "$pushNumber lượt đẩy tin </br>$postNumber lượt ưu tiên tin");
  }

  void giftCheck() {
    _profileBloc.requestGetGiftResponse();
    _profileBloc.giftResponseStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
        case Status.COMPLETED:
          GiftResponse giftResponse = event.data;
          setState(() {
            pushNumber = giftResponse.remainPush;
            postNumber = giftResponse.remainPriority;
          });
          break;
          break;
        case Status.ERROR:
          break;
      }
    });
  }

  void requestGetGift() async {
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    bool isSocial = await Helper.getIsSocial();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
      _isSocial = isSocial;
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
            globals.type = profile.type;
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

  void registerDeviceToken(String deviceToken, String userId) async {
    String result2 =
        await _homeBloc.requestRegisterDeviceToken(deviceToken, userId);
    print("registerDeviceToken: $result2");
  }

  bool isShowPartner() {
    return _type == "Trainer" || _type == "Club";
  }

  @override
  void dispose() {
    super.dispose();
    _profileBloc.dispose();
    _homeBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: AppTheme.appBarSize),
      child: _isLoading
          ? Container(
              height: Helper.getScreenHeight(context),
              child: UILoadingOpacity())
          : Stack(
              children: [
                Column(
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
                                        Navigator.of(context)
                                            .pushNamed(
                                                DetailProfilePage.ROUTE_NAME)
                                            .then((value) => _profileBloc
                                                .requestGetProfile());
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
                                    Text(
                                        _isTokenExpired
                                            ? "Phiên đăng nhập hết hạn"
                                            : "Bạn chưa đăng nhập",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w500)),
                                    FlatButton.icon(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  LoginPage.ROUTE_NAME);
                                        },
                                        color: Colors.white,
                                        textColor: Colors.red,
                                        icon: Icon(Icons.assignment_ind),
                                        label: Text(
                                            _isTokenExpired
                                                ? "Đăng nhập lại"
                                                : 'Đăng nhập ngay',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500))),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(OpenLetterPage.ROUTE_NAME);
                      },
                      child: Row(
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {},
                            elevation: 2.0,
                            fillColor: Colors.white,
                            child: Icon(
                              Icons.message,
                              color: Colors.red,
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
                    // isShowPartner() ? InkWell(
                    //   onTap: () {
                    //     Navigator.of(context).pushNamed(PartnerMain.ROUTE_NAME);
                    //   },
                    //   child: Row(
                    //     children: <Widget>[
                    //       RawMaterialButton(
                    //         onPressed: () {},
                    //         elevation: 2.0,
                    //         fillColor: Colors.white,
                    //         child: Icon(
                    //           Icons.account_tree,
                    //           color: Colors.red,
                    //           size: 30,
                    //         ),
                    //         padding: EdgeInsets.all(15.0),
                    //         shape: CircleBorder(),
                    //       ),
                    //       Text(
                    //         "Thành viên",
                    //         style: TextStyle(
                    //             fontSize: 20, fontWeight: FontWeight.w400),
                    //       )
                    //     ],
                    //   ),
                    // ) : Container(),
                    // isShowPartner() ? SizedBox(height: 8) : Container(),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(GuidePage.ROUTE_NAME);
                      },
                      child: Row(
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {},
                            elevation: 2.0,
                            fillColor: Colors.white,
                            child: Icon(
                              Icons.add_to_home_screen,
                              color: Colors.red,
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
                              color: Colors.red,
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
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(MyPost.ROUTE_NAME);
                      },
                      child: Row(
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {},
                            elevation: 2.0,
                            fillColor: Colors.white,
                            child: Icon(
                              Icons.list,
                              color: Colors.red,
                              size: 30,
                            ),
                            padding: EdgeInsets.all(15.0),
                            shape: CircleBorder(),
                          ),
                          Text(
                            "Tin đăng của tôi",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        if (_token == null || _token.length == 0) {
                          Helper.showAuthenticationDialog(context);
                        } else {
                          showRemindDialog(context);
                        }
                      },
                      child: Row(
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {},
                            elevation: 2.0,
                            fillColor: Colors.white,
                            child: Icon(
                              Icons.card_giftcard,
                              color: Colors.red,
                              size: 30,
                            ),
                            padding: EdgeInsets.all(15.0),
                            shape: CircleBorder(),
                          ),
                          Text(
                            "Quà của tôi",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(HelpPage.ROUTE_NAME);
                      },
                      child: Row(
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {},
                            elevation: 2.0,
                            fillColor: Colors.white,
                            child: Icon(
                              Icons.help,
                              color: Colors.red,
                              size: 30,
                            ),
                            padding: EdgeInsets.all(15.0),
                            shape: CircleBorder(),
                          ),
                          Text(
                            "Trợ giúp",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                    ),
                    _token != null && !_isTokenExpired
                        ? SizedBox(height: 8)
                        : Container(),
                    _token != null && !_isTokenExpired && !_isSocial
                        ? InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(ChangePassWordPage.ROUTE_NAME)
                                  .then((value) {
                                if (value != null) {
                                  ChangePassWordResponse
                                      changePassWordResponse = value;
                                  updateToken(changePassWordResponse.token,
                                      changePassWordResponse.expires);
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
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  padding: EdgeInsets.all(15.0),
                                  shape: CircleBorder(),
                                ),
                                Text(
                                  "Đổi mật khẩu",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            ),
                          )
                        : Container(),
                    _token != null && !_isTokenExpired
                        ? SizedBox(height: 8)
                        : Container(),
                    _token != null && !_isTokenExpired && !_isSocial
                        ? InkWell(
                      onTap: () {
                        Helper.showDeleteDialog(context, "Xoá tài khoản",
                            "Bạn có chắc chắn muốn xoá tài khoản?",
                                () async {
                              final result =
                              await _profileBloc.deleteAccount();
                              if (result) {
                                //
                                Fluttertoast.showToast(
                                    msg: "Xoá tài khoản thành công",
                                    gravity: ToastGravity.CENTER);
                                //
                                registerDeviceToken(globals.deviceToken, "");
                                SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                                prefs.setString('token', null);
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    LoginPage.ROUTE_NAME,
                                        (Route<dynamic> route) => false);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Vui lòng thử lại",
                                    gravity: ToastGravity.CENTER);
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
                              Icons.person_remove_sharp,
                              color: Colors.red,
                              size: 30,
                            ),
                            padding: EdgeInsets.all(15.0),
                            shape: CircleBorder(),
                          ),
                          Text(
                            "Xoá tài khoản",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                    )
                        : Container(),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        Helper.showDeleteDialog(context, "Đăng xuất",
                            "Bạn có chắc chắn muốn đăng xuất?", () async {
                          registerDeviceToken(globals.deviceToken, "");
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString('token', null);
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              LoginPage.ROUTE_NAME,
                              (Route<dynamic> route) => false);
                        });
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            )
                          : Container(),
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onLongPress: () {
                        //Navigator.of(context).pushNamed(PhoneInfoPage.ROUTE_NAME);
                      },
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          "Version 1.0.14",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
                Positioned(
                  right: 22,
                  top: MediaQuery.of(context).size.height / 8,
                  child: CircleAvatar(
                    radius: 58,
                    backgroundColor: Colors.grey,
                    backgroundImage: _avatar != null
                        ? CachedNetworkImageProvider(_avatar)
                        : AssetImage("assets/images/avatar.png"),
                  ),
                ),
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
