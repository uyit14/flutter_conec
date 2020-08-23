import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/sport.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:conecapp/ui/news/pages/sell_detail_page.dart';
import 'package:flutter/material.dart';

//ads
class NewSportWidget extends StatefulWidget {
  @override
  _NewSportWidgetState createState() => _NewSportWidgetState();
}

class _NewSportWidgetState extends State<NewSportWidget> {
  HomeBloc _homeBloc = HomeBloc();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeBloc.requestGetSport();
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = MediaQuery.of(context).size.width * 0.2;
    return StreamBuilder<ApiResponse<List<Sport>>>(
        stream: _homeBloc.sportStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data.status) {
              case Status.LOADING:
                return UILoading(loadingMessage: snapshot.data.message);
              case Status.COMPLETED:
                List<Sport> sports = snapshot.data.data;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: sports.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                SellDetailPage.ROUTE_NAME,
                                arguments: {
                                  'postId': sports[index].postId,
                                });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Hero(
                                    tag: sports[index].postId,
                                    child: CachedNetworkImage(
                                      imageUrl: sports[index].thumbnail,
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                      errorWidget: (context, url, error) =>
                                          Image.asset("assets/images/error.png",
                                              width: imageSize,
                                              height: imageSize),
                                      fit: BoxFit.cover,
                                      width: imageSize,
                                      height: imageSize,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                    child: Container(
                                  height: imageSize,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        sports[index].title,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${Helper.formatCurrency(sports[index].price ?? 0)} VND',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.red),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Spacer(),
                                      Text(
                                        sports[index].description ?? "",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                )),
                                SizedBox(width: 10),
                                Container(
                                    child: Center(
                                        child: Icon(
                                      Icons.navigate_next,
                                      size: 30,
                                      color: Colors.red,
                                    )),
                                    height: imageSize)
                              ],
                            ),
                          ),
                        );
                      }),
                );
              case Status.ERROR:
                return UIError(
                    errorMessage: snapshot.data.message,
                    onRetryPressed: () => _homeBloc.requestGetSport());
            }
          }
          return Center(
              child: Text(
                  "Không có dữ liệu, kiểm tra lại kết nối internet của bạn"));
        });
  }
}
