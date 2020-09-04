import 'package:conecapp/ui/conec_home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingScreen extends StatefulWidget {
  static const ROUTE_NAME = '/onboarding-screen';

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  void gotoNextPage() {
    if (_currentPage == 0) {
      _pageController.animateToPage(
        1,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    }
    if (_currentPage == 1) {
      gotoHome();
    }
    setState(() {
      _currentPage = 1;
    });
  }

  void gotoHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('onboarding', false);
    Navigator.pushReplacementNamed(
      context,
      ConecHomePage.ROUTE_NAME,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      children: [
                        Image.asset("assets/images/register.jpg",
                            fit: BoxFit.fill),
                        Image.asset("assets/images/post.jpg", fit: BoxFit.fill),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 150, horizontal: 32),
                      color: Colors.black12.withOpacity(0.5),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 50,
                child: RaisedButton(
                  color: Colors.red,
                  onPressed: gotoNextPage,
                  child: Text(
                    _currentPage == 1 ? "Vào trang chủ" : "Tiếp theo",
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
