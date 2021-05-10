import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/news.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:conecapp/ui/news/pages/news_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';

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
    _homeBloc.startNews();
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
                        final document = parse(news[index].description ?? "");
                        final String parsedString = parse(document.body.text).documentElement.text;
                        return ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: 180, maxHeight: 183),
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
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                      "assets/images/placeholder.png",
                                                      width: 100,
                                                      height: 100),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Flexible(
                                          flex: 6,
                                          child: Text(
                                            parsedString ?? "",
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
                    onRetryPressed: () => _homeBloc.startNews());
            }
          }
          return UILoading(loadingMessage: "Đang tải");
        });
  }
}
