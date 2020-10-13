import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/news_detail.dart';
import 'package:conecapp/ui/news/blocs/news_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share/share.dart';
import 'package:conecapp/models/response/image.dart' as myImage;

class NewsDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/news-detail';

  @override
  _NewsDetailPageState createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  String postId;
  String linkShare;
  int _currentIndex = 0;
  NewsBloc _newsBloc = NewsBloc();
  bool _setBanners = true;
  PageController _pageController = PageController(initialPage: 0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    postId = routeArgs['postId'];
    _newsBloc.requestNewsDetail(postId);
  }

  void autoPlayBanners(List<myImage.Image> images) {
    if (images.length > 1) {
      Timer.periodic(Duration(seconds: 2), (Timer timer) {
        if (_currentIndex == images.length) {
          _currentIndex = 0;
        } else {
          _currentIndex++;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentIndex,
            duration: Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        }
      });
    }
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
                Share.share(linkShare ?? Helper.applicationUrl());
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
                    linkShare = newsDetail.shareLink;
                    if (newsDetail.images.length > 0 && _setBanners) {
                      autoPlayBanners(newsDetail.images);
                      _setBanners = false;
                    }
                    return SingleChildScrollView(
                        child: Card(
                      margin: EdgeInsets.all(0),
                      child: Column(
                        children: <Widget>[
                          Hero(
                            tag: postId,
                            child: newsDetail.images.length > 0
                                ? Stack(
                              children: [
                                Container(
                                  height: 225,
                                  child: PageView.builder(
                                      itemCount: newsDetail.images.length,
                                      controller: _pageController,
                                      onPageChanged: (currentPage) {
                                        setState(() {
                                          _currentIndex = currentPage;
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        return CachedNetworkImage(
                                          imageUrl: newsDetail
                                              .images[index].fileName,
                                          placeholder: (context, url) =>
                                              Image.asset(
                                                  "assets/images/placeholder.png"),
                                          errorWidget: (context, url,
                                              error) =>
                                              Image.asset(
                                                  "assets/images/error.png"),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 225,
                                        );
                                      }),
                                ),
                                Positioned(
                                  bottom: 24,
                                  child: Container(
                                    height: 24,
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount:
                                          newsDetail.images.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              width: 16,
                                              height: 16,
                                              margin:
                                              EdgeInsets.only(right: 6),
                                              decoration: BoxDecoration(
                                                //borderRadius: BorderRadius.all(Radius.circular(16)),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.white),
                                                  color: _currentIndex ==
                                                      index
                                                      ? Colors.white
                                                      : Colors.transparent),
                                            );
                                          }),
                                    ),
                                  ),
                                )
                              ],
                            )
                                : CachedNetworkImage(
                              imageUrl: newsDetail.thumbnail,
                              placeholder: (context, url) => Image.asset(
                                  "assets/images/placeholder.png"),
                              errorWidget: (context, url, error) =>
                                  Image.asset("assets/images/error.png"),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 225,
                            ),
                          ),
                          // if (newsDetail.images.length > 0)
                          //   Container(
                          //     height: 55,
                          //     margin: EdgeInsets.only(top: 4),
                          //     child: Center(
                          //       child: ListView.builder(
                          //           shrinkWrap: true,
                          //           scrollDirection: Axis.horizontal,
                          //           itemCount: newsDetail.images.length,
                          //           itemBuilder: (context, index) {
                          //             return InkWell(
                          //               onTap: () {
                          //                 setState(() {
                          //                   _currentIndex = index;
                          //                 });
                          //                 if (_pageController.hasClients) {
                          //                   _pageController.animateToPage(
                          //                     index,
                          //                     duration:
                          //                     Duration(milliseconds: 350),
                          //                     curve: Curves.easeIn,
                          //                   );
                          //                 }
                          //               },
                          //               child: Container(
                          //                 decoration: _currentIndex == index
                          //                     ? BoxDecoration(
                          //                   border: Border.all(
                          //                       width: 2,
                          //                       color: Colors.green),
                          //                   borderRadius:
                          //                   BorderRadius.all(
                          //                       Radius.circular(8)),
                          //                 )
                          //                     : null,
                          //                 margin: EdgeInsets.only(right: 2),
                          //                 child: ClipRRect(
                          //                   borderRadius: BorderRadius.all(
                          //                       Radius.circular(6)),
                          //                   child: CachedNetworkImage(
                          //                     imageUrl: newsDetail
                          //                         .images[index].fileName,
                          //                     placeholder: (context, url) =>
                          //                         Image.asset(
                          //                             "assets/images/placeholder.png"),
                          //                     errorWidget: (context, url,
                          //                         error) =>
                          //                         Image.asset(
                          //                             "assets/images/error.png"),
                          //                     fit: BoxFit.cover,
                          //                     width: 55,
                          //                     height: 55,
                          //                   ),
                          //                 ),
                          //               ),
                          //             );
                          //           }),
                          //     ),
                          //   )
                          // else
                          //   Container(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(newsDetail.title, style: AppTheme.title),
                                Text(newsDetail.approvedDate,
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
