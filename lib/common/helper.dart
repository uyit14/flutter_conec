import 'dart:developer' as dev;

import 'package:conecapp/models/request/latlong.dart';
import 'package:conecapp/ui/authen/pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const GOOGLE_API_KEY = 'AIzaSyCB6MXwv-kgX2ecqg020GAIAV_VsHoKX8Y';

class Helper {
  //location halper
  static String generateLocationPreviewImage({num lat, num lng}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$lat,$lng&zoom=18&size=600x300&maptype=roadmap &markers=color:red%7Clabel:C%7C$lat,$lng&key=$GOOGLE_API_KEY';
  }

  static const baseURL = "https://conec.vn";

  //static String baseURL = "https://test.conec.vn";

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

  static String formatNotifyDate(String date) {
    return date != null
        ? DateFormat("dd-MM-yyyy hh:mm").format(DateTime.parse(date))
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

  static bool isTablet(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > 600 ? true : false;
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

  static Future<Map<String, String>> header() async {
    var prefs = await SharedPreferences.getInstance();
    Map<String, String> header = {
      "Authorization": "Bearer ${prefs.getString("token")} ",
      "Content-Type": "application/json"
    };

    return header;
  }

  static Future<String> token() async {
    var prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    return token;
  }

  static final headerNoToken = {
    'Accept': "application/json",
    'content-type': "application/json"
  };

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static String handleDistance({num distanceResponse}) {
    if (distanceResponse != null && distanceResponse >= 0) {
      if (distanceResponse < 1) {
        return "${(distanceResponse * 1000).toInt()} m";
      } else {
        return "${distanceResponse.toInt()} km";
      }
    }
    return "Không xác định";
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

  static void showDeleteDialog(
      BuildContext context, String title, String content, VoidCallback onOK) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
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

  static void showGiftCheckDialog(
      BuildContext context, String title, String content, VoidCallback onOK) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("Để sau", style: TextStyle(color: Colors.red)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text("Nhận ngay"),
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

  static void showMissingDataDialog(BuildContext context, Function onOKPress) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text("Thiếu thông tin"),
              content: Text(
                  "Vui lòng cập nhật đầy đủ thông tin cá nhân để đăng bài"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("Hủy", style: TextStyle(color: Colors.red)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text("OK"),
                  onPressed: onOKPress,
                )
              ],
            ));
  }

  static void showTokenExpiredDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text("Phiên đăng nhập đã hết hạn"),
              content: Text("Bạn vui lòng đăng nhập lại"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("OK"),
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(LoginPage.ROUTE_NAME),
                )
              ],
            ));
  }

  static void showMissingDialog(
      BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Html(data: content),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ));
  }

  static void showMissingDialog2(
      BuildContext context, String title, String content, Function onOKPress) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Html(data: content),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: onOKPress,
            )
          ],
        ));
  }

  static void showCompleteDialog(
      BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    return token;
  }

  static Future<bool> getIsSocial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isSocial') == null) {
      return false;
    }
    var isSocial = prefs.getBool('isSocial');
    return isSocial;
  }

  static void appLog(
      {@required String className,
      @required String functionName,
      @required String message}) {
    debugPrint('$className - $functionName : $message');
  }

  static Future<bool> isTokenExpired() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var expiredDay = prefs.getString('expired');
    //var expiredDay = "2020-09-28T20:38:41.2397583+07:00";
    if (expiredDay != null) {
      if (DateTime.parse(expiredDay).isBefore(DateTime.now())) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  static const List<String> reportList = [
    "Thông tin không đúng thực tế",
    "Nội dung vi phạm",
    "Lừa đảo",
    "Trùng tin đăng"
  ];

  // //report dialog
  // static void showReportDialog(BuildContext context, Function(int index) onReport){
  //   int selectedIndex = 0;
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext ctx) => CupertinoAlertDialog(
  //         title: Text("Báo cáo vi phạm"),
  //         content:
  //         Container(
  //           height: MediaQuery.of(context).size.height / 2,
  //           width: MediaQuery.of(context).size.width - 50,
  //         child: Column(
  //             children: [
  //               Expanded(
  //                 child: ListView.builder(
  //                   itemCount: reportList.length,
  //                     itemBuilder: (context, index){
  //                     return Row(
  //                       children: [
  //                         Radio(
  //                           value: reportList[index],
  //                           groupValue: selectedIndex,
  //                           activeColor:
  //                           Color.fromRGBO(220, 65, 50, 1),
  //                           onChanged: (value) {
  //                             selectedIndex = value;
  //                           },
  //                         ),
  //                         SizedBox(width: 8),
  //                         Text(reportList[index])
  //                       ],
  //                     );
  //                     }
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           CupertinoDialogAction(
  //             child: Text("Hủy", style: TextStyle(color: Colors.red)),
  //             onPressed: () => Navigator.of(context).pop(),
  //           ),
  //           CupertinoDialogAction(
  //             child: Text("Gửi báo cáo"),
  //             onPressed: () => onReport(selectedIndex),
  //           )
  //         ],
  //       ));
  // }

  static const String loadingMessage = "Đang tải...";
  static const String verifyMessage =
      "Nhập mã xác nhận bao gôm 5 ký tự chúng tôi đã gửi đến email của bạn!";
}
