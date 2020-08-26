import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/news_detail.dart';
import 'package:conecapp/ui/news/blocs/news_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share/share.dart';

class NewsDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/news-detail';

  @override
  _NewsDetailPageState createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  String postId;
  NewsBloc _newsBloc = NewsBloc();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    postId = routeArgs['postId'];
    _newsBloc.requestNewsDetail(postId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Tin Tức",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black, size: 26),
          elevation: 0,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Share.share('check out my website https://example.com');
              },
              icon: Icon(
                Icons.share,
                color: Colors.red,
              ),
            ),
            IconButton(
              onPressed: () {
                //TODO - report
              },
              icon: Icon(
                Icons.report,
                color: Colors.red,
              ),
            ),
          ],
        ),
        body: StreamBuilder<ApiResponse<NewsDetail>>(
            stream: _newsBloc.newsDetailStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    return UILoading(loadingMessage: snapshot.data.message);
                  case Status.COMPLETED:
                    NewsDetail newsDetail = snapshot.data.data;
                    return SingleChildScrollView(
                        child: Card(
                      margin: EdgeInsets.all(0),
                      child: Column(
                        children: <Widget>[
                          Hero(
                            tag: postId,
                            child: CachedNetworkImage(
                              imageUrl: newsDetail.thumbnail,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  Image.asset("assets/images/error.png"),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 250,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(newsDetail.title, style: AppTheme.title),
                                Text(newsDetail.publishedDate,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.grey)),
                                SizedBox(height: 8),
                                Html(
                                  data: newsDetail.content,
                                )
//                                Text(
//                                  newsDetail.content,
//                                  style: TextStyle(fontSize: 16),
//                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ));
                  case Status.ERROR:
                    return UIError(
                        errorMessage: snapshot.data.message,
                        onRetryPressed: () =>
                            _newsBloc.requestNewsDetail(postId));
                }
              }
              return Container(child: Text("Không có dữ liệu, kiểm tra lại kết nối internet của bạn"));
            }),
      ),
    );
  }
}
