import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/comment/comment_response.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:flutter/material.dart';
import '../../../common/globals.dart' as globals;

import 'child_comment_widget.dart';

class ItemCommentParent extends StatefulWidget {
  final Comment comment;
  final ItemsByCategoryBloc bloc;
  final Function(String parentID, bool isDelete) callback;

  ItemCommentParent(this.comment, this.bloc, this.callback);

  @override
  _ItemCommentParentState createState() => _ItemCommentParentState();
}

class _ItemCommentParentState extends State<ItemCommentParent> {
  Comment parentComment;
  ItemsByCategoryBloc _itemsByCategoryBloc;
  bool _isLikeComment = false;
  int _commentLikeCount = 0;

  @override
  void initState() {
    parentComment = widget.comment;
    _itemsByCategoryBloc = widget.bloc;
    _isLikeComment = parentComment.userHasUpvoted;
    _commentLikeCount = parentComment.upvoteCount;
    super.initState();
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
        widget.callback(parentComment.id, true);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 16,
                  backgroundImage: parentComment.profilePictureUrl !=
                      null
                      ? NetworkImage(
                      parentComment.profilePictureUrl)
                      : AssetImage(
                      "assets/images/avatar.png"),
                ),
//                CircleAvatar(
//                  radius: 16,
//                  backgroundImage: CachedNetworkImageProvider(
//                      parentComment.profilePictureUrl),
//                ),
                SizedBox(width: 4),
                Container(
                  width: MediaQuery.of(context).size.width - 75,
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
                          Text(parentComment.fullname,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          Text(
                            Helper.calculatorTime(parentComment.created),
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                      Text(
                        parentComment.content,
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
                      if(!globals.isSigned){
                        Helper.showAuthenticationDialog(context);
                      }else{
                        if (!_isLikeComment) {
                          _itemsByCategoryBloc.requestLikeComment(parentComment.id);
                          _commentLikeCount++;
                        } else {
                          _itemsByCategoryBloc.requestUnLikeComment(parentComment.id);
                          _commentLikeCount--;
                        }
                        setState(() {
                          _isLikeComment=!_isLikeComment;
                        });
                      }
                    },
                    child: Text("Thích",
                        key: ValueKey(parentComment.id),
                        style: TextStyle(
                            fontSize: 14,
                            color:
                                _isLikeComment ? Colors.blue : Colors.black54)),
                  ),
                  SizedBox(width: 32),
                  InkWell(
                    onTap: () {
                      widget.callback(parentComment.id, false);
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
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54),
                  ),
                  SizedBox(width: 4),
                ],
              ),
            ),
            Column(
              children: List<Widget>.from(
                  getChildCommentByParentId(parentComment.id).map(
                (childComment) =>
                    ChildCommentWidget(childComment, ValueKey(childComment.id), widget.callback),
              )).toList(),
            )
          ],
        ),
      ),
    );
  }
}
