import 'package:flutter/material.dart';

class ForGotPasswordPage extends StatelessWidget {
  static const ROUTE_NAME = '/forgot-pass';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quên mật khẩu")),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              maxLines: 1,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                  hintText: 'Nhập email của bạn',
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 1)),
                  contentPadding: EdgeInsets.only(left: 8),
                  suffixIcon: Icon(
                    Icons.email,
                    color: Colors.black,
                  ),
                  border: const OutlineInputBorder()),
            ),
            SizedBox(height: 32),
            InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                height: 45,
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Lấy lại mật khẩu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
