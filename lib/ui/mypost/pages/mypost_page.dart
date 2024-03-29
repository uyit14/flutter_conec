import 'package:conecapp/common/helper.dart';

import '../widgets/not_signed_widget.dart';
import '../widgets/signed_widget.dart';
import 'package:flutter/material.dart';

class MyPost extends StatefulWidget {
  static const ROUTE_NAME = '/mypost-page';
  @override
  _MyPostState createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  String _token;
  bool _isTokenExpired = true;

  @override
  void initState() {
    super.initState();
    getToken();
  }
  void getToken() async{
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Tin đăng")),
        body: Container(
          height: double.infinity,
          child:  _token == null || _isTokenExpired
              ? NotSigned(_isTokenExpired)
              : Signed(),
        ),
      ),
    );
  }
}



