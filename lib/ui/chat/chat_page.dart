import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/chat/conversations_response.dart';
import 'package:conecapp/ui/chat/chat_bloc.dart';
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
  ChatBloc _chatBloc = ChatBloc();
  bool isCallApi;
  Conversation _conversation = Conversation();

  List<ChatDoc> chatDocs = List.generate(
      10,
      (index) => ChatDoc(
          index % 2 == 0 ? "Me" : "Friend",
          index != 3
              ? "New message at $index"
              : "TỐI 29/7 THÊM 4.773 CA COVID-19 TỔNG SỐ CA TRONG NGÀY LÀ 7.594 CA TP.HCM CÓ 4.592 CA",
          ChatDoc.avatar,
          index % 2 == 0 ? true : false,
          index.toString()));

  final serverUrl = Helper.baseURL + "/notifyHub";
  HubConnection hubConnection;

  @override
  void initState() {
    super.initState();
    isCallApi = true;
    initSignalR();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isCallApi) {
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, Object>;
      String memberId = routeArgs['memberId'];
      String postId;
      if (routeArgs['postId'] != null) {
        postId = routeArgs['postId'];
      }

      _chatBloc.requestCreateConversation(memberId, postId: postId);
      _chatBloc.createConversationStream.listen((event) {
        switch (event.status) {
          case Status.LOADING:
            break;
          case Status.COMPLETED:
            setState(() {
              _conversation = event.data.conversation;
            });
            if (!event.data.isNew) {
              //nothing
            } else {
              //call api get message list
            }
            break;
          case Status.ERROR:
            break;
        }
      });
      isCallApi = false;
    }
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
        body: Container(
          child: Column(
            children: [
              Container(
                color: Colors.red,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(1);
                      },
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      backgroundImage: _conversation.member != null &&
                              _conversation.member.memberAvatar != null
                          ? NetworkImage(_conversation.member.memberAvatar)
                          : AssetImage("assets/images/avatar.png"),
                    ),
                    SizedBox(width: 6),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width - 160,
                          child: Text(
                              _conversation.member != null
                                  ? _conversation.member.memberName
                                  : "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        SizedBox(height: 2),
                        Text(
                            _conversation.lastMessageDate != null
                                ? Helper.calculatorTime(
                                    _conversation.lastMessageDate)
                                : "",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              _conversation.post != null
                  ? Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: Colors.grey)),
                      padding: EdgeInsets.all(4),
                      child: Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: Helper.tempAvatar,
                            placeholder: (context, url) =>
                                Image.asset("assets/images/placeholder.png"),
                            errorWidget: (context, url, error) =>
                                Image.asset("assets/images/error.png"),
                            fit: BoxFit.cover,
                            width: 100,
                            height: 50,
                          ),
                          SizedBox(width: 6),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 160,
                                child: Text(
                                    _conversation.post != null
                                        ? _conversation.post.title
                                        : "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                  _conversation.post != null
                                      ? _conversation.post.joinFee
                                      : "",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Container(),
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
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(hubConnection.state == HubConnectionState.Connected
        //       ? Icons.cast_connected
        //       : Icons.cast_connected_outlined),
        //   onPressed: () async {
        //     await hubConnection.start();
        //   },
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}
