import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/comment/comment_response.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:flutter/material.dart';
import '../../../common/globals.dart' as globals;

class ChildCommentWidget extends StatefulWidget {
  final Comment comment;
  final Function(String parentID, bool isDelete) callback;
  final Key key;

  ChildCommentWidget(this.comment, this.key, this.callback);

  @override
  _ChildCommentWidgetState createState() => _ChildCommentWidgetState();
}

class _ChildCommentWidgetState extends State<ChildCommentWidget> {
  bool _isLikeComment = false;
  int _commentLikeCount = 0;
  ItemsByCategoryBloc _itemsByCategoryBloc = ItemsByCategoryBloc();

  String _token;
  bool _isTokenExpired = true;
  void getToken() async{
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
    });
  }

  @override
  void initState() {
    _isLikeComment = widget.comment.userHasUpvoted;
    _commentLikeCount = widget.comment.upvoteCount;
    super.initState();
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: (){
        widget.callback(widget.comment.id, true);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12, left: 40, top: 8),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
//                CircleAvatar(
//                  radius: 16,
//                  backgroundImage:
//                      CachedNetworkImageProvider(_comment.profilePictureUrl),
//                ),
                CircleAvatar(
                  radius: 16,
                  backgroundImage: widget.comment.profilePictureUrl !=
                      null
                      ? NetworkImage(
                      widget.comment.profilePictureUrl)
                      : AssetImage(
                      "assets/images/avatar.png"),
                ),
                SizedBox(width: 4),
                Container(
                  width: MediaQuery.of(context).size.width - 124,
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                      color: Colors.black12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(widget.comment.fullname ?? "",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          Text(
                              Helper.calculatorTime(widget.comment.created),
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          )
                        ],
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
                    key: ValueKey(widget.comment.id),
                    onTap: () {
                      if(_token == null || _token.length == 0){
                        Helper.showAuthenticationDialog(context);
                      }else{
                        if(_isTokenExpired){
                          Helper.showTokenExpiredDialog(context);
                        }else{
                          if (!_isLikeComment) {
                            _itemsByCategoryBloc.requestLikeComment(widget.comment.id);
                            _commentLikeCount++;
                          } else {
                            _itemsByCategoryBloc.requestUnLikeComment(widget.comment.id);
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
                     widget.callback(widget.comment.parent, false);
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
            )
          ],
        ),
      ),
    );
  }
}
