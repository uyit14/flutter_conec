import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/ui/home/pages/home_page.dart';
import 'package:conecapp/ui/mypost/pages/post_action_page.dart';
import 'package:conecapp/ui/news/blocs/news_bloc.dart';
import 'package:conecapp/ui/notify/pages/notify_page.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:conecapp/ui/profile/pages/edit_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
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
  ProfileBloc _profileBloc = ProfileBloc();

  String _token;
  bool _isTokenExpired = true;
  void getToken() async{
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
    });
    if(!_isTokenExpired && _token!=null){
      _profileBloc.requestGetProfile();
      _profileBloc.profileStream.listen((event) {
        if(event.status == Status.COMPLETED){
          final profile = event.data;
          if(profile.name!=null && profile.type!=null && profile.phoneNumber!=null){
            setState(() {
              _profile = profile;
              _isMissingData = false;
            });
          }else{
            return;
          }
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

//  detectToken() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    var token = prefs.getString('token');
//    globals.isSigned = token != null ? true : false;
//    globals.token = token;
//  }

  @override
  void initState() {
    super.initState();
    //detectToken();
    getLocation();
    getToken();
  }

    void getLocation() async {
      Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(position.latitude ?? "---aaa---");
      print(position.longitude ?? "---aaa---");
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
                    icon: Icon(Icons.search, size: 32,),
                    onPressed: () => Navigator.of(context).pushNamed(
                        ItemByCategory.ROUTE_NAME,
                        arguments: {'id': null, 'title': null}),
                  ),
//                  IconButton(
//                    icon: Icon(Icons.notifications),
//                    onPressed: () =>
//                        Navigator.of(context).pushNamed(NotifyPage.ROUTE_NAME),
//                  ),
                ],
              )
            : null,
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Provider<HomeBloc>(
              create: (_) => HomeBloc(),
              dispose: (_, HomeBloc homeBloc) => homeBloc.dispose(),
              child: HomePage(callback: _initTab1Page),
            ),
            Provider<NewsBloc>(
                create: (_) => NewsBloc(),
                dispose: (_, NewsBloc newsBloc) => newsBloc.dispose(),
                child: NewsPage(_initIndex)),
            MyPost(),
            ProfilePage()
          ],
        ),
        floatingActionButton: Container(
          child: FloatingActionButton(
            onPressed: () {
              if(_token == null || _token.length == 0){
                Helper.showAuthenticationDialog(context);
              }else{
                if(_isTokenExpired){
                  Helper.showTokenExpiredDialog(context);
                }else{
                  if(_isMissingData){
                    Helper.showMissingDataDialog(context, (){
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(EditProfilePage.ROUTE_NAME, arguments: _profile).then((value) {
                        if(value==0){
                          setState(() {
                            _isMissingData = false;
                          });
                        }
                      });
                    });
                  }else{
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
                  tooltip: "Rao vặt",
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
