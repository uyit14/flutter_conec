import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/notify/notify_response.dart';
import 'package:conecapp/ui/home/pages/item_detail_page.dart';
import 'package:conecapp/ui/news/pages/news_detail_page.dart';
import 'package:conecapp/ui/news/pages/sell_detail_page.dart';
import 'package:conecapp/ui/notify/blocs/notify_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotifyDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/notify-detail';

  @override
  _NotifyDetailPageState createState() => _NotifyDetailPageState();
}

class _NotifyDetailPageState extends State<NotifyDetailPage> {
  Notify _notify;
  NotifyBloc _notifyBloc = NotifyBloc();
  bool _apiCall = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context).settings.arguments;
    _notify = routeArgs;
    if (_notify != null && !_notify.read && _apiCall) {
      _notifyBloc.requestDeleteOrRead(_notify.id, "MarkAsRead");
      _apiCall = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(1);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(1);
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: Text("Thông báo"),
          actions: [
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () {
                _notifyBloc.requestDeleteOrRead(_notify.id, "Remove");
                Navigator.of(context).pop(1);
              },
            ),
            SizedBox(
              width: 12,
            )
          ],
        ),
        body: Card(
          elevation: 4,
          margin: EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(_notify.title,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Html(data:_notify.content),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(_notify.createdDate,
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                    Spacer(),
                    _notify.topicId != null ? FlatButton(
                        onPressed: () {
                          if(_notify.content.contains("từ chối")){
                            Fluttertoast.showToast(msg: "Tin của bạn chưa được phê duyệt");
                          }else{
                            if (_notify.topicId != null) {
                              if (_notify.topicId ==
                                  "333f691d-6595-443d-bae3-9a2681025b53") {
                                Navigator.of(context).pushNamed(
                                    NewsDetailPage.ROUTE_NAME,
                                    arguments: {
                                      'postId': _notify.typeId,
                                    });
                              } else if (_notify.topicId ==
                                  "333f691d-6585-443a-bae3-9a2681025b53") {
                                Navigator.of(context).pushNamed(
                                    SellDetailPage.ROUTE_NAME,
                                    arguments: {
                                      'postId': _notify.typeId,
                                    });
                              } else {
                                Navigator.of(context).pushNamed(
                                    ItemDetailPage.ROUTE_NAME,
                                    arguments: {
                                      'postId': _notify.typeId,
                                      'title': ""
                                    });
                              }
                            }
                          }

                        },
                        child: Text(
                          "Xem Tin",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )): Container()
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
