import 'dart:io' as pf;

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/partner_module/ui/member/add_member_page.dart';
import 'package:conecapp/partner_module/ui/member/member_group_page.dart';
import 'package:conecapp/partner_module/ui/member/member_page.dart';
import 'package:conecapp/partner_module/ui/member/requests_page.dart';
import 'package:conecapp/partner_module/ui/notify/add_notify_page.dart';
import 'package:conecapp/partner_module/ui/notify/notify_partner_page.dart';
import 'package:conecapp/ui/chat/chat_list_page.dart';
import 'package:conecapp/ui/chat/chat_page.dart';
import 'package:conecapp/ui/home/pages/home_page.dart';
import 'package:conecapp/ui/mypost/pages/post_action_page.dart';
import 'package:conecapp/ui/news/widgets/news_widget.dart';
import 'package:conecapp/ui/news/widgets/sell_widget.dart';
import 'package:conecapp/ui/notify/pages/notify_page.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:conecapp/ui/profile/pages/edit_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_version/new_version.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:signalr_client/http_connection_options.dart';
import 'package:signalr_client/hub_connection.dart';
import 'package:signalr_client/hub_connection_builder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/globals.dart' as globals;
import 'home/blocs/home_bloc.dart';
import 'home/pages/item_detail_page.dart';
import 'home/pages/items_by_category_page.dart';
import 'member2/fl_main_page.dart';
import 'mypost/pages/mypost_page.dart';
import 'news/pages/news_detail_page.dart';
import 'news/pages/news_page.dart';
import 'news/pages/sell_detail_page.dart';
import 'profile/pages/profile_pages.dart';
import '../common/ui/speed_dial.dart' as mySpeedDial;

class ConecHomePage extends StatefulWidget {
  static const ROUTE_NAME = '/home';

  @override
  _ConecHomePageState createState() => _ConecHomePageState();
}

class _ConecHomePageState extends State<ConecHomePage> {
  PageController _pageController = PageController(initialPage: 0);
  int _selectedPageIndex = 0;
  bool isCallApi = false;
  int _initIndex = 0;
  bool _isMissingData = true;
  var _profile;
  int _number = 0;
  ProfileBloc _profileBloc = ProfileBloc();
  HomeBloc _homeBloc = HomeBloc();

  String _token;
  bool _isTokenExpired = true;
  String _deviceToken = "";
  String _numberMessage = "";

  //For one signal
  String _debugLabelString = "";
  String _emailAddress;
  String _externalUserId;
  bool _enableConsentButton = false;

  // CHANGE THIS parameter to true if you want to test GDPR privacy consent
  bool _requireConsent = false;

  //
  final serverUrl = Helper.baseURL + "/appNotifyHub";
  HubConnection hubConnection;
  HttpConnectionOptions connectionOptions;
  String send = "SendMessage";
  String rev = "ReceiveMessage";

  void getToken() async {
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
    });
    if (!_isTokenExpired && _token != null) {
      _profileBloc.requestGetProfile();
      getNumberOfNotify();
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

  void getNumberOfNotify() async {
    _homeBloc.requestGetNumberNotify();
    String numberMessage = await _homeBloc.requestGetConversationCounter();
    setState(() {
      _numberMessage = numberMessage;
    });
  }

  void initSignalR() async {
    connectionOptions = HttpConnectionOptions(
        accessTokenFactory: () async => await Helper.token());
    hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl, options: connectionOptions)
        .build();
    hubConnection.on(rev, _handleNewMessage);
  }

  void startConnection() async {
    await hubConnection.start();
    if (hubConnection.state == HubConnectionState.Connected) {
      print("Connected");
    }
    if (hubConnection.state == HubConnectionState.Disconnected) {
      print("Disconnected");
    }
  }

  void _handleNewMessage(dynamic mess) {
    getNumberOfNotify();
    setState(() {});
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
    isCallApi = true;
    initSignalR();
    startConnection();
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
    if (pf.Platform.isIOS) {
      checkAppVersionApi();
    } else {
      //checkVersion(context);
    }
    initOneSignal("7075e16c-c1fb-4d33-93b1-1c8cf007c294");
    getToken();
  }

  void checkAppVersionApi() async {
    final apiAppVersion = await _homeBloc.requestGetAppVersion();
    String currentAppVersion = await Helper.getAppVersion();
    Helper.appLog(
        className: "ConecHomePage",
        functionName: "checkAppVersionApi",
        message: '$apiAppVersion - $currentAppVersion');
    if (currentAppVersion == null) {
      Helper.setAppVersion(apiAppVersion);
      return;
    }
    if (currentAppVersion != apiAppVersion) {
      Helper.showUpdateVersionDialog(
          context, "Cập nhật", "Conec đã có bản cập nhật mới trên cửa hàng",
          () async {
        Helper.setAppVersion(apiAppVersion);
        if (pf.Platform.isIOS) {
          await launch('https://apps.apple.com/vn/app/id1539002688?l=vi');
        } else {
          await launch(
              "https://play.google.com/store/apps/details?id=com.conec.flutter_conec");
        }
      });
    }
  }

  void checkVersion(BuildContext context) async {
    final newVersion = NewVersion(context: context);
    final status = await newVersion.getVersionStatus();
//    String newStoreVersion;
//    //add this check because ios version local = store + 1;
//    if (status.storeVersion.length > 0) {
//      if (pf.Platform.isIOS) {
//        int newSVer = int.parse(status.storeVersion.substring(3, 5),
//            onError: (source) => 10);
//        int newSVerPlush = newSVer + 1;
//        String storeVerFinal = '1.0.$newSVerPlush';
//        print('storeVer: ' + storeVerFinal);
//        newStoreVersion = storeVerFinal;
//      } else {
//        newStoreVersion = status.storeVersion;
//      }
//    }
    print(status.localVersion + "-" + status.storeVersion);

    if (status.localVersion != status.storeVersion) {
      Helper.showUpdateVersionDialog(
          context, "Cập nhật", "Conec đã có bản cập nhật mới trên cửa hàng",
          () async {
        if (pf.Platform.isIOS) {
          await launch("https://apps.apple.com/vn/app/id1539002688?l=vi");
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
    if (isCallApi) {
      giftCheck(context);
      isCallApi = false;
    }
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
        if (type == 'CONVERSATION') {
          Navigator.of(context).pushNamed(ChatListPage.ROUTE_NAME);
        }
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

        if (type == 'USER') {
          Navigator.of(context)
              .pushNamed(NotifyPage.ROUTE_NAME, arguments: 'open_notify')
              .then((value) {
            if (value == 1) {
              _homeBloc.requestGetNumberNotify();
            }
          });
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

  bool isShowPartner() {
    return _profile != null &&
        (_profile.type == "Trainer" || _profile.type == "Club");
  }
  DateTime currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Nhấp một lần nữa để thoát");
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: SafeArea(
        child: Scaffold(
          appBar: _selectedPageIndex == 0
              ? AppBar(
                  // leading: Builder(
                  //   builder: (context) {
                  //     return IconButton(
                  //       icon: Icon(Icons.group, size: 32),
                  //       onPressed: () => Scaffold.of(context).openEndDrawer(),
                  //     );
                  //   }
                  // ),
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      colors: [Colors.red, Colors.redAccent[200]],
                    )),
                  ),
                  title: Text(
                    "Conec Sport",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.black, size: 24),
                  backgroundColor: Colors.redAccent[200],
                  actions: <Widget>[
                    // IconButton(
                    //   icon: Icon(Icons.search, size: 28),
                    //   onPressed: () => Navigator.of(context).pushNamed(
                    //       ItemByCategory.ROUTE_NAME,
                    //       arguments: {'id': null, 'title': null}),
                    // ),
                    InkWell(
                      onTap: () => Navigator.of(context).pushNamed(
                          ItemByCategory.ROUTE_NAME,
                          arguments: {'id': null, 'title': null}),
                      child: Icon(Icons.search, size: 28),
                    ),
                    SizedBox(width: 8),
                    Badge(
                      padding: const EdgeInsets.all(3.0),
                      position: BadgePosition.topEnd(top: 4, end: -2),
                      badgeContent: Text(
                        _numberMessage,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      badgeColor: Colors.yellowAccent,
                      showBadge: _numberMessage.length == 0 ? false : true,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(ChatListPage.ROUTE_NAME)
                              .then((value) => getNumberOfNotify());
                        },
                        child: Icon(Icons.chat_bubble, size: 24),
                      ),
                    ),
                    SizedBox(width: 8),
                    _token != null && !_isTokenExpired
                        ? Badge(
                            padding: const EdgeInsets.all(3.0),
                            position: BadgePosition.topEnd(top: 5, end: -7),
                            badgeContent: Text(
                              _number.toString(),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            badgeColor: Colors.yellowAccent,
                            showBadge: _number > 0 ? true : false,
                            child: InkWell(
                              child: Icon(
                                Icons.notifications,
                                size: 26,
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
                      width: 8,
                    ),
                    _selectedPageIndex == 0
                        ? Builder(builder: (context) {
                            return InkWell(
                              child: Icon(Icons.group, size: 28),
                              onTap: () {
                                if (isShowPartner()) {
                                  Scaffold.of(context).openEndDrawer();
                                } else {
                                  Navigator.of(context)
                                      .pushNamed(FlMainPage.ROUTE_NAME);
                                }
                              },
                            );
                          })
                        : Container(),
                    SizedBox(width: 4)
                  ],
                )
              : null,
          endDrawer: _selectedPageIndex == 0 && isShowPartner()
              ? Drawer(
                  child: SingleChildScrollView(
                    child: Container(
                    color: Colors.white10,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                _profile != null && _profile.avatar != null
                                    ? CachedNetworkImageProvider(_profile.avatar)
                                    : AssetImage("assets/images/avatar.png"),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text(_profile.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w400))),
                        SizedBox(height: 24),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(AddMemberPage.ROUTE_NAME);
                          },
                          child: Row(
                            children: [
                              RawMaterialButton(
                                onPressed: () {},
                                elevation: 2.0,
                                fillColor: Colors.white,
                                child: Icon(
                                  Icons.person_add,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                padding: EdgeInsets.all(8),
                                shape: CircleBorder(),
                              ),
                              Text("Thêm thành viên",
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w400))
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(MemberGroupPage.ROUTE_NAME);
                          },
                          child: Row(
                            children: [
                              RawMaterialButton(
                                onPressed: () {},
                                elevation: 2.0,
                                fillColor: Colors.white,
                                child: Icon(
                                  Icons.group,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                padding: EdgeInsets.all(8),
                                shape: CircleBorder(),
                              ),
                              Text("Thành viên",
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w400))
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(RequestPage.ROUTE_NAME);
                          },
                          child: Row(
                            children: [
                              RawMaterialButton(
                                onPressed: () {},
                                elevation: 2.0,
                                fillColor: Colors.white,
                                child: Icon(
                                  Icons.group_add,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                padding: EdgeInsets.all(8),
                                shape: CircleBorder(),
                              ),
                              Text("Yêu cầu kết nạp",
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w400))
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(NotifyPartnerPage.ROUTE_NAME);
                          },
                          child: Row(
                            children: [
                              RawMaterialButton(
                                onPressed: () {},
                                elevation: 2.0,
                                fillColor: Colors.white,
                                child: Icon(
                                  Icons.notifications,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                padding: EdgeInsets.all(8),
                                shape: CircleBorder(),
                              ),
                              Text("Thông báo",
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w400))
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(ChatListPage.ROUTE_NAME)
                                .then((value) => getNumberOfNotify());
                          },
                          child: Row(
                            children: [
                              Badge(
                                padding: const EdgeInsets.all(8),
                                position:
                                    BadgePosition.topEnd(top: -12, end: -12),
                                badgeContent: Text(
                                  _numberMessage ?? "",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                badgeColor: Colors.yellow,
                                showBadge: _numberMessage != null &&
                                        _numberMessage.length == 0
                                    ? false
                                    : true,
                                child: RawMaterialButton(
                                  onPressed: () {},
                                  elevation: 2.0,
                                  fillColor: Colors.white,
                                  child: Icon(
                                    Icons.chat_bubble,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  padding: EdgeInsets.all(8),
                                  shape: CircleBorder(),
                                ),
                              ),
                              Text("Trò chuyện",
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w400))
                            ],
                          ),
                        ),
                      ],
                    ),
                ),
                  ))
              : null,
          body: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  HomePage(callback: _initTab1Page),
                  SellWidget(),
                  NewsWidget(),
                  ProfilePage()
                ],
              ),
              _isSpeedOpen
                  ? Container(
                      color: Color(0xff0c0c0c).withOpacity(0.4),
                      height: double.infinity,
                      width: double.infinity,
                    )
                  : Container(),
              // Positioned(
              //   bottom: 55,
              //   right: 16,
              //   child: Badge(
              //     padding: const EdgeInsets.all(8),
              //     position: BadgePosition.topEnd(top: -10, end: -7),
              //     badgeContent: Text(
              //       _numberMessage,
              //       style: TextStyle(
              //           fontSize: 14,
              //           color: Colors.white,
              //           fontWeight: FontWeight.bold),
              //     ),
              //     badgeColor: Colors.red,
              //     showBadge:
              //         _isSpeedOpen || _numberMessage.length == 0 ? false : true,
              //     child: mySpeedDial.SpeedDial(
              //       number: _numberMessage,
              //       onOpenZalo: () =>
              //           launch("http://zaloapp.com/qr/p/19h7p5ajy28dc"),
              //       onOpenMess: () =>
              //           launch("https://messenger.com/t/www.conec.vn"),
              //       onOpenChat: () {
              //         Navigator.of(context)
              //             .pushNamed(ChatListPage.ROUTE_NAME)
              //             .then((value) => getNumberOfNotify());
              //       },
              //       onFabAction: onFabAction,
              //     ),
              //   ),
              // ),
            ],
          ),
          floatingActionButton: Container(
              child: FloatingActionButton(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            heroTag: 'add',
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
          )),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          extendBody: true,
          bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            child: Container(
              margin: EdgeInsets.only(
                  left: Helper.isTablet(context) ? 24 : 12,
                  right: Helper.isTablet(context) ? 32 : 16),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                    onTap: () => _selectPage(0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home,
                          size: 30,
                          color: _selectedPageIndex == 0
                              ? Colors.red
                              : Colors.grey,
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
                          color: _selectedPageIndex == 1
                              ? Colors.red
                              : Colors.grey,
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
                          color: _selectedPageIndex == 2
                              ? Colors.red
                              : Colors.grey,
                        ),
                        Text("Bản tin",
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
                          color: _selectedPageIndex == 3
                              ? Colors.red
                              : Colors.grey,
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
      ),
    );
  }

  bool _isSpeedOpen = false;

  void onFabAction(bool value) {
    setState(() {
      _isSpeedOpen = value;
    });
  }
}

/*
- filter at home
- filter at ads
- add, update ads, news
- google map
*/
