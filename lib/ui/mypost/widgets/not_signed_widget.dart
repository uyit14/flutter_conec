import 'package:conecapp/ui/authen/pages/login_page.dart';
import 'package:flutter/material.dart';

class NotSigned extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.assignment_ind,
            size: 40,
          ),
          Text(
            "Bạn chưa đăng nhập!",
            style: TextStyle(fontSize: 24),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacementNamed(LoginPage.ROUTE_NAME);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 45,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Text(
                  'Đăng nhập ngay',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
