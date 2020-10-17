import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/ui/home/pages/comment_bloc.dart';
import 'package:conecapp/ui/home/widgets/item_parent_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../../../common/globals.dart' as globals;

class CommentPage extends StatefulWidget {
  final ItemDetail itemDetail;

  CommentPage(this.itemDetail);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  TextEditingController _controller = TextEditingController();
  bool _isLikeOwner = false;
  bool _isShowCommentInput = false;
  int _likeCount = 0;
  bool _isLoading = false;
  var _focusNode = FocusNode();
  String _token;
  bool _isTokenExpired = true;

  @override
  void initState() {
    super.initState();
    getToken();
    _likeCount = widget.itemDetail.likeCount;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void getToken() async {
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
    });
  }

  void requestFocus(String parentId, bool isDelete) {
    debugPrint(parentId ?? "NULL");
    if (_token == null) {
      Helper.showAuthenticationDialog(context);
    } else {
      if (_isTokenExpired) {
        Helper.showTokenExpiredDialog(context);
      } else {
        if (!isDelete) {
          _focusNode.requestFocus();
          setState(() {
            _isShowCommentInput = !_isShowCommentInput;
          });
        } else {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          margin: EdgeInsets.only(top: 8),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Icon(
                    Icons.thumb_up,
                    size: 18,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _likeCount.toString() ?? "0",
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  Text('${widget.itemDetail.viewCount} lượt xem')
                ],
              ),
              Container(
                  width: double.infinity,
                  height: 0.5,
                  color: Colors.grey,
                  margin: EdgeInsets.only(top: 4, bottom: 16)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      if (_token == null) {
                        Helper.showAuthenticationDialog(context);
                      } else {
                        if (_isTokenExpired) {
                          Helper.showTokenExpiredDialog(context);
                        } else {
                          if (!_isLikeOwner) {
                            _likeCount++;
                          } else {
                            _likeCount--;
                          }
                          setState(() {
                            _isLikeOwner = !_isLikeOwner;
                          });
                        }
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.thumb_up,
                          size: 18,
                          color: _isLikeOwner ? Colors.blue : Colors.black87,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Thích",
                          style: TextStyle(
                            fontSize: 16,
                            color: _isLikeOwner ? Colors.blue : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      requestFocus(null, false);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.comment,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text("Bình luận", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      Share.share(widget.itemDetail.shareLink ??
                          Helper.applicationUrl());
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.mobile_screen_share,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Chia sẻ",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                  width: double.infinity,
                  height: 0.5,
                  color: Colors.grey,
                  margin: EdgeInsets.only(top: 16, bottom: 16)),
              Provider(
                  create: (context) => CommentBloc(),
                  child: ItemParentPage(widget.itemDetail.postId))
            ],
          ),
        ),
        _isShowCommentInput
            ? Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                ]),
                padding: EdgeInsets.symmetric(horizontal: 8),
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: Row(
                  children: <Widget>[
                    !_isLoading
                        ? CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey,
                            backgroundImage: widget.itemDetail.ownerAvatar !=
                                    null
                                ? NetworkImage(widget.itemDetail.ownerAvatar)
                                : AssetImage("assets/images/avatar.png"),
                          )
                        : CupertinoActivityIndicator(
                            radius: 16,
                          ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Viết bình luận...',
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0)),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    InkWell(
                      child: Icon(Icons.send),
                      onTap: () {
                        //
                      },
                    )
                  ],
                ),
              )
            : Container()
      ],
    );
  }
}
