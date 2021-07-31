import 'package:conecapp/partner_module/ui/member/member_page.dart';
import 'package:conecapp/partner_module/ui/notify/notify_partner_page.dart';
import 'package:conecapp/ui/chat/chat_list_page.dart';
import 'package:flutter/material.dart';

enum MANAGEMENT_TYPE { NOTIFY, MEMBER, CHAT }

class PartnerMain extends StatefulWidget {
  static const ROUTE_NAME = '/partner-main';

  @override
  _PartnerMainState createState() => _PartnerMainState();
}

class _PartnerMainState extends State<PartnerMain> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Đối tác")),
        body: Container(
          padding: EdgeInsets.all(12),
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              gridItem("Thành viên", Icons.person_add_alt_1_rounded,
                  MANAGEMENT_TYPE.MEMBER, Colors.green),
              gridItem("Thông báo", Icons.notifications, MANAGEMENT_TYPE.NOTIFY,
                  Colors.yellow),
              gridItem("Trò chuyện", Icons.chat_bubble, MANAGEMENT_TYPE.CHAT,
                  Colors.blue)
            ],
          ),
        ),
      ),
    );
  }
}

Widget gridItem(String title, IconData iconData, MANAGEMENT_TYPE type,
    MaterialColor color) {
  return Builder(builder: (BuildContext context) {
    return InkWell(
      onTap: () {
        switch (type) {
          case MANAGEMENT_TYPE.NOTIFY:
            Navigator.of(context).pushNamed(NotifyPartnerPage.ROUTE_NAME);
            break;
          case MANAGEMENT_TYPE.MEMBER:
            Navigator.of(context).pushNamed(MemberPage.ROUTE_NAME);
            break;
          case MANAGEMENT_TYPE.CHAT:
            Navigator.of(context).pushNamed(ChatListPage.ROUTE_NAME);
            break;
        }
      },
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: color, size: 36),
            SizedBox(height: 8),
            Text(title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400))
          ],
        ),
      ),
    );
  });
}
