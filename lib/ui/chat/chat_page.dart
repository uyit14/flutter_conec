import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/chat/conversations_response.dart';
import 'package:conecapp/models/response/chat/message_response.dart';
import 'package:conecapp/models/response/chat/send_message_response.dart';
import 'package:conecapp/ui/chat/chat_bloc.dart';
import 'package:conecapp/ui/home/pages/introduce_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  int page = 1;
  bool _shouldLoadMore = true;

  final serverUrl = Helper.baseURL + "/appNotifyHub";
  HubConnection hubConnection;
  HttpConnectionOptions connectionOptions;
  String send = "SendMessage";
  String rev = "ReceiveMessage";

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
      String messHardCode = routeArgs['mess'];
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
              page = 2;

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
        if (messHardCode != null) {
          _chatBloc.requestCreateConversationWithMessage(memberId,
              postId: postId, mess: messHardCode);
          _chatBloc.createConversationWithMessageStream.listen((event) {
            switch (event.status) {
              case Status.LOADING:
                setState(() {
                  _isLoading = true;
                });
                break;
              case Status.COMPLETED:
                setState(() {
                  _conversation = event.data.conversation;
                  if (_conversation.messages != null) {
                    setState(() {
                      _message.addAll(_conversation.messages.reversed.toList());
                    });
                  }
                  _isLoading = false;
                });
                break;
              case Status.ERROR:
                setState(() {
                  _isLoading = false;
                });
                break;
            }
          });
        } else {
          _chatBloc.requestCreateConversation(memberId, postId: postId);
          _chatBloc.createConversationStream.listen((event) {
            switch (event.status) {
              case Status.LOADING:
                setState(() {
                  _isLoading = true;
                });
                break;
              case Status.COMPLETED:
                setState(() {
                  _conversation = event.data.conversation;
                  _message = _conversation.messages.reversed.toList();
                  _isLoading = false;
                });
                break;
              case Status.ERROR:
                setState(() {
                  _isLoading = false;
                });
                break;
            }
          });
        }
      }
      startConnection();
      isCallApi = false;
    }
  }

  void initSignalR() async {
    connectionOptions = HttpConnectionOptions(
        accessTokenFactory: () async => await Helper.token());
    hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl, options: connectionOptions)
        .build();
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
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(IntroducePage.ROUTE_NAME, arguments: {
                          'clubId': _conversation.member.memberId
                        });
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
                            backgroundImage: _conversation.member != null &&
                                    _conversation.member.memberAvatar != null
                                ? NetworkImage(
                                    _conversation.member.memberAvatar)
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
                                            _conversation.member.memberName !=
                                                null
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
                    Spacer(),
                    PopupMenuButton(
                      color: Colors.white,
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Xóa cuộc trò chuyện'),
                          )
                        ];
                      },
                      onSelected: (String value) {
                        Helper.showDeleteDialog(context, "Thông báo",
                            "Bạn muốn xóa cuộc trò chuyện này?", () async {
                          final result = await _chatBloc
                              .requestDeleteConversation(_conversation.id);
                          if (!result) {
                            Fluttertoast.showToast(msg: "Vui lòng thử lại");
                          }
                          Navigator.of(context).pop(1);
                          Navigator.of(context).pop(1);
                        });
                      },
                    )
                  ],
                ),
              ),
              _conversation.post != null
                  ? Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: Colors.grey)),
                      padding: EdgeInsets.all(4),
                      child: InkWell(
                        onTap: () => Helper.navigatorToPost(
                            _conversation.post.id,
                            _conversation.post.topicId,
                            _conversation.post.title,
                            context),
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
                                  width:
                                      MediaQuery.of(context).size.width - 160,
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
                      ),
                    )
                  : Container(),
              Expanded(
                child: StreamBuilder<ApiResponse<List<MessageChat>>>(
                    stream: _chatBloc.messagesStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData || _message.length > 0) {
                        if (snapshot.data != null) {
                          if (page == 1) {
                            _message = snapshot.data.data;
                          } else {
                            _message.addAll(snapshot.data.data);
                          }
                          _shouldLoadMore = true;
                        } else {
                          _shouldLoadMore = false;
                        }
                        // case Status.LOADING:
                        //   return UILoading(
                        //       loadingMessage: snapshot.data.message);
                        // case Status.ERROR:
                        //   return UIError(errorMessage: snapshot.data.message);
                        // case Status.COMPLETED:
                        // default:
                        return Messages(_message, _scrollController);
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
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(hubConnection.state == HubConnectionState.Connected
        //       ? Icons.cast_connected
        //       : Icons.cast_connected_outlined),
        //   onPressed: () async {
        //     await hubConnection.invoke(send, args: ["40fcdb4a-6c82-4150-be23-4509a7d64ec6", mess.toJson()]);
        //   },
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}
