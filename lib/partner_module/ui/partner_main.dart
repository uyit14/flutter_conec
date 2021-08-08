import 'package:badges/badges.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/partner_module/ui/member/member_page.dart';
import 'package:conecapp/partner_module/ui/notify/notify_partner_page.dart';
import 'package:conecapp/ui/chat/chat_list_page.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:signalr_client/http_connection_options.dart';
import 'package:signalr_client/hub_connection.dart';
import 'package:signalr_client/hub_connection_builder.dart';

enum MANAGEMENT_TYPE { NOTIFY, MEMBER, CHAT }

class PartnerMain extends StatefulWidget {
  static const ROUTE_NAME = '/partner-main';

  @override
  _PartnerMainState createState() => _PartnerMainState();
}

class _PartnerMainState extends State<PartnerMain> {
  String _numberMessage;
  HomeBloc _homeBloc = HomeBloc();
  final serverUrl = Helper.baseURL + "/appNotifyHub";
  HubConnection hubConnection;
  HttpConnectionOptions connectionOptions;
  String send = "SendMessage";
  String rev = "ReceiveMessage";

  @override
  void initState() {
    super.initState();
    initSignalR();
    startConnection();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    getNumberOfNotify();
  }

  void getNumberOfNotify() async {
    _homeBloc.requestGetNumberNotify();
    String numberMessage = await _homeBloc.requestGetConversationCounter();
    setState(() {
      _numberMessage = numberMessage;
    });
  }

  void initSignalR() async {
    connectionOptions = HttpConnectionOptions(
        accessTokenFactory: () async => await Helper.token());
    hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl, options: connectionOptions)
        .build();
    hubConnection.on(rev, _handleNewMessage);
  }

  void startConnection() async {
    await hubConnection.start();
    if (hubConnection.state == HubConnectionState.Connected) {
      print("Connected");
    }
    if (hubConnection.state == HubConnectionState.Disconnected) {
      print("Disconnected");
    }
  }

  void _handleNewMessage(dynamic mess) {
    getNumberOfNotify();
    setState(() {

    });
  }

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
                  MANAGEMENT_TYPE.MEMBER, Colors.green, ""),
              gridItem("Thông báo", Icons.notifications, MANAGEMENT_TYPE.NOTIFY,
                  Colors.yellow, ""),
              // gridItem("Trò chuyện", Icons.chat_bubble, MANAGEMENT_TYPE.CHAT,
              //     Colors.blue, _numberMessage),
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(ChatListPage.ROUTE_NAME)
                      .then((value) => getNumberOfNotify());
                },
                child: Card(
                  elevation: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Badge(
                        padding: const EdgeInsets.all(8),
                        position: BadgePosition.topEnd(top: -12, end: -12),
                        badgeContent: Text(
                          _numberMessage ?? "",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        badgeColor: Colors.red,
                        showBadge:
                            _numberMessage != null && _numberMessage.length == 0
                                ? false
                                : true,
                        child: Icon(Icons.chat_bubble,
                            color: Colors.blue, size: 36),
                      ),
                      SizedBox(height: 8),
                      Text("Trò chuyện",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget gridItem(String title, IconData iconData, MANAGEMENT_TYPE type,
    MaterialColor color, String _numberMessage) {
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
            Badge(
              padding: const EdgeInsets.all(8),
              position: BadgePosition.topEnd(top: -12, end: -12),
              badgeContent: Text(
                _numberMessage ?? "",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              badgeColor: Colors.red,
              showBadge: _numberMessage != null && _numberMessage.length == 0
                  ? false
                  : true,
              child: Icon(iconData, color: color, size: 36),
            ),
            SizedBox(height: 8),
            Text(title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400))
          ],
        ),
      ),
    );
  });
}
