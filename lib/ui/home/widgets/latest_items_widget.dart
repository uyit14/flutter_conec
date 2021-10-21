import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/latest_item.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:conecapp/ui/home/pages/item_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';

class LatestItemsWidget extends StatefulWidget {
  @override
  _LatestItemsWidgetState createState() => _LatestItemsWidgetState();
}

class _LatestItemsWidgetState extends State<LatestItemsWidget> {
  HomeBloc _homeBloc = HomeBloc();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeBloc.requestGetLatestItem();
  }

  @override
  void dispose() {
    super.dispose();
    _homeBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<ApiResponse<List<LatestItem>>>(
          stream: _homeBloc.latestItemStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return UILoading(loadingMessage: snapshot.data.message);
                case Status.COMPLETED:
                  List<LatestItem> items = snapshot.data.data;
                  return GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 6),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemBuilder: (_, index) {
                        final document = parse(items[index].description ?? "");
                        final String parsedString = parse(document.body.text).documentElement.text;
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                ItemDetailPage.ROUTE_NAME,
                                arguments: {
                                  'postId': items[index].postId,
                                  'title': items[index].title
                                });
                          },
                          child: Container(
                            margin: EdgeInsets.all(4),
                            child: Stack(
                              children: <Widget>[
                                // Banner(
                                //   message: "Mới",
                                //   location: BannerLocation.topEnd,
                                //   color: Colors.green,
                                //   child: ClipRRect(
                                //     borderRadius: BorderRadius.circular(15),
                                //     child: Hero(
                                //       tag: items[index].postId,
                                //       child: CachedNetworkImage(
                                //         imageUrl: items[index].thumbnail ?? "",
                                //         placeholder: (context, url) =>
                                //             Image.asset(
                                //                 "assets/images/placeholder.png",
                                //               fit: BoxFit.cover,
                                //               width: double.infinity,
                                //               height: double.infinity),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Hero(
                                    tag: items[index].postId,
                                    child: CachedNetworkImage(
                                      imageUrl: items[index].thumbnail ?? "",
                                      placeholder: (context, url) =>
                                          Image.asset(
                                              "assets/images/placeholder.png",
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 6),
                                    decoration: BoxDecoration(
                                        color:
                                            Color(0xFF0E3311).withOpacity(0.5),
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15))),
                                    height: 75,
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          items[index].title,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // Html(
                                        //   data: items[index].description ?? "",
                                        //   style: {
                                        //     "p": Style(fontSize: FontSize.medium,
                                        //         color: Colors.white),
                                        //   },
                                        // )
                                        Container(
                                          width: double.infinity,
                                          height: 30,
                                          child: Text(
                                            parsedString ?? "",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                case Status.ERROR:
                  return UIError(
                      errorMessage: snapshot.data.message,
                      onRetryPressed: () => _homeBloc.requestGetLatestItem());
              }
            }
            return Center(child: Text("Không có dữ liệu, kiểm tra lại kết nối internet của bạn"));
          }),
    );
  }
}
