import 'package:flutter/material.dart';

class CustomScrollBehavior extends ScrollBehavior{

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return ClampingScrollPhysics();
  }
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}