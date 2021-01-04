import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/latest_item.dart';
import 'package:conecapp/models/response/nearby_response.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:flutter/material.dart';
import '../../../common/globals.dart' as globals;
import 'item_detail_page.dart';
import 'package:html/parser.dart';

class TrainerPostPage extends StatefulWidget {

  @override
  _TrainerPostPageState createState() => _TrainerPostPageState();
}

class _TrainerPostPageState extends State<TrainerPostPage> {
  HomeBloc _homeBloc = HomeBloc();

  @override
  void initState() {
    super.initState();
    _homeBloc.requestGetNearBy(globals.latitude, globals.longitude, 50);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<ApiResponse<NearbyResponse>>(
          stream: _homeBloc.nearByStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return UILoading(loadingMessage: snapshot.data.message);
                case Status.COMPLETED:
                  List<LatestItem> latestItem = snapshot.data.data.data.trainerPosts;
                  if(latestItem.length > 0){
                    return ListView.builder(
                        itemCount: latestItem.length,
                        itemBuilder: (context, index) {
                          final document = parse(latestItem[index].description ?? "");
                          final String parsedString = parse(document.body.text).documentElement.text;
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  ItemDetailPage.ROUTE_NAME,
                                  arguments: {
                                    'postId': latestItem[index].postId,
                                    'title': latestItem[index].title
                                  });
                            },
                            child: Card(
                              margin: EdgeInsets.all(8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      latestItem[index].title,
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
                                            child: Hero(
                                              tag: latestItem[index]
                                                  .postId,
                                              child: ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    6),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                  latestItem[index]
                                                      .thumbnail,
                                                  placeholder: (context,
                                                      url) =>
                                                      Image.asset(
                                                          "assets/images/placeholder.png",
                                                          width: 100,
                                                          height: 100),
                                                  errorWidget: (context,
                                                      url, error) =>
                                                      Image.asset(
                                                        "assets/images/error.png",
                                                        height: 100,
                                                        width: 100,
                                                      ),
                                                  fit: BoxFit.contain,
                                                  height: 100,
                                                  width: 100,
                                                ),
                                              ),
                                            )),
                                        SizedBox(width: 6),
                                        Flexible(
                                          flex: 7,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                parsedString ??
                                                    "",
                                                maxLines: 2,
                                                style:
                                                TextStyle(fontSize: 16),
                                                overflow:
                                                TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                latestItem[index]
                                                    .joiningFee !=
                                                    null && latestItem[index]
                                                    .joiningFee!=0
                                                    ? '${Helper.formatCurrency(latestItem[index].joiningFee)} VND / ${latestItem[index].joiningFeePeriod ?? ""}'
                                                    : "Liên hệ",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              SizedBox(height: 4,),
                                              Text(
                                                "Đăng bởi: ${latestItem[index].owner}",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
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
                                            "Cách đây: ${latestItem[index].distance.toInt()} km",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontStyle:
                                                FontStyle.italic,
                                                color: Colors.blue),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                            latestItem[index]
                                                .approvedDate,
                                            style: TextStyle(
                                                fontStyle:
                                                FontStyle.italic))
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  }
                  return Container(
                      child: Center(
                          child: Text("Không có huấn luyện viên nào gần đây!")));
                case Status.ERROR:
                  return UIError(errorMessage: snapshot.data.message);
              }
            }
            return Container(
                child: Center(child: Text("Không có huấn luyện viên nào gần đây!")));
          }),
    );
  }
}
