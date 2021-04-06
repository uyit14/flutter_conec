import 'dart:io' as pf;

import 'package:badges/badges.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/ui/home/pages/home_page.dart';
import 'package:conecapp/ui/mypost/pages/post_action_page.dart';
import 'package:conecapp/ui/notify/pages/notify_page.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:conecapp/ui/profile/pages/edit_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_version/new_version.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/globals.dart' as globals;
import 'home/blocs/home_bloc.dart';
import 'home/pages/item_detail_page.dart';
import 'home/pages/items_by_category_page.dart';
import 'mypost/pages/mypost_page.dart';
import 'news/pages/news_detail_page.dart';
import 'news/pages/news_page.dart';
import 'news/pages/sell_detail_page.dart';
import 'profile/pages/profile_pages.dart';

class ConecHomePage extends StatefulWidget {
  static const ROUTE_NAME = '/home';

  @override
  _ConecHomePageState createState() => _ConecHomePageState();
}

class _ConecHomePageState extends State<ConecHomePage> {
  PageController _pageController = PageController(initialPage: 0);
  int _selectedPageIndex = 0;
  int _initIndex = 0;
  bool _isMissingData = true;
  var _profile;
  int _number = 0;
  ProfileBloc _profileBloc = ProfileBloc();
  HomeBloc _homeBloc = HomeBloc();

  String _token;
  bool _isTokenExpired = true;
  String _deviceToken = "";

  //For one signal
  String _debugLabelString = "";
  String _emailAddress;
  String _externalUserId;
  bool _enableConsentButton = false;

  // CHANGE THIS parameter to true if you want to test GDPR privacy consent
  bool _requireConsent = false;

  void getToken() async {
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
    });
    if (!_isTokenExpired && _token != null) {
      _profileBloc.requestGetProfile();
      _homeBloc.requestGetNumberNotify();
      _profileBloc.profileStream.listen((event) {
        if (event.status == Status.COMPLETED) {
          final profile = event.data;
          globals.province = profile.province;
          globals.district = profile.district;
          globals.ward = profile.ward;
          globals.address = profile.address;
          globals.phone = profile.phoneNumber;
          globals.ownerId = profile.id;
          registerDeviceToken(_deviceToken, profile.id);
          if (profile.name != null &&
              profile.type != null &&
              profile.phoneNumber != null) {
            setState(() {
              _profile = profile;
              _isMissingData = false;
            });
          } else {
            setState(() {
              _profile = profile;
            });
            return;
          }
        }
      });
      _homeBloc.numberNotifyStream.listen((event) {
        if (event.status == Status.COMPLETED) {
          setState(() {
            _number = event.data;
          });
        }
      });
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _initTab1Page(int index, int initIndex) {
    debugPrint("initIndex " + initIndex.toString());
    _selectPage(index);
    setState(() {
      _initIndex = initIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    //getLocation();
    // NewVersion(
    //     context: context,
    //     iOSId: 'com.conec.conecSport',
    //     androidId: 'com.conec.flutter_conec',
    //     dialogTitle: "Cập nhật",
    //     dialogText: "Conec đã có bản cập nhật mới trên cửa hàng",
    //     dismissText: "Để sau",
    //     updateText: "Cập nhật"
    // ).showAlertIfNecessary();
    checkVersion(context);
    initOneSignal("7075e16c-c1fb-4d33-93b1-1c8cf007c294");
    getToken();
  }

  void checkVersion(BuildContext context) async {
    final newVersion = NewVersion(context: context);
    final status = await newVersion.getVersionStatus();
    String newStoreVersion;
    //add this check because ios version local = store + 1;
    if (status.storeVersion.length > 0) {
      if (pf.Platform.isIOS) {
        int newSVer = int.parse(status.storeVersion.substring(3, 5),
            onError: (source) => 10);
        int newSVerPlush = newSVer + 1;
        String storeVerFinal = '1.0.$newSVerPlush';
        print('storeVer: ' + storeVerFinal);
        newStoreVersion = storeVerFinal;
      } else {
        newStoreVersion = status.storeVersion;
      }
    }
    print(status.localVersion + "-" + newStoreVersion);

    if (status.localVersion != newStoreVersion) {
      Helper.showUpdateVersionDialog(
          context, "Cập nhật", "Conec đã có bản cập nhật mới trên cửa hàng",
          () async {
        if (pf.Platform.isIOS) {
          await launch(
              "https://apps.apple.com/vn/app/id1539002688?l=vi");
        } else {
          await launch(
              "https://play.google.com/store/apps/details?id=com.conec.flutter_conec");
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    giftCheck(context);
  }

  void giftCheck(BuildContext context) async {
    bool result = await _homeBloc.requestGiftCheck();
    if (result) {
      Helper.showGiftCheckDialog(context, "Điểm danh nhận quà",
          "Quà tháng này của bạn: \n5 lượt đẩy tin \n5 tin ưu tiên", () async {
        Navigator.of(context).pop();
        bool result2 = await _homeBloc.requestGiftReceive();
        if (result2) {
          Helper.showMissingDialog(context, "Nhận quà thành công", "");
        } else {
          Helper.showMissingDialog(context, "Nhận quà thất bại",
              "Bạn đã nhận quà hoặc chưa tới thời gian nhận");
        }
      });
    }
  }

  void registerDeviceToken(String deviceToken, String userId) async {
    String result2 =
        await _homeBloc.requestRegisterDeviceToken(deviceToken, userId);
    print("registerDeviceToken: $result2");
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initOneSignal(oneSignalAppId) async {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    var settings = {
      OSiOSSettings.autoPrompt: true,
      OSiOSSettings.inAppLaunchUrl: true
    };

    OneSignal.shared.init(oneSignalAppId, iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    print("DeviceToken: ${status.subscriptionStatus.userId}");
    globals.deviceToken = status.subscriptionStatus.userId;
    setState(() {
      _deviceToken = status.subscriptionStatus.userId;
    });
    // will be called whenever a notification is received
    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      print('Received: ' + notification?.payload?.body ?? '');
    });

    // will be called whenever a notification is opened/button pressed.
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      //print('Opened: ' + result.notification?.payload?.body ?? '');
      print(
          "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}");
      print(
          "postIdddd: " + result.notification.payload.additionalData["postId"]);
      if (result.notification.payload.additionalData["postId"] != null &&
          result.notification.payload.additionalData["type"] != null) {
        String postId = result.notification.payload.additionalData["postId"];
        String type = result.notification.payload.additionalData["type"];
        String title = result.notification.payload.title;
        print("Open: $type");
        if (type == "TOPIC") {
          Navigator.of(context)
              .pushNamed(ItemDetailPage.ROUTE_NAME, arguments: {
            'postId': postId,
            'title': title,
          });
        }
        if (type == "ADS") {
          Navigator.of(context).pushNamed(SellDetailPage.ROUTE_NAME,
              arguments: {'postId': postId});
        }
        if (type == "NEWS") {
          Navigator.of(context).pushNamed(NewsDetailPage.ROUTE_NAME,
              arguments: {'postId': postId});
        }
      }
    });
  }

  void getLocation() async {
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("latttt: ${position.latitude}" ?? "---aaa---");
    print("longgg: ${position.longitude}" ?? "---aaa---");
    globals.latitude = position.latitude;
    globals.longitude = position.longitude;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _selectedPageIndex == 0
            ? AppBar(
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [Colors.red, Colors.redAccent[200]],
                  )),
                ),
                title: Text(
                  "Conec Sport",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.black, size: 26),
                backgroundColor: Colors.redAccent[200],
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search, size: 32),
                    onPressed: () => Navigator.of(context).pushNamed(
                        ItemByCategory.ROUTE_NAME,
                        arguments: {'id': null, 'title': null}),
                  ),
                  _token != null && !_isTokenExpired
                      ? Badge(
                          padding: const EdgeInsets.all(3.0),
                          position: BadgePosition.topEnd(top: 5, end: -7),
                          badgeContent: Text(
                            _number.toString(),
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          badgeColor: Colors.yellowAccent,
                          showBadge: _number > 0 ? true : false,
                          child: InkWell(
                            child: Icon(
                              Icons.notifications,
                              size: 32,
                              color: Colors.black87.withOpacity(0.8),
                            ),
                            onTap: () => Navigator.of(context)
                                .pushNamed(NotifyPage.ROUTE_NAME)
                                .then((value) {
                              if (value == 1) {
                                _homeBloc.requestGetNumberNotify();
                              }
                            }),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    width: 16,
                  )
                ],
              )
            : null,
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            HomePage(callback: _initTab1Page),
            NewsPage(_initIndex),
            MyPost(),
            ProfilePage()
          ],
        ),
        floatingActionButton: Container(
          child: FloatingActionButton(
            onPressed: () {
              if (_token == null || _token.length == 0) {
                Helper.showAuthenticationDialog(context);
              } else {
                if (_isTokenExpired) {
                  Helper.showTokenExpiredDialog(context);
                } else {
                  if (_isMissingData) {
                    Helper.showMissingDataDialog(context, () {
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pushNamed(EditProfilePage.ROUTE_NAME,
                              arguments: _profile)
                          .then((value) {
                        if (value == 0) {
                          _profileBloc.requestGetProfile();
                        }
                      });
                    });
                  } else {
                    Navigator.of(context).pushNamed(PostActionPage.ROUTE_NAME);
                  }
                }
              }
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            // child: SizedBox.fromSize(
            //   size: Size(56, 56), // button width and height
            //   child: ClipOval(
            //     child: Material(
            //       color: Colors.red, // button color
            //       child: InkWell(
            //         splashColor: Colors.green, // splash color
            //         onTap: () {}, // button pressed
            //         child: Center(
            //             child: Text(
            //           "Đăng tin",
            //           textAlign: TextAlign.center,
            //           style: TextStyle(
            //               color: Colors.white, fontWeight: FontWeight.bold),
            //         )), // text
            //       ),
            //     ),
            //   ),
            // ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        extendBody: true,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Container(
            margin: EdgeInsets.only( left: Helper.isTablet(context) ? 24 : 12, right: Helper.isTablet(context) ? 32 : 16),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                InkWell(
                  onTap: () => _selectPage(0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.home,
                        size: 30,
                        color:
                            _selectedPageIndex == 0 ? Colors.red : Colors.grey,
                      ),
                      Text("Trang chủ",
                          style: TextStyle(
                            fontSize: 13,
                            color: _selectedPageIndex == 0
                                ? Colors.red
                                : Colors.grey,
                          )),
                      SizedBox(height: 2)
                    ],
                  ),
                ),
                SizedBox(
                    width: Helper.isTablet(context)
                        ? Helper.getScreenWidth(context) / 7
                        : Helper.getScreenWidth(context) / 14),
                InkWell(
                  onTap: () => _selectPage(1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.explore,
                        size: 30,
                        color:
                            _selectedPageIndex == 1 ? Colors.red : Colors.grey,
                      ),
                      Text(" Dụng cụ  ",
                          style: TextStyle(
                            fontSize: 13,
                            color: _selectedPageIndex == 1
                                ? Colors.red
                                : Colors.grey,
                          )),
                      SizedBox(height: 2)
                    ],
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () => _selectPage(2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.list,
                        size: 30,
                        color:
                            _selectedPageIndex == 2 ? Colors.red : Colors.grey,
                      ),
                      Text("Tin đăng",
                          style: TextStyle(
                            fontSize: 13,
                            color: _selectedPageIndex == 2
                                ? Colors.red
                                : Colors.grey,
                          )),
                      SizedBox(height: 2)
                    ],
                  ),
                ),
                SizedBox(
                    width: Helper.isTablet(context)
                        ? Helper.getScreenWidth(context) / 7
                        : Helper.getScreenWidth(context) / 10),
                InkWell(
                  onTap: () => _selectPage(3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.more_horiz,
                        size: 30,
                        color:
                            _selectedPageIndex == 3 ? Colors.red : Colors.grey,
                      ),
                      Text("  Thêm  ",
                          style: TextStyle(
                            fontSize: 13,
                            color: _selectedPageIndex == 3
                                ? Colors.red
                                : Colors.grey,
                          )),
                      SizedBox(height: 2)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
- filter at home
- filter at ads
- add, update ads, news
- google map
*/
