import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/news.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:conecapp/ui/news/pages/news_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//news
class NewProductWidget extends StatefulWidget {
  @override
  _NewProductWidgetState createState() => _NewProductWidgetState();
}

class _NewProductWidgetState extends State<NewProductWidget> {
  HomeBloc _homeBloc = HomeBloc();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeBloc.requestGetNews();
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = MediaQuery.of(context).size.width * 0.2;
    return StreamBuilder<ApiResponse<List<News>>>(
        stream: _homeBloc.newsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data.status) {
              case Status.LOADING:
                return UILoading(loadingMessage: snapshot.data.message);
              case Status.COMPLETED:
                List<News> news = snapshot.data.data;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        return ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: 180, maxHeight: 180),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  NewsDetailPage.ROUTE_NAME,
                                  arguments: {
                                    'postId': news[index].postId,
                                  });
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      news[index].title,
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
                                            tag: news[index].postId,
                                            child: CachedNetworkImage(
                                              imageUrl: news[index].thumbnail,
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Image.asset(
                                                      "assets/images/error.png", height: 100, width: 120,),
                                              fit: BoxFit.cover,
                                              height: 100,
                                              width: 120,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Flexible(
                                          flex: 6,
                                          child: Text(
                                            news[index].description ?? "",
                                            maxLines: 3,
                                            style: TextStyle(fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      child: Text(
                                        news[index].approvedDate,
                                        textAlign: TextAlign.end,
                                      ),
                                      width: double.infinity,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                );
              case Status.ERROR:
                return UIError(
                    errorMessage: snapshot.data.message,
                    onRetryPressed: () => _homeBloc.requestGetNews());
            }
          }
          return Container(
              child: Text(
                  "Không có dữ liệu, kiểm tra lại kết nối internet của bạn"));
        });
  }
}
