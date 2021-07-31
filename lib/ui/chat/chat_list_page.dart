import 'package:conecapp/common/helper.dart';
import 'package:conecapp/ui/chat/user_char.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  static const ROUTE_NAME = "/chat-list";

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<UserChat> _userChat = List.generate(
      5,
      (index) => UserChat(
          name: 'User $index',
          avatar: Helper.tempAvatar,
          lastMessage: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello"));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Tin nhắn"),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListView.builder(
            itemCount: _userChat.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(ChatPage.ROUTE_NAME);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey,
                        backgroundImage: _userChat[index].avatar != null
                            ? NetworkImage(_userChat[index].avatar)
                            : AssetImage("assets/images/avatar.png"),
                      ),
                      SizedBox(width: 4),
                      Container(
                        width: MediaQuery.of(context).size.width - 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_userChat[index].name,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 2),
                            Text(_userChat[index].lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
      ),
    ));
  }
}
