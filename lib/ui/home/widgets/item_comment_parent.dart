import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/comment/comment_response.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:conecapp/ui/home/pages/introduce_page.dart';
import 'package:flutter/material.dart';
import '../../../common/globals.dart' as globals;

import 'child_comment_widget.dart';

class ItemCommentParent extends StatefulWidget {
  final Comment comment;
  final String ownerId;
  final ItemsByCategoryBloc bloc;
  final Function(String parentID, bool isDelete) callback;

  ItemCommentParent(this.comment, this.ownerId, this.bloc, this.callback);

  @override
  _ItemCommentParentState createState() => _ItemCommentParentState();

}

class _ItemCommentParentState extends State<ItemCommentParent> {
  ItemsByCategoryBloc _itemsByCategoryBloc;
  bool _isLikeComment = false;
  int _commentLikeCount = 0;
  String _token;
  bool _isTokenExpired = true;

  void getToken() async {
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
    });
  }

  @override
  void initState() {
    _itemsByCategoryBloc = widget.bloc;
    _isLikeComment = widget.comment.userHasUpvoted;
    _commentLikeCount = widget.comment.upvoteCount;
    super.initState();
    getToken();
  }

  List<Comment> getChildCommentByParentId(String parentID) {
    return _itemsByCategoryBloc.allComments
        .where((element) => element.parent == parentID)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        if (widget.comment.createdByCurrentUser) {
          widget.callback(widget.comment.id, true);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: (){
                    Navigator.of(context).pushNamed(
                        IntroducePage.ROUTE_NAME,
                        arguments: {
                          'clubId': widget.ownerId
                        });
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey,
                    backgroundImage: widget.comment.profilePictureUrl != null
                        ? NetworkImage(widget.comment.profilePictureUrl)
                        : AssetImage("assets/images/avatar.png"),
                  ),
                ),
//                CircleAvatar(
//                  radius: 16,
//                  backgroundImage: CachedNetworkImageProvider(
//                      parentComment.profilePictureUrl),
//                ),
                SizedBox(width: 4),
                Container(
                  width: MediaQuery.of(context).size.width - 90,
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                      color: Colors.black12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        onTap: (){
                          Navigator.of(context).pushNamed(
                              IntroducePage.ROUTE_NAME,
                              arguments: {
                                'clubId': widget.ownerId
                              });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(widget.comment.fullname ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                            ),
                            Container(
                              width: 80,
                              child: Text(
                                Helper.calculatorTime(widget.comment.created),
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w400),
                              ),
                            )
                          ],
                        ),
                      ),
                      Text(
                        widget.comment.content,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 40, top: 4),
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      if (_token == null || _token.length == 0) {
                        Helper.showAuthenticationDialog(context);
                      } else {
                        if (_isTokenExpired) {
                          Helper.showTokenExpiredDialog(context);
                        } else {
                          if (!_isLikeComment) {
                            _itemsByCategoryBloc
                                .requestLikeComment(widget.comment.id);
                            _commentLikeCount++;
                          } else {
                            _itemsByCategoryBloc
                                .requestUnLikeComment(widget.comment.id);
                            _commentLikeCount--;
                          }
                          setState(() {
                            _isLikeComment = !_isLikeComment;
                          });
                        }
                      }
                    },
                    child: Text("Thích",
                        key: ValueKey(widget.comment.id),
                        style: TextStyle(
                            fontSize: 14,
                            color:
                                _isLikeComment ? Colors.blue : Colors.black54)),
                  ),
                  SizedBox(width: 32),
                  InkWell(
                    onTap: () {
                      widget.callback(widget.comment.id, false);
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.comment, size: 14, color: Colors.black54),
                        SizedBox(width: 8),
                        Text("Trả lời",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.thumb_up, size: 14, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    _commentLikeCount.toString() ?? "0",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(width: 4),
                ],
              ),
            ),
            Column(
              children: List<Widget>.from(
                  getChildCommentByParentId(widget.comment.id).map(
                (childComment) => ChildCommentWidget(
                    childComment, ValueKey(childComment.id), widget.callback),
              )).toList(),
            )
          ],
        ),
      ),
    );
  }
}
