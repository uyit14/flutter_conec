import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/chat/conversations_response.dart';
import 'package:conecapp/models/response/chat/message_response.dart';
import 'package:conecapp/partner_module/models/search_m_response.dart';
import 'package:conecapp/partner_module/ui/member/search_member_page.dart';
import 'package:conecapp/ui/chat/chat_bloc.dart';
import 'package:conecapp/ui/chat/search_member_chat.dart';
import 'package:flutter/material.dart';
import 'package:signalr_client/http_connection_options.dart';
import 'package:signalr_client/hub_connection.dart';
import 'package:signalr_client/hub_connection_builder.dart';

import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  static const ROUTE_NAME = "/chat-list";

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  ChatBloc _chatBloc = ChatBloc();
  List<Conversation> _conversations = List();
  final serverUrl = Helper.baseURL + "/appNotifyHub";
  HubConnection hubConnection;
  HttpConnectionOptions connectionOptions;
  String send = "SendMessage";
  String rev = "ReceiveMessage";
  Conversation _conversation = Conversation();

  @override
  void initState() {
    super.initState();
    initSignalR();
    _chatBloc.requestGetConversations();
    startConnection();
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
    var ms = MessageChat.fromJson(mess[0]);
    setState(() {
      int pos = _conversations
          .indexWhere((element) => element.id == ms.conversationId);
      if (pos == -1) {
        _chatBloc.requestGetConversations();
      } else {
        _conversations[pos].seen = false;
        _conversations[pos].lastMessage = ms.content;
        Conversation conversation = _conversations[pos];
        _conversations.removeAt(pos);
        _conversations.insert(0, conversation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Trò chuyện"),
        actions: [
          IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(SearchMemberChatPage.ROUTE_NAME)
                    .then((value) {
                  if (value != null) {
                    _conversation = value;
                    Navigator.of(context)
                        .pushNamed(ChatPage.ROUTE_NAME, arguments: {
                      'conversationId': _conversation.id,
                      "memberId": _conversation.member.memberId,
                      "postId": _conversation.post != null
                          ? _conversation.post.id
                          : null
                    }).then((value) {
                      if (value == 1) {
                        _chatBloc.requestGetConversations();
                      }
                    });
                  }
                });
              }),
          SizedBox(width: 12)
        ],
      ),
      body: StreamBuilder<ApiResponse<List<Conversation>>>(
          stream: _chatBloc.conversationStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return UILoading();
                case Status.ERROR:
                  return UIError(errorMessage: snapshot.data.message);
                case Status.COMPLETED:
                  if (snapshot.data.data.length > 0) {
                    _conversations = snapshot.data.data;
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListView.builder(
                          itemCount: _conversations.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(ChatPage.ROUTE_NAME, arguments: {
                                  'conversationId': _conversations[index].id,
                                  "memberId":
                                      _conversations[index].member.memberId,
                                  "postId": _conversations[index].post != null
                                      ? _conversations[index].post.id
                                      : null
                                }).then((value) {
                                  if (value == 1) {
                                    _chatBloc.requestGetConversations();
                                  }
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: _conversations[index]
                                                      .member !=
                                                  null &&
                                              _conversations[index]
                                                      .member
                                                      .memberAvatar !=
                                                  null
                                          ? NetworkImage(_conversations[index]
                                              .member
                                              .memberAvatar)
                                          : AssetImage(
                                              "assets/images/avatar.png"),
                                    ),
                                    SizedBox(width: 4),
                                    Container(
                                      width: MediaQuery.of(context).size.width -
                                          100,
                                      child: Stack(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  _conversations[index]
                                                          .member
                                                          .memberName ??
                                                      "Người dùng mới",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              _conversations[index].post != null
                                                  ? SizedBox(height: 2)
                                                  : Container(),
                                              _conversations[index].post != null
                                                  ? Text(
                                                      _conversations[index]
                                                              .post
                                                              .title ??
                                                          "",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.w400))
                                                  : Container(),
                                              SizedBox(height: 2),
                                              Text(
                                                  _conversations[index]
                                                          .lastMessage ??
                                                      "",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          _conversations[index]
                                                                  .seen
                                                              ? FontWeight.w400
                                                              : FontWeight
                                                                  .bold)),
                                            ],
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              margin: EdgeInsets.only(right: 6),
                                              decoration: BoxDecoration(
                                                  //borderRadius: BorderRadius.all(Radius.circular(16)),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.white),
                                                  color:
                                                      _conversations[index].seen
                                                          ? Colors.transparent
                                                          : Colors.blue),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    );
                  }
                  return Container();
              }
            }
            return Center(child: CircularProgressIndicator());
          }),
    ));
  }
}
