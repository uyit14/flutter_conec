import 'package:flutter/material.dart';

class GuidePage extends StatefulWidget {
  static const ROUTE_NAME = '/guide-page';

  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  String titleText = "Đăng ký";
  String contentText = "Nhập đầy đủ thông tin để đăng ký tài khoản";
  double marginBottom = 0;

  void gotoNextPage() {
    if (_currentPage == 0) {
      _pageController.animateToPage(
        1,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
      setState(() {
        marginBottom = 200;
        titleText = "Đăng tin";
        contentText = "Tại trang chủ nhấn vào nút (+) để đăng tin";
      });
    }
    if (_currentPage == 1) {
      _pageController.animateToPage(
        2,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
      setState(() {
        titleText = "Đăng tin";
        contentText = "Tại màn hình đăng tin nhập đầy đủ nội dung và nhấn nút đăng tin";
      });
    }
    if (_currentPage == 2) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _currentPage++;
    });
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
                        Image.asset("assets/images/signup.jpg",
                            fit: BoxFit.cover),
                        Image.asset("assets/images/home.jpg",
                            fit: BoxFit.cover),
                        Image.asset("assets/images/post.jpg",
                            fit: BoxFit.cover),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding:
                      EdgeInsets.symmetric(vertical: 150, horizontal: 32),
                      color: Colors.black12.withOpacity(0.5),
                    ),
                    _currentPage == 0 || _currentPage == 2 ? Positioned(
                        bottom: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                titleText,
                                style:
                                TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8,),
                              Text(
                                contentText,
                                style:
                                TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(height: 8,),
                              Container(
                                width: double.infinity,
                                height: 45,
                                child: RaisedButton(
                                  color: Colors.blue,
                                  onPressed: gotoNextPage,
                                  child: Text(
                                    _currentPage == 2 ? "Quay lại trang cá nhân" : "Tiếp theo",
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )) : Container(),
                    _currentPage == 1 ? Positioned(
                        top: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                titleText,
                                style:
                                TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8,),
                              Text(
                                contentText,
                                style:
                                TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(height: 8,),
                              Container(
                                width: double.infinity,
                                height: 45,
                                child: RaisedButton(
                                  color: Colors.blue,
                                  onPressed: gotoNextPage,
                                  child: Text(
                                    _currentPage == 2 ? "Quay lại trang cá nhân" : "Tiếp theo",
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )) : Container()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
