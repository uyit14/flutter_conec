import 'package:conecapp/ui/authen/pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'dart:developer' as dev;

class Helper {
  static String formatData(String publishedDate) {
    return publishedDate != null ?DateFormat("dd-MM-yyyy hh:mm:ss")
        .format(DateTime.parse(publishedDate)) : "";
  }

  static log(var tag, var message) {
    dev.log ('\n\n*****************\n$tag\n$message\n*****************\n\n');
  }

  static String applicationUrl(){
    return "https://play.google.com/store/apps/details?id=conec.vinaas.app&hl=vi_VN";
  }

  static String formatCurrency(int number) {
    return NumberFormat("#,##0", "en_US").format(number);
  }

  static String calculatorTime(String time){
    var different;
    String suffix = "";
    different = DateTime.now().difference(DateTime.parse(time)).inSeconds;
    suffix = "giây trước";
    if(different > 59){
      different = DateTime.now().difference(DateTime.parse(time)).inMinutes;
      suffix = "phút trước";
      if(different > 59){
        different = DateTime.now().difference(DateTime.parse(time)).inHours;
        suffix = "giờ trước";
        if(different > 23){
          different = DateTime.now().difference(DateTime.parse(time)).inDays;
          suffix = "ngày trước";
        }
      }
    }
    if(different < 0)
      return "0 giây trước";
    return different.toString() + " " + suffix;
  }

  static final header = {
    'authorization': "Bearer ${globals.token}",
    'Content-Type': "application/json"
  };

  static void showDeleteDialog(BuildContext context, VoidCallback onOK) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text("Xóa bình luận"),
              content:
                  Text("Bạn có chắc chắn muốn xóa bình luận này?"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("Hủy", style: TextStyle(color: Colors.red)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text("OK"),
                  onPressed: onOK,
                )
              ],
            ));
  }

  static void showAuthenticationDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text("Bạn chưa đăng nhập"),
              content:
                  Text("Vui lòng đăng nhập để trải nghiệm nhiều hơn với Conec"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("Hủy", style: TextStyle(color: Colors.red)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text("OK"),
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(LoginPage.ROUTE_NAME),
                )
              ],
            ));
  }

  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    return token;
  }

  static const String loadingMessage = "Đang tải...";
}
