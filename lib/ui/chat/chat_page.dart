import 'package:conecapp/common/helper.dart';
import 'package:flutter/material.dart';
import 'package:signalr_client/signalr_client.dart';

import 'chat_doc.dart';
import 'message.dart';
import 'new_message.dart';

class ChatPage extends StatefulWidget {
  static const ROUTE_NAME = "/chat-page";

  const ChatPage({Key key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatDoc> chatDocs = List.generate(
      10,
      (index) => ChatDoc(
          index % 2 == 0 ? "Me" : "Friend",
          index != 3 ? "New message at $index" : "TỐI 29/7 THÊM 4.773 CA COVID-19 TỔNG SỐ CA TRONG NGÀY LÀ 7.594 CA TP.HCM CÓ 4.592 CA",
          ChatDoc.avatar,
          index % 2 == 0 ? true : false,
          index.toString()));

  final serverUrl = Helper.baseURL + "/notifyHub";
  HubConnection hubConnection;

  @override
  void initState() {
    super.initState();
    initSignalR();
  }

  void initSignalR() {
    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
    hubConnection.onclose((error) {
      print("error: " + error.toString());
    });
    hubConnection.on("ReceiveNotify", _handleNewMessage);
  }

  void _handleNewMessage(dynamic mess) {
    print("mess: " + mess.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(1);
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          actions: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              backgroundImage: Helper.tempAvatar != null
                  ? NetworkImage(Helper.tempAvatar)
                  : AssetImage("assets/images/avatar.png"),
            ),
            SizedBox(width: 6),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Tải Bảo Uy",
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text("2 giờ trước",
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w400)),
              ],
            ),
            SizedBox(width: MediaQuery.of(context).size.width - 160,)
          ],
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: Messages(chatDocs),
              ),
              NewMessage(
                onSend: (message) async {
                  // setState(() {
                  //   chatDocs.insert(
                  //       0, ChatDoc("Me", message, ChatDoc.avatar, true, "1"));
                  // });\
                  if (hubConnection.state == HubConnectionState.Connected)
                    await hubConnection
                        .invoke("SendNotify", args: ['Uy', message]);
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(hubConnection.state == HubConnectionState.Connected
              ? Icons.cast_connected
              : Icons.cast_connected_outlined),
          onPressed: () async {
            await hubConnection.start();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}
