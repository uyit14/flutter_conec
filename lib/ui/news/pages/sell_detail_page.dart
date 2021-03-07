import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/ads_detail.dart';
import 'package:conecapp/models/response/image.dart' as myImage;
import 'package:conecapp/models/response/profile/GiftReponse.dart';
import 'package:conecapp/ui/home/pages/introduce_page.dart';
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
import 'package:url_launcher/url_launcher.dart';

class SellDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/sell-detail';

  @override
  _SellDetailPageState createState() => _SellDetailPageState();
}

class _SellDetailPageState extends State<SellDetailPage> {
  String postId;
  String owner;
  NewsBloc _newsBloc = NewsBloc();
  PostActionBloc _postActionBloc = PostActionBloc();
  String phoneNumber;
  int _currentIndex = 0;
  double lat = 10.8483258;
  double lng = 106.7686185;
  bool _firstCalculate = true;
  String linkShare;
  bool isApprove = false;
  bool _setBanners = true;
  bool _isCallApi = true;
  PageController _pageController = PageController(initialPage: 0);
  ProfileBloc _profileBloc = ProfileBloc();

  String _token;
  bool _isTokenExpired = true;

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
    if (_isCallApi) {
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, Object>;
      postId = routeArgs['postId'];
      owner = routeArgs['owner'];
      _newsBloc.requestAdsDetail(postId);
      if(owner != null){
        giftCheck();
      }
      _isCallApi = false;
    }
  }

  void getLatLng(String address) async {
    try {
      final result = await Helper.getLatLng(address);
      setState(() {
        lat = result.lat;
        lng = result.long;
      });
    } catch (e) {
      setState(() {
        lat = 0.0;
        lng = 0.0;
      });
    }
  }

  void doReload() {
    debugPrint("doReload");
    _newsBloc.requestAdsDetail(postId);
  }

  void showRemindDialog(BuildContext context) {
    if (pushNumber > 0 || postNumber > 0) {
      final act = CupertinoActionSheet(
          actions: <Widget>[
            pushNumber > 0
                ? CupertinoActionSheetAction(
                    child: Text('Đẩy tin lên đầu ($pushNumber)',
                        style: TextStyle(color: Colors.blue)),
                    onPressed: () {
                      requestPush(true, false);
                      Navigator.pop(context);
                    },
                  )
                : Container(),
            postNumber > 0
                ? CupertinoActionSheetAction(
                    child: Text('Ưu tiên tin ($postNumber)',
                        style: TextStyle(color: Colors.blue)),
                    onPressed: () {
                      requestPush(false, true);
                      Navigator.pop(context);
                    },
                  )
                : Container(),
            pushNumber > 0 && postNumber > 0
                ? CupertinoActionSheetAction(
                    child: Text('Đẩy tin và ưu tiên',
                        style: TextStyle(color: Colors.blue)),
                    onPressed: () {
                      requestPush(true, true);
                      Navigator.pop(context);
                    },
                  )
                : Container()
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
          msg: "Bạn đã dùng hết lượt đẩy tin và ưu tiên tin",
          textColor: Colors.black87);
    }
  }

  String getImageUrl(String thumnail, List<myImage.Image> img) {
    if (img == null || img.length == 0) {
      return thumnail ?? "";
    }
    return img[0].fileName;
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
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black, size: 26),
          title: Text(
            "Chi tiết sản phẩm",
            style: TextStyle(color: Colors.black),
          ),
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
                            "Tin của bạn cần phải được duyệt trước khi làm mới hoặc ưu tiên");
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
        body: StreamBuilder<ApiResponse<AdsDetail>>(
            stream: _newsBloc.adsDetailStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    return UILoading(loadingMessage: snapshot.data.message);
                  case Status.COMPLETED:
                    AdsDetail adsDetail = snapshot.data.data;
                    linkShare = adsDetail.shareLink;
                    isApprove = adsDetail.status == "APPROVED";
                    // if (adsDetail.images.length > 0 && _setBanners) {
                    //   autoPlayBanners(adsDetail.images);
                    //   _setBanners = false;
                    // }
                    if (_firstCalculate) {
                      getLatLng(adsDetail.getAddress);
                      _firstCalculate = false;
                    }
                    phoneNumber = adsDetail.phoneNumber;
                    return SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Hero(
                            tag: postId,
                            child: adsDetail.images.length > 0
                                ? Stack(
                                    children: [
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
                                        items: adsDetail.images
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
                                                    adsDetail.images.length,
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
                                    imageUrl: adsDetail.thumbnail,
                                    placeholder: (context, url) => Image.asset(
                                        "assets/images/placeholder.png"),
                                    errorWidget: (context, url, error) =>
                                        Image.asset("assets/images/error.png"),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 225,
                                  ),
                          ),
                          // if (adsDetail.images.length > 0)
                          //   Container(
                          //     height: 55,
                          //     margin: EdgeInsets.only(top: 4),
                          //     child: Center(
                          //       child: ListView.builder(
                          //           shrinkWrap: true,
                          //           scrollDirection: Axis.horizontal,
                          //           itemCount: adsDetail.images.length,
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
                          //                     imageUrl: adsDetail
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(adsDetail.title, style: AppTheme.title),
                                SizedBox(height: 8),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.person_pin,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 8),
                                    Text("Người đăng",
                                        style: AppTheme.commonDetail)
                                  ],
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: <Widget>[
//                                        CircleAvatar(
//                                          radius: 25,
//                                          backgroundImage:
//                                              CachedNetworkImageProvider(
//                                                  adsDetail.ownerAvatar ?? ""),
//                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                                IntroducePage.ROUTE_NAME,
                                                arguments: {
                                                  'clubId': adsDetail.ownerId
                                                });
                                          },
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundImage: adsDetail
                                                            .ownerAvatar !=
                                                        null
                                                    ? NetworkImage(
                                                        adsDetail.ownerAvatar)
                                                    : AssetImage(
                                                        "assets/images/avatar.png"),
                                              ),
                                              SizedBox(width: 8),
                                              Text(adsDetail.owner,
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        FlatButton.icon(
                                            padding: EdgeInsets.only(right: 0),
                                            onPressed: () async {
                                              await launch(
                                                  'tel:${adsDetail.phoneNumber}');
                                            },
                                            icon: Icon(Icons.phone,
                                                color: Colors.blue),
                                            label: Text(
                                              adsDetail.phoneNumber ?? "",
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 1,
                                  color: Colors.black12,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.access_time,
                                        color: Colors.green),
                                    SizedBox(width: 8),
                                    Text("Ngày đăng",
                                        style: AppTheme.commonDetail),
                                    Spacer(),
                                    Text(adsDetail.approvedDate,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic))
                                  ],
                                ),
                                Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: Colors.black12,
                                    margin: EdgeInsets.symmetric(vertical: 8)),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.monetization_on,
                                      color: Colors.green,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text("Giá bán",
                                        style: AppTheme.commonDetail),
                                    Spacer(),
                                    Text(
                                      adsDetail.price != null &&
                                              adsDetail.price != 0
                                          ? '${Helper.formatCurrency(adsDetail.price)} VND'
                                          : "Liên hệ",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: Colors.black12,
                                    margin: EdgeInsets.symmetric(vertical: 8)),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 8),
                                    Text("Địa chỉ",
                                        style: AppTheme.commonDetail),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(adsDetail.getAddress ?? "",
                                      style: TextStyle(fontSize: 14)),
                                ),
                                // InkWell(
                                //   onTap: () {
                                //     Navigator.of(context).pushNamed(
                                //         GoogleMapPage.ROUTE_NAME,
                                //         arguments: {
                                //           'lat': lat,
                                //           'lng': lng,
                                //           'postId': adsDetail.postId,
                                //           'title': adsDetail.title,
                                //           'address':
                                //           '${adsDetail.getAddress}'
                                //         });
                                //   },
                                //   child: Image.network(
                                //     Helper.generateLocationPreviewImage(
                                //         lat: adsDetail.lat != 0.0
                                //             ? adsDetail.lat
                                //             : lat,
                                //         lng: adsDetail.long != 0.0
                                //             ? adsDetail.long
                                //             : lng),
                                //     fit: BoxFit.cover,
                                //     width: double.infinity,
                                //   ),
                                // ),
                                Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: Colors.black12,
                                    margin: EdgeInsets.symmetric(vertical: 8)),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.description,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 8),
                                    Text("Mô tả", style: AppTheme.commonDetail),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 20),
                                  child: adsDetail.content.contains("<")
                                      ? Html(
                                          data: adsDetail.content ?? "",
                                          style: {
                                            "p": Style(
                                                padding:
                                                    EdgeInsets.only(right: 14)),
                                          },
                                        )
                                      : Text(adsDetail.content ?? ""),
                                ),
                                Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: Colors.black12,
                                    margin: EdgeInsets.symmetric(vertical: 8)),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.verified_user,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 8),
                                    Text("Kiểm duyệt",
                                        style: AppTheme.commonDetail),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 8),
                                  child: Text(
                                    "Tin đăng đã được kiểm duyệt. Nếu gặp vấn đề, vui lòng báo cáo tin đăng hoặc liên hệ CSKH để được trợ giúp.",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                AdsCommentWidget(postId, adsDetail, doReload)
//                                Center(
//                                  child: FlatButton.icon(
//                                      shape: RoundedRectangleBorder(
//                                          side: BorderSide(
//                                              width: 0.5,
//                                              color: Colors.orangeAccent),
//                                          borderRadius:
//                                              BorderRadius.circular(8)),
//                                      onPressed: () {
//                                        //
//                                      },
//                                      color: Colors.white,
//                                      textColor: Colors.orangeAccent,
//                                      icon: Icon(Icons.report),
//                                      label: Text("Báo cáo vi phạm",
//                                          style: TextStyle(
//                                              fontSize: 14,
//                                              fontWeight: FontWeight.w400))),
//                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  case Status.ERROR:
                    return UIError(
                        errorMessage: snapshot.data.message,
                        onRetryPressed: () =>
                            _newsBloc.requestAdsDetail(postId));
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
