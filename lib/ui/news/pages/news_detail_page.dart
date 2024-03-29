import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/image.dart' as myImage;
import 'package:conecapp/models/response/news_detail.dart';
import 'package:conecapp/models/response/profile/gift_response.dart';
import 'package:conecapp/ui/home/pages/image_viewer_page.dart';
import 'package:conecapp/ui/home/pages/report_page.dart';
import 'package:conecapp/ui/mypost/blocs/post_action_bloc.dart';
import 'package:conecapp/ui/news/blocs/news_bloc.dart';
import 'package:conecapp/ui/news/widgets/ads_comment_widget.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NewsDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/news-detail';

  @override
  _NewsDetailPageState createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  String postId;
  String owner;
  String linkShare;

  bool isApprove = false;
  int _currentIndex = 0;
  NewsBloc _newsBloc = NewsBloc();
  PostActionBloc _postActionBloc = PostActionBloc();
  bool _setBanners = true;
  PageController _pageController = PageController(initialPage: 0);
  String _token;
  bool _isTokenExpired = true;
  ProfileBloc _profileBloc = ProfileBloc();

  void getToken() async {
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
    });
  }

  int pushNumber = 0;
  int postNumber = 0;

  void giftCheck() {
    _profileBloc.requestGetGiftResponse();
    _profileBloc.giftResponseStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
        case Status.COMPLETED:
          GiftResponse giftResponse = event.data;
          setState(() {
            pushNumber = giftResponse.remainPush;
            postNumber = giftResponse.remainPriority;
          });
          break;
          break;
        case Status.ERROR:
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getToken();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    postId = routeArgs['postId'];
    owner = routeArgs['owner'];
    _newsBloc.requestNewsDetail(postId);
    if(owner != null){
      giftCheck();
    }
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

  void doReload() {
    debugPrint("doReload");
    _newsBloc.requestAdsDetail(postId);
  }

  void showRemindDialog(BuildContext context) {
    if (pushNumber > 0) {
      final act = CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text('Đẩy tin lên đầu ($pushNumber)',
                  style: TextStyle(color: Colors.blue)),
              onPressed: () {
                requestPush(true, false);
                Navigator.pop(context);
              },
            ),
            // CupertinoActionSheetAction(
            //   child: Text('Ưu tiên tin',
            //       style: TextStyle(color: Colors.blue)),
            //   onPressed: () {
            //     requestPush(false, true);
            //     Navigator.pop(context);
            //   },
            // ),
            // CupertinoActionSheetAction(
            //   child: Text('Đẩy tin và ưu tiên',
            //       style: TextStyle(color: Colors.blue)),
            //   onPressed: () {
            //     requestPush(true, true);
            //     Navigator.pop(context);
            //   },
            // )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.pop(context);
            },
          ));
      showCupertinoModalPopup(
          context: context, builder: (BuildContext context) => act);
    } else {
      Fluttertoast.showToast(
          msg: "Bạn đã dùng hết lượt đẩy tin", textColor: Colors.black87);
    }
  }

  void requestPush(bool isPush, bool isPriority) {
    _postActionBloc.requestPushMyPost(postId,
        isPush: isPush, isPriority: isPriority);
    _postActionBloc.pushMyPostStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;
        case Status.COMPLETED:
          _profileBloc.requestGetGiftResponse();
          Helper.showMissingDialog(context, "Thành công", event.data ?? "");
          break;
        case Status.ERROR:
          Fluttertoast.showToast(msg: event.message, textColor: Colors.black87);
          Navigator.pop(context);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Bản tin",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black, size: 26),
          elevation: 0,
          centerTitle: true,
          actions: <Widget>[
            owner != null
                ? IconButton(
                    onPressed: () {
                      if (isApprove) {
                        showRemindDialog(context);
                      } else {
                        Helper.showMissingDialog(context, "Thông báo",
                            "Tin của bạn cần phải được duyệt trước khi làm mới");
                      }
                    },
                    icon: Icon(
                      Icons.publish,
                      color: Colors.orange,
                    ),
                  )
                : Container(),
            IconButton(
              onPressed: () {
                if (_token == null || _token.length == 0) {
                  Helper.showAuthenticationDialog(context);
                } else {
                  if (_isTokenExpired) {
                    Helper.showTokenExpiredDialog(context);
                  } else {
                    Navigator.of(context).pushNamed(ReportPage.ROUTE_NAME,
                        arguments: {'postId': postId});
                  }
                }
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
                    isApprove = newsDetail.status == "APPROVED";
                    // if (newsDetail.images.length > 0 && _setBanners) {
                    //   autoPlayBanners(newsDetail.images);
                    //   _setBanners = false;
                    // }
                    return SingleChildScrollView(
                        child: Card(
                      margin: EdgeInsets.all(0),
                      child: Column(
                        children: <Widget>[
                          InkWell(
                            onTap: (){
                              Navigator.of(context).push(PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (BuildContext context, _, __) =>
                                      ImageViewerPage(newsDetail.images, _currentIndex)));
                            },
                            child: Hero(
                              tag: postId,
                              child: newsDetail.images.length > 0
                                  ? Stack(
                                      children: [
                                        // Container(
                                        //   height: 225,
                                        //   child: PageView.builder(
                                        //       itemCount: newsDetail.images.length,
                                        //       controller: _pageController,
                                        //       onPageChanged: (currentPage) {
                                        //         setState(() {
                                        //           _currentIndex = currentPage;
                                        //         });
                                        //       },
                                        //       itemBuilder: (context, index) {
                                        //         return CachedNetworkImage(
                                        //           imageUrl: newsDetail
                                        //               .images[index].fileName,
                                        //           placeholder: (context, url) =>
                                        //               Image.asset(
                                        //                   "assets/images/placeholder.png"),
                                        //           errorWidget: (context, url,
                                        //               error) =>
                                        //               Image.asset(
                                        //                   "assets/images/error.png"),
                                        //           fit: BoxFit.cover,
                                        //           width: double.infinity,
                                        //           height: 225,
                                        //         );
                                        //       }),
                                        // ),
                                        CarouselSlider(
                                          options: CarouselOptions(
                                            onPageChanged: (currentPage, reason) {
                                              setState(() {
                                                _currentIndex = currentPage;
                                              });
                                            },
                                            height: Helper.isTablet(context)
                                                ? 320
                                                : 225,
                                            autoPlay: true,
                                            enlargeCenterPage: false,
                                            viewportFraction: 1.0,
                                          ),
                                          items: newsDetail.images
                                              .map((item) => Container(
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8)),
                                                        child: Stack(
                                                          children: <Widget>[
                                                            CachedNetworkImage(
                                                              imageUrl:
                                                                  item.fileName,
                                                              placeholder: (context,
                                                                      url) =>
                                                                  Image.asset(
                                                                      "assets/images/placeholder.png"),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Image.asset(
                                                                      "assets/images/error.png"),
                                                              fit: BoxFit.cover,
                                                              width:
                                                                  double.infinity,
                                                            ),
                                                            Positioned(
                                                              bottom: 0.0,
                                                              left: 0.0,
                                                              right: 0.0,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors: [
                                                                      Color
                                                                          .fromARGB(
                                                                              200,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                      Color
                                                                          .fromARGB(
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0)
                                                                    ],
                                                                    begin: Alignment
                                                                        .bottomCenter,
                                                                    end: Alignment
                                                                        .topCenter,
                                                                  ),
                                                                ),
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            10.0,
                                                                        horizontal:
                                                                            20.0),
//                                                child: Text(
//                                                  item.title,
//                                                  style: TextStyle(
//                                                    color: Colors.white,
//                                                    fontSize: 20.0,
//                                                    fontWeight: FontWeight.bold,
//                                                  ),
//                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                  ))
                                              .toList(),
                                        ),
                                        Positioned(
                                          bottom: 24,
                                          child: Container(
                                            height: 24,
                                            width:
                                                MediaQuery.of(context).size.width,
                                            child: Center(
                                              child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      newsDetail.images.length,
                                                  itemBuilder: (context, index) {
                                                    return Container(
                                                      width: 16,
                                                      height: 16,
                                                      margin: EdgeInsets.only(
                                                          right: 6),
                                                      decoration: BoxDecoration(
                                                          //borderRadius: BorderRadius.all(Radius.circular(16)),
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                              width: 1,
                                                              color:
                                                                  Colors.white),
                                                          color: _currentIndex ==
                                                                  index
                                                              ? Colors.white
                                                              : Colors
                                                                  .transparent),
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
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: newsDetail.content.contains("<")
                                      ? Html(
                                          data: newsDetail.content,
                                          style: {
                                            "p": Style(
                                                padding:
                                                    EdgeInsets.only(right: 14)),
                                          },
                                        )
                                      : Text((newsDetail.content ?? "")),
                                ),
                                AdsCommentWidget(postId, newsDetail, doReload)
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
              return Container(
                  child: Text(
                      "Không có dữ liệu, kiểm tra lại kết nối internet của bạn"));
            }),
//        floatingActionButton: owner!=null ? FloatingActionButton.extended(
//          onPressed: () {
//            _postActionBloc
//                .requestPushMyPost(postId);
//            _postActionBloc.pushMyPostStream.listen((event) {
//              switch (event.status) {
//                case Status.LOADING:
//                  break;
//                case Status.COMPLETED:
//                  Helper.showMissingDialog(context, "Đẩy tin thành công",
//                      "Tin của bạn đã được đẩy thành công");
//                  break;
//                case Status.ERROR:
//                  Fluttertoast.showToast(
//                      msg: event.message,
//                      textColor: Colors.black87);
//                  Navigator.pop(context);
//                  break;
//              }
//            });
//          },
//          backgroundColor: Colors.orange,
//          label: Text("Đẩy tin"),
//          icon: Icon(Icons.publish),
//        ) : Container(),
      ),
    );
  }
}
