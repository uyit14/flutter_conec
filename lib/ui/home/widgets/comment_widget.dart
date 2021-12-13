import 'dart:convert';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/comment/comment_response.dart';
import 'package:conecapp/models/response/comment/follow_response.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:conecapp/ui/home/pages/introduce_page.dart';
import 'package:conecapp/ui/home/widgets/item_comment_parent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

class CommentWidget extends StatefulWidget {
  final String postId;
  final ItemDetail itemDetail;
  final Function reloadPage;

  CommentWidget(this.postId, this.itemDetail, this.reloadPage);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  ItemsByCategoryBloc _itemsByCategoryBloc = ItemsByCategoryBloc();
  TextEditingController _controller = TextEditingController();
  bool _isLikeOwner = false;
  bool _isShowCommentInput = false;
  int _likeCount = 0;
  bool _isLoading = false;
  List<Comment> comments = List();
  bool _addDataToList = false;
  String _parentId;
  var _focusNode = FocusNode();

  String _token;
  bool _isTokenExpired = true;
  String _avatar;
  List<Follower> _datas = List();

  void getToken() async {
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
    });
    if (!expired && token != null) {
      _itemsByCategoryBloc.requestGetAvatar();
      _itemsByCategoryBloc.avatarStream.listen((event) {
        switch (event.status) {
          case Status.LOADING:
            break;
          case Status.COMPLETED:
            setState(() {
              _avatar = event.data;
            });
            break;
          case Status.ERROR:
            break;
        }
      });
    }
  }

  @override
  void initState() {
    _addDataToList = true;
    super.initState();
    _itemsByCategoryBloc.requestGetFollower(widget.postId);
    getToken();
    _likeCount = widget.itemDetail.likeCount;
    _isLikeOwner = widget.itemDetail.likeOwner;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_addDataToList) _itemsByCategoryBloc.requestComment(widget.postId);
    _itemsByCategoryBloc.followerStream.listen((event) {
      if (event.status == Status.COMPLETED) {
        setState(() {
          _datas = event.data;
        });
      }
    });
  }

  void requestFocus(String parentId, bool isDelete) {
    debugPrint(parentId ?? "NULL");
    if (_token == null || _token.length == 0) {
      Helper.showAuthenticationDialog(context);
    } else {
      if (_isTokenExpired) {
        Helper.showTokenExpiredDialog(context);
      } else {
        if (!isDelete) {
          _parentId = parentId;
          _focusNode.requestFocus();
          setState(() {
            _isShowCommentInput = !_isShowCommentInput;
          });
        } else {
          Helper.showDeleteDialog(context, "Xóa bình luận",
              "Bạn có chắc chắn muốn xóa bình luận này?", () {
            print("ui delete at: " +
                comments
                    .indexWhere((element) => element.id == parentId)
                    .toString());
            print("with content ui: " + comments[0].content);
            int deleteAt =
                comments.indexWhere((element) => element.id == parentId);
            _itemsByCategoryBloc.requestDeleteComment(parentId).then((value) {
              if (deleteAt == -1) {
                _itemsByCategoryBloc.allComments
                    .removeWhere((element) => element.id == parentId);
              }

              setState(() {
                _addDataToList = true;
              });
            });
            comments.clear();
            Navigator.pop(context);
            widget.reloadPage();
          });
//        setState(() {
//          comments.removeWhere((element) => element.id == parentId);
//        });
        }
      }
    }
  }

  Widget _itemPerson(Follower fl) {
    return Container(
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(IntroducePage.ROUTE_NAME,
              arguments: {'clubId': fl.id});
        },
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  backgroundImage: fl.avatar != null
                      ? NetworkImage(fl.avatar)
                      : AssetImage("assets/images/avatar.png"),
                ),
                SizedBox(width: 8),
                Container(
                    width: MediaQuery.of(context).size.width - 85,
                    child: Text(fl.owner ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 18))),
              ],
            ),
            SizedBox(height: 8),
            Container(
                height: 0.5,
                color: Colors.grey,
                margin: EdgeInsets.only(left: 50)),
          ],
        ),
      ),
    );
  }

  void _shareLink() {
    final act = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child:
                Text('Sao chép liên kết', style: TextStyle(color: Colors.blue)),
            onPressed: () => {
              Clipboard.setData(new ClipboardData(text: widget.itemDetail.shareLink ?? ""))
                  .then((_) {
                Navigator.pop(context);
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Đã sao chép!')));
              })
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Chia sẻ', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              print("shared: ${widget.itemDetail.shareLink}");
              Share.share(
                  widget.itemDetail.shareLink ?? Helper.applicationUrl());
              Navigator.pop(context);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Hủy'),
          onPressed: () {
            Navigator.pop(context);
          },
        ));
    showCupertinoModalPopup(
        context: context, builder: (BuildContext context) => act);
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
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: ListView(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                child: Row(
                                  children: [
                                    Text("Theo dõi",
                                        style: TextStyle(
                                            fontSize: 22, color: Colors.black)),
                                    Spacer(),
                                    IconButton(
                                        icon: Icon(Icons.close, size: 28),
                                        onPressed: () =>
                                            Navigator.of(context).pop())
                                  ],
                                ),
                              ),
                              ..._datas.map((e) => _itemPerson(e))
                            ],
                          ),
                        );
                      });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Image.asset(
                      "assets/images/heart_1.png",
                      height: 18,
                      width: 18,
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
                      if (_token == null || _token.length == 0) {
                        Helper.showAuthenticationDialog(context);
                      } else {
                        if (_isTokenExpired) {
                          Helper.showTokenExpiredDialog(context);
                        } else {
                          _itemsByCategoryBloc
                              .requestLikePost(widget.itemDetail.postId);
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
                        IndexedStack(
                          index: _isLikeOwner ? 0 : 1,
                          children: [
                            Image.asset(
                              "assets/images/heart_1.png",
                              height: 18,
                              width: 18,
                            ),
                            Image.asset(
                              "assets/images/heart_2.png",
                              height: 18,
                              width: 18,
                            ),
                          ],
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Theo dõi",
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
                    onTap: _shareLink,
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
              StreamBuilder<ApiResponse<List<Comment>>>(
                  stream: _itemsByCategoryBloc.parentCommentStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      switch (snapshot.data.status) {
                        case Status.LOADING:
                          return UILoading(
                              loadingMessage: snapshot.data.message);
                        case Status.COMPLETED:
                          if (_addDataToList) {
                            comments.addAll(snapshot.data.data);
                            _addDataToList = false;
                            debugPrint(comments.length.toString() +
                                "---ui lenght list");
                            comments.forEach((element) {
                              print(element.content);
                            });
                          }

                          return Column(
                              children: List<Widget>.from(
                                  comments.map((parentComment) {
                            print("-------" + parentComment.content);
                            return ItemCommentParent(
                                parentComment, _itemsByCategoryBloc,
                                (parentID, isDelete) {
                              requestFocus(parentID, isDelete);
                            });
                          })).toList());
                        case Status.ERROR:
                          return UIError(errorMessage: snapshot.data.message);
                      }
                    }
                    return Container(
                        child: Text(
                            "Chưa có bình luận, bạn hãy là người đầu tiên bình luận"));
                  }),
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
                            backgroundImage: _avatar != null
                                ? NetworkImage(_avatar)
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
                        if (_controller.text.length < 1) {
                          return;
                        } else {
                          setState(() {
                            _isLoading = true;
                          });
                          _itemsByCategoryBloc
                              .requestPostComment(jsonEncode(_parentId == null
                                  ? {
                                      "content": _controller.text,
                                      "postId": widget.postId
                                    }
                                  : {
                                      "content": _controller.text,
                                      "postId": widget.postId,
                                      "parent": _parentId
                                    }))
                              .then((value) {
                            print("value: $value");
                            if (value.parent == null) {
                              comments.add(value);
                            } else {
                              _itemsByCategoryBloc.allComments.add(value);
                            }
                            _controller.clear();
                            setState(() {
                              _isLoading = false;
                            });
                          });
                        }
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
