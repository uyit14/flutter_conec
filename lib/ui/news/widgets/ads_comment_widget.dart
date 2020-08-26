import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/ads_detail.dart';
import 'package:conecapp/models/response/comment/comment_response.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:conecapp/ui/home/widgets/item_comment_parent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import '../../../common/globals.dart' as globals;

class AdsCommentWidget extends StatefulWidget {
  final String postId;
  final AdsDetail itemDetail;
  final Function reloadPage;

  AdsCommentWidget(this.postId, this.itemDetail, this.reloadPage);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<AdsCommentWidget> {
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

  @override
  void initState() {
    _addDataToList = true;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_addDataToList) _itemsByCategoryBloc.requestComment(widget.postId);
    _likeCount = widget.itemDetail.likeCount;
  }

  void requestFocus(String parentId, bool isDelete) {
    debugPrint(parentId ?? "NULL");
    if (!globals.isSigned) {
      Helper.showAuthenticationDialog(context);
    } else {
      if (!isDelete) {
        _parentId = parentId;
        _focusNode.requestFocus();
        setState(() {
          _isShowCommentInput = !_isShowCommentInput;
        });
      } else {
        print("ui delete at: " +
            comments
                .indexWhere((element) => element.id == parentId)
                .toString());
        print("with content ui: " + comments[0].content);
        int deleteAt = comments.indexWhere((element) => element.id == parentId);
        Helper.showDeleteDialog(context, () {
          _itemsByCategoryBloc
              .requestDeleteComment(parentId)
              .then((value) {
            if (deleteAt == -1) {
              _itemsByCategoryBloc.allComments
                  .removeWhere((element) => element.id == parentId);
            }

            setState(() {
              _addDataToList = true;
            });
            comments.clear();
            Navigator.pop(context);
          });
        });
//        setState(() {
//          comments.removeWhere((element) => element.id == parentId);
//        });
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
                      if(!globals.isSigned){
                        Helper.showAuthenticationDialog(context);
                      }else{
                        _itemsByCategoryBloc.requestLikePost(widget.itemDetail.postId);
                        if (!_isLikeOwner) {
                          _likeCount++;
                        } else {
                          _likeCount--;
                        }
                        setState(() {
                          _isLikeOwner = !_isLikeOwner;
                        });
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
                      Share.share(Helper.applicationUrl());
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
                            comments.forEach((element) {print(element.content);});
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
                      backgroundImage: widget.itemDetail.ownerAvatar !=
                          null
                          ? NetworkImage(
                          widget.itemDetail.ownerAvatar)
                          : AssetImage(
                          "assets/images/avatar.png"),
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
                              .requestPostComment(
                                  jsonEncode(_parentId == null
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
