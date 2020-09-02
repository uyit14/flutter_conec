import 'dart:async';
import 'package:conecapp/ui/authen/pages/forgot_password_page.dart';
import 'package:conecapp/ui/conec_home_page.dart';
import 'package:conecapp/ui/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('onboarding');

    var _duration = new Duration(seconds: 1);

    if (firstTime != null && !firstTime) {
      return new Timer(_duration, navigationToHome);
    } else {
      return new Timer(_duration, navigationToOnBoarding);
    }
  }

  void navigationToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
        ConecHomePage.ROUTE_NAME, (Route<dynamic> route) => false);
  //Navigator.of(context).pushNamed(ForGotPasswordPage.ROUTE_NAME);
  }

  void navigationToOnBoarding() {
    Navigator.of(context).pushNamedAndRemoveUntil(
        OnBoardingScreen.ROUTE_NAME, (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    startTime();
    super.initState();
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
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: Colors.red),
              child: Text(
                "Conec Sport",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.yellowAccent),
              ),
            ),
            SizedBox(height: 8,),
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
