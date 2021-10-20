import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/partner_module/models/p_notify_reponse.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';

import 'notify_partner_detail_page.dart';
import 'p_notify_bloc.dart';

class NotifyPartnerPage extends StatefulWidget {
  static const ROUTE_NAME = '/notify-partner';

  @override
  _NotifyPartnerPageState createState() => _NotifyPartnerPageState();
}

class _NotifyPartnerPageState extends State<NotifyPartnerPage> {
  PNotifyBloc _notifyBloc = PNotifyBloc();
  ScrollController _scrollController;
  bool _shouldLoadMore = true;
  int _currentPage = 1;
  List<PNotifyLite> notifyList = List<PNotifyLite>();

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController()..addListener(_scrollListener);
    _notifyBloc.requestGetNotify(_currentPage);
    _currentPage = 2;
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 250) {
      if (_shouldLoadMore) {
        _shouldLoadMore = false;
        _notifyBloc.requestGetNotify(_currentPage);
        setState(() {
          _currentPage++;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _notifyBloc.dispose();
    notifyList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Thông báo"),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(1);
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
        ),
        body: Container(
            padding: EdgeInsets.all(8),
            child: StreamBuilder<ApiResponse<List<PNotifyLite>>>(
                stream: _notifyBloc.notifyStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return UILoading(loadingMessage: snapshot.data.message);
                      case Status.COMPLETED:
                        if (snapshot.data.data.length > 0) {
                          print(
                              "at UI: " + snapshot.data.data.length.toString());
                          notifyList.addAll(snapshot.data.data);
                          _shouldLoadMore = true;
                        } else {
                          _shouldLoadMore = false;
                        }
                        if (notifyList.length > 0) {
                          return ListView.builder(
                              controller: _scrollController,
                              itemCount: notifyList.length,
                              itemBuilder: (context, index) {
                                final document =
                                    parse(notifyList[index].description ?? "");
                                final String parsedString =
                                    parse(document.body.text)
                                        .documentElement
                                        .text;
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        NotifyPartnerDetailPage.ROUTE_NAME,
                                        arguments: notifyList[index].postId);
                                  },
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 4,
                                    margin: EdgeInsets.symmetric(vertical: 2),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(notifyList[index].title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          SizedBox(height: 4),
                                          Text(
                                            parsedString ?? "",
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Text(
                                                  notifyList[index]
                                                      .approvedDate,
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                              Spacer(),
                                              Text("Thông báo"),
                                              SizedBox(width: 6),
                                              Text(
                                                notifyList[index]
                                                    .notificationCount
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              SizedBox(
                                                width: 6,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        }
                        return Center(
                            child: Text(
                          "Chưa có bài đăng nào",
                          style: TextStyle(fontSize: 18),
                        ));
                      case Status.ERROR:
                        return UIError(errorMessage: snapshot.data.message);
                    }
                  }
                  return Center(
                      child: Text(
                    "Chưa có bài đăng nào",
                    style: TextStyle(fontSize: 18),
                  ));
                })),
      ),
    );
  }
}
