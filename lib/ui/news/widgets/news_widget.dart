import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/news.dart';
import 'package:conecapp/ui/news/blocs/news_bloc.dart';
import 'package:conecapp/ui/news/pages/news_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsWidget extends StatefulWidget {
  @override
  _NewsWidgetState createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget> {
  NewsBloc _newsBloc = NewsBloc();

  TextEditingController _searchController = TextEditingController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _newsBloc.requestGetAllNews();
  }

  @override
  void dispose() {
    _newsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22))),
            padding: EdgeInsets.only(left: 18, right: 18, bottom: 8),
            width: double.infinity,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black12,
                    ),
                    height: 40,
                    child: TextFormField(
                      maxLines: 1,
                      onChanged: (value){
                        _newsBloc.searchAction(value);
                      },
                      controller: _searchController,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                          hintText: 'Nhập thông tin bạn muốn tìm kiếm',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: EdgeInsets.only(left: 8)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  child: Text("Hủy", style: AppTheme.changeTextStyle(true)),
                  onTap: () {
                    _newsBloc.clearSearch();
                    _searchController.clear();
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<ApiResponse<List<News>>>(
                stream: _newsBloc.allNewsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return UILoading(loadingMessage: snapshot.data.message);
                      case Status.COMPLETED:
                        List<News> news = snapshot.data.data;
                        print("at UI: " + news.length.toString());
                        return ListView.builder(
                            itemCount: news.length,
                            itemBuilder: (context, index) {
                              return ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: 180, maxHeight: 180),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                    progressIndicatorBuilder: (context,
                                                            url,
                                                            downloadProgress) =>
                                                        CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        Image.asset(
                                                            "assets/images/error.png"),
                                                    fit: BoxFit.cover,
                                                    height: 100,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Flexible(
                                                flex: 6,
                                                child: Text(
                                                  news[index].description ?? "",
                                                  maxLines: 3,
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          ),
                                          Container(
                                            child: Text(
                                              news[index].publishedDate,
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
                            });
                      case Status.ERROR:
                        return UIError(
                            errorMessage: snapshot.data.message,
                            onRetryPressed: () =>
                                _newsBloc.requestGetAllNews());
                    }
                  }
                  return Container(
                      child: Text(
                          "Không có dữ liệu, kiểm tra lại kết nối internet của bạn"));
                }),
          )
        ],
      ),
    );
  }
}
