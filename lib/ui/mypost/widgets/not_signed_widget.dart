import 'package:conecapp/ui/authen/pages/login_page.dart';
import 'package:flutter/material.dart';

class NotSigned extends StatelessWidget {
  final bool isExpired;
  NotSigned(this.isExpired);

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
            isExpired ? "Phiên đăng nhập hết hạn" : "Bạn chưa đăng nhập!",
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
                  isExpired ? "Đăng nhập lại": 'Đăng nhập ngay',
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
