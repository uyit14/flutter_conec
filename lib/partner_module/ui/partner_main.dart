import 'package:conecapp/partner_module/ui/notify/notify_partner_page.dart';
import 'package:flutter/material.dart';

enum MANAGEMENT_TYPE { NOTIFY, MEMBER, ORDER }

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
              gridItem("Khác", Icons.build, MANAGEMENT_TYPE.ORDER, Colors.red)
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
            break;
          case MANAGEMENT_TYPE.ORDER:
            break;
        }
      },
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: color, size: 32),
            SizedBox(height: 8),
            Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400))
          ],
        ),
      ),
    );
  });
}
