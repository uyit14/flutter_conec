import 'package:conecapp/ui/authen/widgets/club_widget.dart';
import 'package:conecapp/ui/authen/widgets/person_widget.dart';
import 'package:flutter/material.dart';

import '../widgets/indicator_painter.dart';

class SignUpPage extends StatefulWidget {
  static const ROUTE_NAME = '/signup';

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  PageController _pageController = PageController(initialPage: 0);
  Color left = Colors.red;
  Color right = Colors.white;

  void _onPersonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onClubPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(16),
                      width: double.infinity,
                      height: screenHeight > screenWidth
                          ? screenHeight * 0.2
                          : screenWidth * 0.2,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.red, Colors.redAccent[200]],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter),
                          borderRadius: BorderRadius.only(
                              bottomLeft:
                                  Radius.circular(screenHeight * 0.3 / 2))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              child: FlutterLogo(
                            size: screenHeight > screenWidth
                                ? screenHeight * 0.1
                                : screenWidth * 0.1,
                          )),
                          Container(
                            width: double.infinity,
                            child: Text(
                              'Kết nối thể thao',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: screenHeight > screenWidth
                                      ? screenHeight * 0.035
                                      : screenWidth * 0.035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      )),
                  Positioned(
                    child: IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                    ),
                    top: 8,
                    left: 8,
                  ),
                ],
              ),
              Container(
                width: 300,
                height: 50,
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Color(0x552B2B2B),
                  border: Border.all(width: 1, color: Colors.red),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                child: CustomPaint(
                  painter:
                      TabIndicationPainter(pageController: _pageController),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: _onPersonPress,
                          child: Text(
                            "Cá nhân",
                            style: TextStyle(
                                color: left,
                                fontSize: 16.0,
                                fontFamily: "WorkSansSemiBold"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FlatButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: _onClubPress,
                          child: Text(
                            "Câu lạc bộ",
                            style: TextStyle(
                                color: right,
                                fontSize: 16.0,
                                fontFamily: "WorkSansSemiBold"),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) {
                    if (i == 0) {
                      setState(() {
                        right = Colors.white;
                        left = Colors.red;
                      });
                    } else if (i == 1) {
                      setState(() {
                        right = Colors.red;
                        left = Colors.white;
                      });
                    }
                  },
                  children: <Widget>[Person(), Club()],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController?.dispose();
  }
}
