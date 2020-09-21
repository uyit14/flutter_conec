import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/nearby_response.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:flutter/material.dart';
import '../../../common/globals.dart' as globals;

import 'item_detail_page.dart';

class NearByPage extends StatefulWidget {
  static const ROUTE_NAME = '/nearby';

  @override
  _NearByPageState createState() => _NearByPageState();
}

class _NearByPageState extends State<NearByPage> {
  HomeBloc _homeBloc = HomeBloc();

  @override
  void initState() {
    super.initState();
    _homeBloc.requestGetNearBy(globals.latitude, globals.longitude, 5);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Gần tôi"),
        ),
        body: Container(
          child: StreamBuilder<ApiResponse<NearbyResponse>>(
              stream: _homeBloc.nearByStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  switch (snapshot.data.status) {
                    case Status.LOADING:
                      return UILoading(loadingMessage: snapshot.data.message);
                    case Status.COMPLETED:
                      List<Posts> postItem = snapshot.data.data.data.posts;
                      if(postItem.length > 0){
                        return ListView.builder(
                            itemCount: postItem.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      ItemDetailPage.ROUTE_NAME,
                                      arguments: {
                                        'postId': postItem[index].postId,
                                        'title': postItem[index].title
                                      });
                                },
                                child: Card(
                                  margin: EdgeInsets.all(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          postItem[index].title ?? "",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                                flex: 4,
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(6),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                    postItem[index].thumbnail,
                                                    progressIndicatorBuilder: (context,
                                                        url,
                                                        downloadProgress) =>
                                                        CircularProgressIndicator(
                                                            value:
                                                            downloadProgress
                                                                .progress),
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
                                            SizedBox(width: 6),
                                            Flexible(
                                              flex: 6,
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    postItem[index]
                                                        .description
                                                        .trim()
                                                        .length >
                                                        0
                                                        ? postItem[index]
                                                        .description
                                                        : "Liên hệ để biết thêm chi tiết",
                                                    maxLines: 3,
                                                    style: TextStyle(fontSize: 16),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    postItem[index].joiningFee !=
                                                        null
                                                        ? '${Helper.formatCurrency(postItem[index].joiningFee)} VND'
                                                        : "Liên hệ",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                                  2,
                                              child: Text(
                                                '${postItem[index].district} - ${postItem[index].province}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(postItem[index].approvedDate,
                                                style: TextStyle(
                                                    fontStyle: FontStyle.italic))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      }
                        return Container(child: Center(child: Text("Không có câu lạc bộ nào gần đây!")));
                    case Status.ERROR:
                      return UIError(errorMessage: snapshot.data.message);
                  }
                }
                return Container(child: Center(child: Text("Không có câu lạc bộ nào gần đây!")));
              }),
        ),
      ),
    );
  }
}