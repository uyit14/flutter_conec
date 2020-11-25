import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/models/response/mypost_response.dart';
import 'package:conecapp/ui/home/pages/item_detail_page.dart';
import 'package:conecapp/ui/mypost/blocs/post_action_bloc.dart';
import 'package:conecapp/ui/mypost/pages/edit_mypost_page.dart';
import 'package:conecapp/ui/mypost/widgets/custom_banner_status.dart';
import 'package:conecapp/ui/news/pages/news_detail_page.dart';
import 'package:conecapp/ui/news/pages/sell_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum MyPostStatus { Pending, Reject, Approve, Hidden, Archive }

class ItemMyPost extends StatefulWidget {
  final Key key;
  final int index;
  final MyPost myPost;
  final MyPostStatus status;
  final Function(String postId) callback;
  final Function(bool doRefresh) refresh;

  ItemMyPost(
      {this.myPost,
      this.key,
      this.status,
      this.callback,
      this.refresh,
      this.index});

  @override
  _ItemMyPostState createState() => _ItemMyPostState();
}

class _ItemMyPostState extends State<ItemMyPost> {
  PostActionBloc _postActionBloc;

  Color checkingStatus() {
    switch (widget.status) {
      case MyPostStatus.Approve:
        return Colors.green;
      case MyPostStatus.Archive:
        return Colors.blue;
      case MyPostStatus.Reject:
        return Colors.red;
      case MyPostStatus.Pending:
        return Colors.orange;
      case MyPostStatus.Hidden:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _postActionBloc = PostActionBloc();
  }

  @override
  void dispose() {
    super.dispose();
    _postActionBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        if(widget.myPost.topicId == "333f691d-6595-443d-bae3-9a2681025b53"){
          Navigator.of(context).pushNamed(
              NewsDetailPage.ROUTE_NAME,
              arguments: {
                'postId': widget.myPost.postId,
                'owner' : "00"
              });
        }else if(widget.myPost.topicId == "333f691d-6585-443a-bae3-9a2681025b53"){
          Navigator.of(context).pushNamed(
              SellDetailPage.ROUTE_NAME,
              arguments: {
                'postId': widget.myPost.postId,
                'owner' : "00"
              });
        }else{
            Navigator.of(context).pushNamed(
                ItemDetailPage.ROUTE_NAME,
                arguments: {
                  'postId': widget.myPost.postId,
                  'title': widget.myPost.title,
                  'owner' : "00"
                });
        }
      },
      child: Slidable(
        actionExtentRatio: 0.4,
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: IconSlideAction(
                        caption: 'Xóa',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () {
                          Helper.showDeleteDialog(context, "Xoá tin",
                              "Bạn có chắc chắn muốn xoá tin này?", () {
                            _postActionBloc.requestDeleteMyPost(
                                widget.myPost.postId, "Delete");
                            widget.callback(widget.myPost.postId);
                            Navigator.pop(context);
                            _postActionBloc.deleteMyPostStream.listen((event) {
                              switch (event.status) {
                                case Status.LOADING:
                                  break;
                                case Status.COMPLETED:
                                  break;
                                case Status.ERROR:
                                  Fluttertoast.showToast(
                                      msg: event.message,
                                      textColor: Colors.black87);
                                  Navigator.pop(context);
                                  break;
                              }
                            });
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: IconSlideAction(
                        caption: widget.key.toString().contains("hidden")
                            ? "Hiện"
                            : 'Ẩn',
                        color: widget.key.toString().contains("hidden")
                            ? Colors.green
                            : Colors.orange,
                        icon: widget.key.toString().contains("hidden")
                            ? Icons.open_in_browser
                            : Icons.cancel,
                        onTap: () {
                          _postActionBloc.requestDeleteMyPost(
                              widget.myPost.postId, "HidePost");
                          widget.callback(widget.myPost.postId);
                          _postActionBloc.deleteMyPostStream.listen((event) {
                            switch (event.status) {
                              case Status.LOADING:
                                break;
                              case Status.COMPLETED:
                                break;
                              case Status.ERROR:
                                Fluttertoast.showToast(
                                    msg: event.message,
                                    textColor: Colors.black87);
                                Navigator.pop(context);
                                break;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: IconSlideAction(
                        caption: 'Sửa',
                        color: Colors.blue,
                        icon: Icons.edit,
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(EditMyPostPage.ROUTE_NAME, arguments: {
                            'postId': widget.myPost.postId
                          }).then((value) => widget.refresh(value));
                        },
                      ),
                    ),
                    Expanded(
                      child: IconSlideAction(
                        caption: 'Làm mới',
                        color: Colors.green,
                        icon: Icons.refresh,
                        onTap: () {
                          if (widget.key.toString().contains("approve")) {
                            Helper.showDeleteDialog(context, "Làm mới tin",
                                "Bạn có chắc chắn muốn làm mới tin này?", () {
                              _postActionBloc
                                  .requestPushMyPost(widget.myPost.postId);
                              _postActionBloc.pushMyPostStream.listen((event) {
                                switch (event.status) {
                                  case Status.LOADING:
                                    break;
                                  case Status.COMPLETED:
                                    Fluttertoast.showToast(
                                        msg: event.data,
                                        textColor: Colors.black87);
                                    Navigator.pop(context);
                                    break;
                                  case Status.ERROR:
                                    Fluttertoast.showToast(
                                        msg: event.message,
                                        textColor: Colors.black87);
                                    Navigator.pop(context);
                                    break;
                                }
                              });
                            });
                          } else {
                            Helper.showMissingDialog(context, "Không thể làm mới",
                                "Tin của bạn cần phải được duyệt trước khi làm mới");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
        child: Stack(
          children: <Widget>[
            Positioned(
              child: ClipPath(
                clipper: CustomBannerStatus(),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                      color: checkingStatus(),
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(12))),
                  //color: checkingStatus(),
                  height: 50,
                  width: 50,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.black12, borderRadius: BorderRadius.circular(12)),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Text(
                                  widget.myPost.title ?? "",
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Text(
                                  widget.myPost.description ?? "",
                                  maxLines: 3,
                                  style: TextStyle(fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Spacer(),
                              Text(
                                widget.myPost.approvedDate,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Spacer(),
                          Container(
                            width: 100,
                            height: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: widget.myPost.thumbnail ?? "",
                                errorWidget: (context, url, error) =>
                                    Image.asset("assets/images/error.png"),
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    widget.index == 0 ? SizedBox(height: 4) : Container(),
                    widget.index == 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.keyboard_backspace,
                                size: 18,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                "Vuốt ngang để chỉnh sửa",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          )
                        : Container()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
