import 'dart:developer' as dev;
import 'dart:isolate';

import 'package:conecapp/models/request/latlong.dart';
import 'package:conecapp/ui/authen/pages/login_page.dart';
import 'package:conecapp/ui/home/pages/item_detail_page.dart';
import 'package:conecapp/ui/news/pages/news_detail_page.dart';
import 'package:conecapp/ui/news/pages/sell_detail_page.dart';
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

  static String tempAvatar =
      "https://scontent.fsgn2-5.fna.fbcdn.net/v/t1.6435-1/p240x240/106685600_1590606004441341_3881513665591966142_n.jpg?_nc_cat=104&ccb=1-3&_nc_sid=7206a8&_nc_ohc=ttuLyfPOPkQAX-YnjtR&_nc_oc=AQloWrJhjFxgLCg0gkz3k01e1y8BVfpBUufqfgdLEbDdZe3lZNYzb2MiOkaGNBzKo5M&_nc_ht=scontent.fsgn2-5.fna&oh=2b030d45a0e74d2a16164a58484e1088&oe=612BE9B3";

  static String hardCodeConversationId = "9c967bad-d499-4aa4-acfa-d79893df4118";

  static String formatData(String approvedDate) {
    return approvedDate != null
        ? DateFormat("dd-MM-yyyy").format(DateTime.parse(approvedDate))
        : "";
  }

  static String formatMoney(int data) {
    var formatter = NumberFormat('#,###');
    if (data == 0 || data == null) return "";
    return '${formatter.format(data)} VND';
  }

  static String formatDob(String dob) {
    return dob != null
        ? DateFormat("dd-MM-yyyy").format(DateTime.parse(dob))
        : "";
  }

  static String formatNotifyDate(String date) {
    return date != null
        ? DateFormat("dd-MM-yyyy kk:mm").format(DateTime.parse(date).toLocal())
        : "";
  }

  static log(var tag, var message) {
    dev.log('\n\n*****************\n$tag\n$message\n*****************\n\n');
  }

  static String applicationUrl() {
    return "https://play.google.com/store/apps/details?id=com.conec.flutter_conec&hl=vi_VN";
  }

  static String formatCurrency(int number) {
    return NumberFormat("#,##0", "en_US").format(number);
  }

  static bool isTablet(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > 600 ? true : false;
  }

  static String topicNews = "333f691d-6595-443d-bae3-9a2681025b53";
  static String topicAds = "333f691d-6585-443a-bae3-9a2681025b53";
  static String errorMessage =
      "Có lỗi xảy ra, vui lòng kiểm tra lại kết nối internet của bạn!";

  static bool isNews(String topicId) {
    return topicId == topicNews;
  }

  static void navigatorToPost(
      String postId, String topicId, String title, BuildContext context) {
    if (topicId == "333f691d-6595-443d-bae3-9a2681025b53") {
      Navigator.of(context)
          .pushNamed(NewsDetailPage.ROUTE_NAME, arguments: {'postId': postId});
    } else if (topicId == "333f691d-6585-443a-bae3-9a2681025b53") {
      Navigator.of(context)
          .pushNamed(SellDetailPage.ROUTE_NAME, arguments: {'postId': postId});
    } else {
      Navigator.of(context).pushNamed(ItemDetailPage.ROUTE_NAME,
          arguments: {'postId': postId, 'title': title});
    }
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

  static void showAlertDialog(
      BuildContext context, title, content, Function onOK) {
    Widget cancelButton = TextButton(
      child: Text("Đóng"),
      onPressed: () => Navigator.of(context).pop(),
    );
    Widget continueButton = TextButton(
      child: Text("Gửi thông báo"),
      onPressed: onOK,
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void showRemindDialog(BuildContext context, content, Function onOK) {
    TextEditingController _controller = TextEditingController(text: content);

    Widget cancelButton = TextButton(
      child: Text("Đóng"),
      onPressed: () => Navigator.of(context).pop(),
    );
    Widget continueButton = TextButton(
      child: Text("Gửi thông báo"),
      onPressed: () => onOK(_controller.text),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Nhắc nhở đóng tiền"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Một thông báo sẽ được gửi đến thành viên này"),
          SizedBox(height: 12),
          Text(
            "Vui lòng nhập thông báo",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: _controller,
              maxLines: 4,
            ),
          )
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void showInputDialog(
      BuildContext context, title, club, Function onOK) {
    TextEditingController _controller = TextEditingController();

    Widget cancelButton = TextButton(
      child: Text("Đóng"),
      onPressed: () => Navigator.of(context).pop(),
    );
    Widget continueButton = TextButton(
      child: Text("Xác nhận"),
      onPressed: () => onOK(_controller.text),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bạn muốn gửi yêu cầu kết nạp thành viên với $club ?"),
          SizedBox(height: 12),
          Text(
            "Gửi lời nhắn",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: _controller,
              maxLines: 4,
            ),
          )
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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

  static void showFailDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text("Lỗi nhập thiếu"),
              content: Text("Bạn vui lòng điền đầy đủ thông tin bắt buộc"),
              actions: <Widget>[
                CupertinoDialogAction(
                    child: Text("OK"),
                    onPressed: () => Navigator.of(context).pop())
              ],
            ));
  }

  static void showOKDialog(
      BuildContext context, Function onOK, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text("Thành công"),
              content: Text(content),
              actions: <Widget>[
                CupertinoDialogAction(child: Text("OK"), onPressed: onOK)
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

  static void showUpdateVersionDialog(
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
                  child: Text("Cập nhật ngay"),
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

  static void showHiddenDialog(
      BuildContext context, String content, Function onOKPress) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              content: Text(content),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("OK"),
                  onPressed: onOKPress,
                )
              ],
            ));
  }

  static void showInfoDialog(BuildContext context, String phone, String address,
      Function onPhoneCall) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("Thông tin liên hệ"),
              content: Material(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 8),
                    InkWell(
                      onTap: onPhoneCall,
                      child: Row(
                        children: [
                          Icon(Icons.phone_android),
                          SizedBox(width: 4),
                          Text("Liên hệ: ", style: TextStyle(fontSize: 14)),
                          SizedBox(width: 8),
                          Text(
                            phone,
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(width: 4),
                        Text("Địa chỉ: ", style: TextStyle(fontSize: 14)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                Align(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Đóng",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
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

  static void setAppVersion(String appVersion) async {
    appLog(
        className: "Helper",
        functionName: "setAppVersion",
        message: "set $appVersion to stored");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('app_ver', appVersion);
  }

  static Future<String> getAppVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var appVersion;
    try {
      appVersion = prefs.getString('app_ver');
    } catch (Unhandled) {
      appVersion = null;
    }

    return appVersion;
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
        print('token valid');
        return true;
      } else {
        return false;
      }
    }
    print('token expired');
    return false;
  }

  static const List<String> hardCodeMSell = [
    "Sản phẩm này còn không ạ?",
    "Bạn có ship hàng không?",
    "Sản phẩm này đã qua sử dụng chưa ạ?",
    "Bạn có các sản phẩm khác tương tự?",
  ];

  static const List<String> hardCodeMPost = [
    "Hiện tại còn tuyển sinh không ạ?",
    "Làm thế nào để tham gia?",
    "Học phí để tham gia là bao nhiêu?",
    "Đối tượng phù hợp để tham gia là ai?",
  ];

  static const List<String> reportList = [
    "Thông tin không đúng thực tế",
    "Đã đóng cửa",
    "Lừa đảo",
    "Trùng tin đăng"
  ];

  static const List<String> statusList = ["Hiện", "Ẩn"];

  static List<String> options = [
    'Đỏ',
    'Xanh lá',
    'Xanh đậm',
    'Xanh nhạt',
    'Vàng',
    'Xám'
  ];

  static List<String> params = [
    'alert alert-danger',
    'alert alert-success',
    'alert alert-primary',
    'alert alert-info',
    'alert alert-warning',
    'alert alert-secondary'
  ];

  static List<String> paramsGroup = [
    'danger',
    'success',
    'primary',
    'info',
    'warning',
    'secondary'
  ];

  static ColorNotify getColorGroup(String color) {
    if (color == null || color.length == 0) {
      color = paramsGroup[1];
    }
    int index = paramsGroup.indexOf(color);
    return ColorNotify(text: options[index], color: getColorByTag(index));
  }

  static ColorNotify getColorNotify(String color) {
    if (color == null || color.length == 0) {
      color = params[1];
    }
    int index = params.indexOf(color);
    return ColorNotify(text: options[index], color: getColorByTag(index));
  }

  static Color getColorByTag(int mTag) {
    switch (mTag) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.blue[300];
      case 4:
        return Colors.yellow[700];
      case 5:
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  static String storeNote =
      "Bạn nên đăng ảnh đa dạng sản phẩm để có nhiều khách hàng hơn";
  static String trainerNote =
      "Bạn đăng ảnh CMND/CCCD, Bằng cấp, Thành tích và ít nhất 03 ảnh huấn luyện cùng học viên của bạn";
  static String clubNote =
      "Bạn đăng ảnh giấy phép kinh doanh, giấy phép hoạt động hoặc các giấy phép có liên quan và hình ảnh thực câu lạc bộ của bạn";

  static bool statusRequest(String value) {
    if (value == statusList[0]) return true;
    return false;
  }

  static String statusResponse(bool status) {
    if (status) return statusList[0];
    return statusList[1];
  }

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
  //                           activeColor:Static.Configs.print_grand_total
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

  void createPort() async {
    var receivePort = new ReceivePort();
    await Isolate.spawn(entryPoint, receivePort.sendPort);
    // Receive the SendPort from the Isolate
    SendPort sendPort = await receivePort.first;

    // Send a message to the Isolate
    sendPort.send("hello");
  }

  // Entry point for your Isolate
  entryPoint(SendPort sendPort) async {
    // Open the ReceivePort to listen for incoming messages (optional)
    var port = new ReceivePort();

    // Send messages to other Isolates
    sendPort.send(port.sendPort);

    // Listen for messages (optional)
    await for (var data in port) {
      // `data` is the message received.
    }
  }

  static const String loadingMessage = "Đang tải...";
  static const String verifyMessage =
      "Nhập mã xác nhận bao gôm 5 ký tự chúng tôi đã gửi đến email của bạn!";
}

class ColorNotify {
  final String text;
  final Color color;

  ColorNotify({this.text, this.color});
}
