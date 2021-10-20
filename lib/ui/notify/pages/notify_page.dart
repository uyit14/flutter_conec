import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/notify/notify_response.dart';
import 'package:conecapp/repositories/home/home_remote_repository.dart';
import 'package:conecapp/ui/home/pages/introduce_page.dart';
import 'package:conecapp/ui/home/pages/item_detail_page.dart';
import 'package:conecapp/ui/member2/member2_detail_page.dart';
import 'package:conecapp/ui/member2/member3_detail_page.dart';
import 'package:conecapp/ui/news/pages/news_detail_page.dart';
import 'package:conecapp/ui/news/pages/sell_detail_page.dart';
import 'package:conecapp/ui/notify/blocs/notify_bloc.dart';
import 'package:conecapp/ui/notify/pages/notify_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart';

class NotifyPage extends StatefulWidget {
  static const ROUTE_NAME = '/notify';

  @override
  _NotifyPageState createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {
  NotifyBloc _notifyBloc = NotifyBloc();
  ScrollController _scrollController;
  bool _shouldLoadMore = true;
  int _currentPage = 1;
  List<Notify> notifyList = List<Notify>();

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final data = ModalRoute.of(context).settings.arguments;
    // if (data != null &&
    //     data == "open_notify" &&
    //     notifyList != null &&
    //     notifyList.length > 0) {
    //   print('at index 0 :' + notifyList[0].read.toString());
    //   notifyList[0].read = true;
    //   Navigator.of(context)
    //       .pushNamed(NotifyDetailPage.ROUTE_NAME, arguments: notifyList[0])
    //       .then((value) {
    //     if (value == 1) {
    //       _notifyBloc.requestGetNotify(1);
    //       notifyList.clear();
    //     }
    //   });
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _notifyBloc.dispose();
    notifyList.clear();
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
            color: Colors.black26,
            padding: EdgeInsets.all(8),
            child: StreamBuilder<ApiResponse<List<Notify>>>(
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
                                    parse(notifyList[index].content ?? "");
                                final String parsedString =
                                    parse(document.body.text)
                                        .documentElement
                                        .text;
                                return InkWell(
                                  onTap: () async {
                                    print('at index $index :' +
                                        notifyList[index].read.toString());
                                    notifyList[index].read = true;
                                    if (notifyList[index].openType ==
                                            "DETAIL" &&
                                        notifyList[index].type ==
                                            "USER_MEMBER") {
                                      HomeRemoteRepository _repository =
                                          HomeRemoteRepository();
                                      final result =
                                          await _repository.fetMember3Detail(
                                              notifyList[index].typeId);
                                      if (result.status == false) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Yêu cầu này đã được chấp nhận hoặc đã bị hủy",
                                            gravity: ToastGravity.CENTER);
                                      } else {
                                        Navigator.of(context).pushNamed(
                                            Member3DetailPage.ROUTE_NAME,
                                            arguments: {
                                              'id': notifyList[index].typeId,
                                              'title': ""
                                            });
                                      }
                                    } else {
                                      Navigator.of(context)
                                          .pushNamed(
                                              NotifyDetailPage.ROUTE_NAME,
                                              arguments: notifyList[index])
                                          .then((value) {
                                        if (value == 1) {
                                          _notifyBloc.requestGetNotify(1);
                                          notifyList.clear();
                                        }
                                      });
                                    }
                                  },
                                  child: Card(
                                    color: notifyList[index].read
                                        ? Colors.white70
                                        : Colors.white,
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
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(notifyList[index].createdDate,
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        }
                        return Center(
                            child: Text(
                          "Chưa có thông báo",
                          style: TextStyle(fontSize: 18),
                        ));
                      case Status.ERROR:
                        return UIError(errorMessage: snapshot.data.message);
                    }
                  }
                  return Center(
                      child: Text(
                    "Chưa có thông báo",
                    style: TextStyle(fontSize: 18),
                  ));
                })),
      ),
    );
  }
}
