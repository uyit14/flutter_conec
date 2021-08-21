import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/member2/member2_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'member2_bloc.dart';
import 'member2_detail_page.dart';

class Member2Page extends StatefulWidget {
  @override
  _Member2PageState createState() => _Member2PageState();
}

class _Member2PageState extends State<Member2Page> {
  Member2Bloc _member2bloc = Member2Bloc();
  ScrollController _scrollController;
  bool _shouldLoadMore = true;
  int _currentPage = 1;
  List<Member2> member2List = List<Member2>();

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController()..addListener(_scrollListener);
    _member2bloc.requestGetMember2(_currentPage);
    _currentPage = 2;
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 250) {
      if (_shouldLoadMore) {
        _shouldLoadMore = false;
        _member2bloc.requestGetMember2(_currentPage);
        setState(() {
          _currentPage++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder<ApiResponse<List<Member2>>>(
            stream: _member2bloc.member2Stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    return UILoading(loadingMessage: snapshot.data.message);
                  case Status.COMPLETED:
                    if (snapshot.data.data.length > 0) {
                      print("at UI: " + snapshot.data.data.length.toString());
                      member2List.addAll(snapshot.data.data);
                      _shouldLoadMore = true;
                    } else {
                      _shouldLoadMore = false;
                    }
                    if (member2List.length > 0) {
                      return ListView.builder(
                          controller: _scrollController,
                          itemCount: member2List.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).pushNamed(Member2DetailPage.ROUTE_NAME,
                                    arguments: {
                                      'id': member2List[index].id,
                                      'title': member2List[index].title,
                                    });
                              },
                              child: Card(
                                margin: EdgeInsets.symmetric(vertical: 2),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Flexible(
                                          flex: 4,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  member2List[index].thumbnail,
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                      "assets/images/placeholder.png",
                                                      width: 100,
                                                      height: 120),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                "assets/images/error.png",
                                                height: 100,
                                                width: 120,
                                              ),
                                              fit: BoxFit.cover,
                                              height: 100,
                                              width: 120,
                                            ),
                                          )),
                                      SizedBox(width: 8),
                                      Flexible(
                                        flex: 6,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              member2List[index].title,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  'Đã tham gia: ',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    color: Colors.blueAccent,
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                                  child: Text(
                                                    member2List[index]
                                                        .followedDate.replaceAll("một", "1"),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: Colors.green,
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                              child: Text(
                                                member2List[index]
                                                            .group
                                                            .length >
                                                        0
                                                    ? member2List[index].group
                                                    : "Chưa phân nhóm",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              member2List[index].getAddress,
                                              style: TextStyle(fontSize: 14),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    }
                    return Center(
                        child: Text(
                      "Chưa có thành viên",
                      style: TextStyle(fontSize: 18),
                    ));
                  case Status.ERROR:
                    return UIError(errorMessage: snapshot.data.message);
                }
              }
              return Center(
                  child: Text(
                "Chưa có thành viên",
                style: TextStyle(fontSize: 18),
              ));
            }));
  }
}
