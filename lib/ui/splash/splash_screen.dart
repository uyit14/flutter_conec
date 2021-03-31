import 'dart:async';

import 'package:conecapp/common/helper.dart';
import 'package:conecapp/ui/authen/pages/login_page.dart';
import 'package:conecapp/ui/conec_home_page.dart';
import 'package:conecapp/ui/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //static FirebaseAnalytics analytics = FirebaseAnalytics();

  startTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('onboarding');

    var _duration = new Duration(seconds: 1);

    if (firstTime != null && !firstTime) {
      return new Timer(_duration, navigationToHomeOrSignIn);
    } else {
      return new Timer(_duration, navigationToOnBoarding);
    }
  }

  void navigationToHomeOrSignIn() async {
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    if (!expired && token != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          ConecHomePage.ROUTE_NAME, (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          LoginPage.ROUTE_NAME, (Route<dynamic> route) => false);
    }
  }

  void navigationToOnBoarding() {
    Navigator.of(context).pushNamedAndRemoveUntil(
        OnBoardingScreen.ROUTE_NAME, (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    startTime();
    super.initState();
    //analytics.logAppOpen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/images/logo_tranparent.png",
              width: 200,
              height: 100,
              fit: BoxFit.fill,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              "Kết nối thể thao",
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w500, color: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}
