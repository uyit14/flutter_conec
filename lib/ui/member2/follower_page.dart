import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/member2/follower2_response.dart';
import 'package:conecapp/ui/home/pages/item_detail_page.dart';
import 'package:flutter/material.dart';

import 'member2_bloc.dart';

class FollowerPage extends StatefulWidget {
  @override
  _FollowerPageState createState() => _FollowerPageState();
}

class _FollowerPageState extends State<FollowerPage> {
  Member2Bloc _member2bloc = Member2Bloc();
  ScrollController _scrollController;
  bool _shouldLoadMore = true;
  int _currentPage = 1;
  List<Follower2> follower2List = List<Follower2>();

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController()..addListener(_scrollListener);
    _member2bloc.requestGetFollower2(_currentPage);
    _currentPage = 2;
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 250) {
      if (_shouldLoadMore) {
        _shouldLoadMore = false;
        _member2bloc.requestGetFollower2(_currentPage);
        setState(() {
          _currentPage++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder<ApiResponse<List<Follower2>>>(
            stream: _member2bloc.follower2Stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    return UILoading(loadingMessage: snapshot.data.message);
                  case Status.COMPLETED:
                    if (snapshot.data.data.length > 0) {
                      print("at UI: " + snapshot.data.data.length.toString());
                      follower2List.addAll(snapshot.data.data);
                      _shouldLoadMore = true;
                    } else {
                      _shouldLoadMore = false;
                    }
                    if (follower2List.length > 0) {
                      return ListView.builder(
                          controller: _scrollController,
                          itemCount: follower2List.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    ItemDetailPage.ROUTE_NAME,
                                    arguments: {
                                      'postId': follower2List[index].postId,
                                      'title': follower2List[index].title
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
                                              imageUrl: follower2List[index]
                                                  .thumbnail,
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
                                              follower2List[index].title,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  'Đã theo dõi: ',
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
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 2,
                                                      vertical: 1),
                                                  child: Text(
                                                    follower2List[index]
                                                        .followedDate
                                                        .replaceAll("một", "1"),
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
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 2, vertical: 1),
                                              child: Text(
                                                '${follower2List[index].likeCount} Theo dõi',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              follower2List[index].getAddress,
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
