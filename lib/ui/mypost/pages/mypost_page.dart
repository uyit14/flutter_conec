import 'package:conecapp/common/helper.dart';

import '../widgets/not_signed_widget.dart';
import '../widgets/signed_widget.dart';
import 'package:flutter/material.dart';

class MyPost extends StatefulWidget {
  @override
  _MyPostState createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  String _token;

  @override
  void initState() {
    super.initState();
    getToken();
  }
  void getToken() async{
    String token = await Helper.getToken();
    setState(() {
      _token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _token != null
        ? Signed()
        : NotSigned();
  }
}



