import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/chat/conversations_response.dart';
import 'package:conecapp/models/response/chat/message_response.dart';
import 'package:conecapp/models/response/chat/send_message_response.dart';
import 'package:conecapp/ui/chat/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:signalr_client/signalr_client.dart';

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
  bool _isLoading = false;
  List<MessageChat> _message = List();
  Conversation _conversation = Conversation();
  int page = 0;
  bool _shouldLoadMore = true;
  MessageChat mess = new MessageChat(
    content: "aaaaaa"
  );

  final serverUrl = Helper.baseURL + "/appNotifyHub";
  HubConnection hubConnection;
  HttpConnectionOptions connectionOptions;

  ScrollController _scrollController;

  void _scrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (_shouldLoadMore) {
        _shouldLoadMore = false;
        _chatBloc.requestGetMessages(_conversation.id, page);
        setState(() {
          page++;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    isCallApi = true;
    initSignalR();
    _scrollController = new ScrollController()..addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isCallApi) {
      _isLoading = true;
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, Object>;
      String memberId = routeArgs['memberId'];
      String conversationId = routeArgs['conversationId'];
      String postId;
      if (routeArgs['postId'] != null) {
        postId = routeArgs['postId'];
      }
      //conversationId == null => new conversation;
      if (conversationId != null) {
        _chatBloc.requestSelectConversation(conversationId);
        _chatBloc.selectConversationStream.listen((event) {
          switch (event.status) {
            case Status.LOADING:
              break;
            case Status.COMPLETED:
              setState(() {
                _conversation = event.data.conversation;
                if (_conversation.messages != null) {
                  setState(() {
                    _message.addAll(_conversation.messages.reversed.toList());
                  });
                }
              });
              _chatBloc.requestGetMessages(conversationId, page);
              page = 1;

              break;
            case Status.ERROR:
              print("selectConversation: " + event.message);
              break;
          }
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        _chatBloc.requestCreateConversation(memberId, postId: postId);
        _chatBloc.createConversationStream.listen((event) {
          switch (event.status) {
            case Status.LOADING:
              break;
            case Status.COMPLETED:
              setState(() {
                _conversation = event.data.conversation;
              });
              if (event.data.isNew) {
                setState(() {
                  _isLoading = false;
                });
              } else {
                //_chatBloc.requestGetMessages(_conversation.id, 0);
              }
              break;
            case Status.ERROR:
              break;
          }
        });
      }
      startConnection();
      isCallApi = false;
    }
  }

  String send = "SendMessage";
  String rev = "ReceiveMessage";
  void initSignalR() async{
    connectionOptions = HttpConnectionOptions(accessTokenFactory: () async => await Helper.token());
    hubConnection = HubConnectionBuilder().withUrl(serverUrl, options: connectionOptions).build();
    hubConnection.on(rev, _handleNewMessage);

  }

  void _handleNewMessage(dynamic mess) {
    print("mess: " + mess.toString());
    var ms = MessageChat.fromJson(mess[0]);
    setState(() {
      _message.insert(0, ms);
    });
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

  @override
  void dispose() {
    super.dispose();
    _chatBloc.dispose();
    _message.clear();
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
                              _conversation.member != null &&
                                      _conversation.member.memberName != null
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
                            imageUrl: _conversation.post != null
                                ? _conversation.post.image
                                : "",
                            placeholder: (context, url) =>
                                Image.asset("assets/images/placeholder.png"),
                            errorWidget: (context, url, error) =>
                                Image.asset("assets/images/error.png"),
                            fit: BoxFit.cover,
                            width: 80,
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
                child: StreamBuilder<ApiResponse<List<MessageChat>>>(
                    stream: _chatBloc.messagesStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (_message != null && snapshot.data.data != null) {
                          if (snapshot.data.data.length > 0) {
                            if (page == 0) {
                              _message = snapshot.data.data;
                            } else {
                              _message.addAll(snapshot.data.data);
                            }
                            _shouldLoadMore = true;
                          } else {
                            _shouldLoadMore = false;
                          }
                        }
                        switch (snapshot.data.status) {
                          case Status.LOADING:
                            return UILoading(
                                loadingMessage: snapshot.data.message);
                          case Status.ERROR:
                            return UIError(errorMessage: snapshot.data.message);
                          case Status.COMPLETED:
                          default:
                            return Messages(_message, _scrollController);
                        }
                      }
                      return Center(
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : Container());
                    }),
              ),
              NewMessage(
                onSend: (message) async {
                  if (_conversation.id != null) {
                    SendMessageResponse response = await _chatBloc
                        .requestSendMessage(_conversation.id, message);
                    if (response.status == 1) {
                      setState(() {
                        _message.insert(0, response.message);
                      });
                    }
                  }
                },
                conversationId: _conversation != null
                    ? _conversation.id
                    : Helper.hardCodeConversationId,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(hubConnection.state == HubConnectionState.Connected
              ? Icons.cast_connected
              : Icons.cast_connected_outlined),
          onPressed: () async {
            await hubConnection.invoke(send, args: ["835f0dba-3dce-419b-806a-be4678cb2b75", mess.toJson()]);
          },
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}
