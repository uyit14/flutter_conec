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
import 'home/blocs/home_bloc.dart';
import 'home/pages/items_by_category_page.dart';
import 'mypost/pages/mypost_page.dart';
import 'news/pages/news_page.dart';
import 'profile/pages/profile_pages.dart';
import '../common/globals.dart' as globals;

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
    getToken();
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
                      child: Icon(Icons.notifications, size: 32, color: Colors.black87.withOpacity(0.8),),
                      onTap: () => Navigator.of(context)
                          .pushNamed(NotifyPage.ROUTE_NAME).then((value) {
                            if(value==1){
                              _homeBloc.requestGetNumberNotify();
                            }
                      }),
                    ),
                  )
                      : Container(),
                  SizedBox(width: 16,)
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
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        extendBody: true,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                IconButton(
                  color: _selectedPageIndex == 0 ? Colors.red : Colors.grey,
                  onPressed: () => _selectPage(0),
                  iconSize: 30,
                  icon: Icon(Icons.home),
                  tooltip: "Trang chủ",
                ),
                IconButton(
                  color: _selectedPageIndex == 1 ? Colors.red : Colors.grey,
                  onPressed: () => _selectPage(1),
                  iconSize: 30,
                  icon: Icon(Icons.explore),
                  tooltip: "Dụng cụ",
                ),
                IconButton(
                  color: _selectedPageIndex == 2 ? Colors.red : Colors.grey,
                  onPressed: () => _selectPage(2),
                  iconSize: 30,
                  icon: Icon(Icons.list),
                  tooltip: "Tin đăng",
                ),
                IconButton(
                  color: _selectedPageIndex == 3 ? Colors.red : Colors.grey,
                  onPressed: () => _selectPage(3),
                  iconSize: 30,
                  icon: Icon(Icons.more_horiz),
                  tooltip: "Thêm",
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
