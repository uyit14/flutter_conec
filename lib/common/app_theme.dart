import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final TextStyle commonDetail =
      TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold);
  static final TextStyle title =
      TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold);
  static final TextStyle profileTitle =
      TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w300);
  static final TextStyle profileInfo =
      TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w400);
//  static TextStyle changeTextStyle =
//      TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.blue);

  static TextStyle changeTextStyle(bool enable) {
    return TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: enable ? Colors.blue : Colors.grey);
  }

  static final appBarSize = AppBar().preferredSize.height;
}
