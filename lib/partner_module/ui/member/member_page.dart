import 'package:flutter/material.dart';

class MemberPage extends StatefulWidget {
  static const ROUTE_NAME = '/member';

  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Thành viên")),
        body: Container(
          child: Text("Member"),
        ),
      ),
    );
  }
}
