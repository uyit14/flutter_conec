import 'package:conecapp/models/request/latlong.dart';
import 'package:conecapp/ui/authen/pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'dart:developer' as dev;

const GOOGLE_API_KEY = 'AIzaSyCB6MXwv-kgX2ecqg020GAIAV_VsHoKX8Y';

class Helper {
  //location halper
  static String generateLocationPreviewImage({double lat, double lng}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$lat,$lng&zoom=18&size=600x300&maptype=roadmap &markers=color:red%7Clabel:C%7C$lat,$lng&key=$GOOGLE_API_KEY';
  }

  static const baseURL = "http://149.28.140.240:8088";

  static String formatData(String approvedDate) {
    return approvedDate != null
        ? DateFormat("dd-MM-yyyy").format(DateTime.parse(approvedDate))
        : "";
  }

  static String formatDob(String dob) {
    return dob != null
        ? DateFormat("dd-MM-yyyy").format(DateTime.parse(dob))
        : "";
  }

  static log(var tag, var message) {
    dev.log('\n\n*****************\n$tag\n$message\n*****************\n\n');
  }

  static String applicationUrl() {
    return "https://play.google.com/store/apps/details?id=conec.vinaas.app&hl=vi_VN";
  }

  static String formatCurrency(int number) {
    return NumberFormat("#,##0", "en_US").format(number);
  }

  static String calculatorTime(String time) {
    var different;
    String suffix = "";
    different = DateTime.now().difference(DateTime.parse(time)).inSeconds;
    suffix = "giây trước";
    if (different > 59) {
      different = DateTime.now().difference(DateTime.parse(time)).inMinutes;
      suffix = "phút trước";
      if (different > 59) {
        different = DateTime.now().difference(DateTime.parse(time)).inHours;
        suffix = "giờ trước";
        if (different > 23) {
          different = DateTime.now().difference(DateTime.parse(time)).inDays;
          suffix = "ngày trước";
        }
      }
    }
    if (different < 0) return "0 giây trước";
    return different.toString() + " " + suffix;
  }

//  static final header = {
//    'authorization': "Bearer $getToken",
//    'Content-Type': "application/json"
//  };

  static Future<Map<String, String>> header() async {
    var prefs = await SharedPreferences.getInstance();
    Map<String, String> header = {
      "Authorization":
      "Bearer ${prefs.getString("token")} ",
      "Content-Type": "application/json"
    };

    return header;
  }

  static final headerNoToken = {
    'Accept': "application/json",
    'content-type': "application/json"
  };

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static Future<LatLong> getLatLng(String address) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(address);
    var first = addresses.first;
    return LatLong(
        lat: first.coordinates.latitude, long: first.coordinates.longitude);
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static void showDeleteDialog(BuildContext context, VoidCallback onOK) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text("Xóa bình luận"),
              content: Text("Bạn có chắc chắn muốn xóa bình luận này?"),
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

  static void showTokenExpiredDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text("Phiên đăng nhập đã hết hạn"),
          content:
          Text("Bạn vui lòng đăng nhập lại"),
          actions: <Widget>[
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

  static Future<bool> isTokenExpired() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var expiredDay = prefs.getString('expired');
    //var expiredDay = "2020-09-28T20:38:41.2397583+07:00";
    if(expiredDay!=null){
      if(DateTime.parse(expiredDay).isBefore(DateTime.now())){
        return true;
      }else{
        return false;
      }
    }
    return false;
  }



  static const String loadingMessage = "Đang tải...";
  static const String verifyMessage =
      "Nhập mã xác nhận bao gôm 5 ký tự chúng tôi đã gửi đến email của bạn!";
}
