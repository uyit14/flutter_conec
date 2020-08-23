import 'package:conecapp/ui/conec_home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingScreen extends StatelessWidget {
  static const ROUTE_NAME = '/onboarding-screen';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Màn hình hướng dẫn sử dụng", style: TextStyle(fontSize: 24)),
              SizedBox(height: 16),
              Container(
                width: 250,
                height: 50,
                child: RaisedButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool('onboarding', false);
                    Navigator.pushReplacementNamed(
                      context,
                      ConecHomePage.ROUTE_NAME,
                    );
                  },
                  child: Text("Vào trang chủ"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
