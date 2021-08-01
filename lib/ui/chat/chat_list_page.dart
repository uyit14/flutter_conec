import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/chat/conversations_response.dart';
import 'package:conecapp/ui/chat/chat_bloc.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  static const ROUTE_NAME = "/chat-list";

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  ChatBloc _chatBloc = ChatBloc();
  List<Conversation> _userChat = List();

  @override
  void initState() {
    super.initState();
    _chatBloc.requestGetConversations();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Trò chuyện"),
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
                        _userChat = snapshot.data.data;
                        return Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: ListView.builder(
                              itemCount: _userChat.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(
                                        ChatPage.ROUTE_NAME, arguments: {
                                      "memberId": _userChat[index].member
                                          .memberId,
                                      "postId": _userChat[index].post != null
                                          ? _userChat[index].post.id
                                          : null
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Colors.grey,
                                          backgroundImage:
                                          _userChat[index].member != null &&
                                              _userChat[index]
                                                  .member
                                                  .memberAvatar !=
                                                  null
                                              ? NetworkImage(_userChat[index]
                                              .member
                                              .memberAvatar)
                                              : AssetImage(
                                              "assets/images/avatar.png"),
                                        ),
                                        SizedBox(width: 4),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width -
                                              100,
                                          child: Stack(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      _userChat[index]
                                                          .member
                                                          .memberName,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
                                                              .bold)),
                                                  SizedBox(height: 2),
                                                  Text(_userChat[index]
                                                      .lastMessage,
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: _userChat[index]
                                                              .seen ? FontWeight
                                                              .w400 : FontWeight
                                                              .bold)),
                                                ],
                                              ),
                                              Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  width: 10,
                                                  height: 10,
                                                  margin: EdgeInsets.only(
                                                      right: 6),
                                                  decoration: BoxDecoration(
                                                    //borderRadius: BorderRadius.all(Radius.circular(16)),
                                                      shape:
                                                      BoxShape.circle,
                                                      border: Border.all(
                                                          width: 1,
                                                          color:
                                                          Colors.white),
                                                      color: _userChat[index]
                                                          .seen
                                                          ? Colors.transparent
                                                          : Colors
                                                          .blue),
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
