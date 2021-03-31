import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/image.dart' as myImage;
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/models/response/page/hidden_response.dart';
import 'package:conecapp/models/response/profile/GiftReponse.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:conecapp/ui/home/pages/introduce_page.dart';
import 'package:conecapp/ui/home/pages/report_page.dart';
import 'package:conecapp/ui/home/widgets/comment_widget.dart';
import 'package:conecapp/ui/mypost/blocs/post_action_bloc.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/globals.dart' as globals;
import '../../../common/helper.dart';
import 'image_viewer_page.dart';

class ItemDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/items-detail';

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  bool _isFavorite = false;
  bool _isCallApi;

  //String phoneNumber;
  bool _shouldShow = false;
  String linkShare;
  bool isApprove = false;
  int _currentIndex = 0;
  bool _setBanners = true;
  String postId;
  String owner;
  String title;
  double lat = 10.8483258;
  double lng = 106.7686185;
  bool _firstCalculate = true;
  ItemsByCategoryBloc _itemsByCategoryBloc = ItemsByCategoryBloc();
  PostActionBloc _postActionBloc = PostActionBloc();
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
            //       style: TextStyle(
            //           color: Colors.blue)),
            //   onPressed: () {
            //     requestPush(false, true);
            //     Navigator.pop(context);
            //   },
            // ),
            // CupertinoActionSheetAction(
            //   child: Text('Đẩy tin và ưu tiên',
            //       style: TextStyle(
            //           color: Colors.blue)),
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

  @override
  void initState() {
    _isCallApi = true;
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
      title = routeArgs['title'];
      owner = routeArgs['owner'];
      _itemsByCategoryBloc.requestItemDetail(postId);
      if (owner != null) {
        giftCheck();
      }
      _isCallApi = false;
    }
  }

  void doReload() {
    debugPrint("doReload");
    _itemsByCategoryBloc.requestItemDetail(postId);
  }

  String getImageUrl(String thumnail, List<myImage.Image> img) {
    if (img == null || img.length == 0) {
      return thumnail ?? "";
    }
    return img[0].fileName;
  }

//  void getLatLng(String address) async {
//    final result = await Helper.getLatLng(address);
//    setState(() {
//      lat = result.lat;
//      lng = result.long;
//    });
//  }

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
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black, size: 26),
          title: Text(
            title ?? "",
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
                            "Tin của bạn cần phải được duyệt trước khi làm mới");
                      }
                    },
                    icon: Icon(
                      Icons.publish,
                      color: Colors.orange,
                    ),
                  )
                : Container(),
//            IconButton(
//              onPressed: () {
//                Share.share(linkShare ?? Helper.applicationUrl());
//              },
//              icon: Icon(
//                Icons.share,
//                color: Colors.red,
//              ),
//            ),
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
        body: StreamBuilder<ApiResponse<ItemDetail>>(
            stream: _itemsByCategoryBloc.itemDetailStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    return UILoading(loadingMessage: snapshot.data.message);
                  case Status.COMPLETED:
                    ItemDetail itemDetail = snapshot.data.data;
                    isApprove = itemDetail.status == "APPROVED";
                    // if (itemDetail.images.length > 0 && _setBanners) {
                    //   autoPlayBanners(itemDetail.images);
                    //   _setBanners = false;
                    // }
                    //phoneNumber = itemDetail.phoneNumber;
                    linkShare = itemDetail.shareLink;
//                    if (_firstCalculate) {
//                      getLatLng(itemDetail.getAddress);
//                      _firstCalculate = false;
//                    }
                    return SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (BuildContext context, _, __) =>
                                      ImageViewerPage(
                                          itemDetail.images, _currentIndex)));
                            },
                            child: Hero(
                              tag: postId,
                              child: itemDetail.images.length > 0
                                  ? Stack(
                                      children: [
                                        // Container(
                                        //   height: 225,
                                        //   child: PageView.builder(
                                        //       itemCount: itemDetail.images.length,
                                        //       controller: _pageController,
                                        //       onPageChanged: (currentPage) {
                                        //         setState(() {
                                        //           _currentIndex = currentPage;
                                        //         });
                                        //       },
                                        //       itemBuilder: (context, index) {
                                        //         return CachedNetworkImage(
                                        //           imageUrl: itemDetail
                                        //               .images[index].fileName,
                                        //           placeholder: (context, url) =>
                                        //               Image.asset(
                                        //                   "assets/images/placeholder.png"),
                                        //           errorWidget: (context, url,
                                        //                   error) =>
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
                                            onPageChanged:
                                                (currentPage, reason) {
                                              setState(() {
                                                _currentIndex = currentPage;
                                              });
                                            },
                                            //height: 225,
                                            height: Helper.isTablet(context)
                                                ? 320
                                                : 225,
                                            autoPlay: true,
                                            enlargeCenterPage: false,
                                            viewportFraction: 1.0,
                                          ),
                                          items: itemDetail.images
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
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit.cover,
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
                                                                      Color.fromARGB(
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
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Center(
                                              child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      itemDetail.images.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Container(
                                                      width: 16,
                                                      height: 16,
                                                      margin: EdgeInsets.only(
                                                          right: 6),
                                                      decoration: BoxDecoration(
                                                          //borderRadius: BorderRadius.all(Radius.circular(16)),
                                                          shape:
                                                              BoxShape.circle,
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
                                      imageUrl: itemDetail.thumbnail,
                                      placeholder: (context, url) =>
                                          Image.asset(
                                              "assets/images/placeholder.png"),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              "assets/images/error.png"),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 225,
                                    ),
                            ),
                          ),
//                          if (itemDetail.images.length > 0)
//                            Container(
//                              height: 55,
//                              margin: EdgeInsets.only(top: 4),
//                              child: Center(
//                                child: ListView.builder(
//                                    shrinkWrap: true,
//                                    scrollDirection: Axis.horizontal,
//                                    itemCount: itemDetail.images.length,
//                                    itemBuilder: (context, index) {
//                                      return InkWell(
//                                        onTap: () {
//                                          setState(() {
//                                            _currentIndex = index;
//                                          });
//                                          if (_pageController.hasClients) {
//                                            _pageController.animateToPage(
//                                              index,
//                                              duration:
//                                                  Duration(milliseconds: 350),
//                                              curve: Curves.easeIn,
//                                            );
//                                          }
//                                        },
//                                        child: Container(
//                                          decoration: _currentIndex == index
//                                              ? BoxDecoration(
//                                                  border: Border.all(
//                                                      width: 2,
//                                                      color: Colors.green),
//                                                  borderRadius:
//                                                      BorderRadius.all(
//                                                          Radius.circular(8)),
//                                                )
//                                              : null,
//                                          margin: EdgeInsets.only(right: 2),
//                                          child: ClipRRect(
//                                            borderRadius: BorderRadius.all(
//                                                Radius.circular(6)),
//                                            child: CachedNetworkImage(
//                                              imageUrl: itemDetail
//                                                  .images[index].fileName,
//                                              placeholder: (context, url) =>
//                                                  Image.asset(
//                                                      "assets/images/placeholder.png"),
//                                              errorWidget: (context, url,
//                                                      error) =>
//                                                  Image.asset(
//                                                      "assets/images/error.png"),
//                                              fit: BoxFit.cover,
//                                              width: 55,
//                                              height: 55,
//                                            ),
//                                          ),
//                                        ),
//                                      );
//                                    }),
//                              ),
//                            )
//                          else
//                            Container(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
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
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                  IntroducePage.ROUTE_NAME,
                                                  arguments: {
                                                    'clubId': itemDetail.ownerId
                                                  });
                                            },
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: Colors.grey,
                                                  backgroundImage: itemDetail
                                                              .ownerAvatar !=
                                                          null
                                                      ? NetworkImage(itemDetail
                                                          .ownerAvatar)
                                                      : AssetImage(
                                                          "assets/images/avatar.png"),
                                                ),
                                                SizedBox(width: 8),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      250,
                                                  child: Text(itemDetail.owner,
                                                      style: TextStyle(
                                                          fontSize: 18)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Spacer(),
                                          FlatButton.icon(
                                              padding:
                                                  EdgeInsets.only(right: 0),
                                              onPressed: () async {
                                                if (_shouldShow) {
                                                  await launch(
                                                      'tel:${itemDetail.phoneNumber}');
                                                } else {
                                                  HiddenResponse response =
                                                      await _itemsByCategoryBloc
                                                          .requestHiddenPostInfo(
                                                              globals.ownerId,
                                                              itemDetail
                                                                  .ownerId,
                                                              itemDetail
                                                                  .postId);
                                                  if (response.status) {
                                                    setState(() {
                                                      _shouldShow =
                                                          response.status;
                                                    });
                                                  } else {
                                                    Helper.showHiddenDialog(
                                                        context,
                                                        response.message ??
                                                            "Có lỗi xảy ra, xin thử lại sau",
                                                        () {
                                                      Navigator.pop(context);
                                                    });
                                                  }
                                                }
                                              },
                                              icon: Icon(Icons.phone,
                                                  color: Colors.blue),
                                              label: Text(
                                                _shouldShow
                                                    ? itemDetail.phoneNumber
                                                    : "Liên hệ",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ))
                                        ],
                                      ),
                                    ],
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
                                    Text(itemDetail.approvedDate ?? "",
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
                                      Icons.attach_money,
                                      color: Colors.green,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text("Phí tham gia",
                                        style: AppTheme.commonDetail),
                                    Spacer(),
                                    Text(
                                      itemDetail.joiningFee != null &&
                                              itemDetail.joiningFee != 0
                                          ? '${Helper.formatCurrency(itemDetail.joiningFee)} VND ${itemDetail.joiningFeePeriod != null ? "/" : ""} ${itemDetail.joiningFeePeriod ?? ""}'
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
                                _shouldShow
                                    ? Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: 8),
                                          Text("Địa chỉ",
                                              style: AppTheme.commonDetail),
                                        ],
                                      )
                                    : Container(),
                                _shouldShow
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(itemDetail.getAddress ?? "",
                                            style: TextStyle(fontSize: 14)),
                                      )
                                    : Container(),
                                // InkWell(
                                //   onTap: () {
                                //     Navigator.of(context).pushNamed(
                                //         GoogleMapPage.ROUTE_NAME,
                                //         arguments: {
                                //           'lat': lat,
                                //           'lng': lng,
                                //           'postId': itemDetail.postId,
                                //           'title': itemDetail.title,
                                //           'address': '${itemDetail.getAddress}'
                                //         });
                                //   },
                                //   child: Image.network(
                                //     Helper.generateLocationPreviewImage(
                                //         lat: itemDetail.lat != 0
                                //             ? itemDetail.lat
                                //             : lat,
                                //         lng: itemDetail.long != 0
                                //             ? itemDetail.long
                                //             : lng),
                                //     fit: BoxFit.cover,
                                //     width: double.infinity,
                                //   ),
                                // ),
                                _shouldShow
                                    ? Container(
                                        width: double.infinity,
                                        height: 1,
                                        color: Colors.black12,
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8))
                                    : Container(),
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
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: itemDetail.content.contains("<")
                                        ? Html(
                                            data: itemDetail.content ?? "",
                                          )
                                        : Text(itemDetail.content)),
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
                              ],
                            ),
                          ),
                          CommentWidget(postId, itemDetail, doReload)
//                          FlatButton.icon(
//                              shape: RoundedRectangleBorder(
//                                  side: BorderSide(
//                                      width: 0.5, color: Colors.orangeAccent),
//                                  borderRadius: BorderRadius.circular(8)),
//                              onPressed: () {
//                                //TODO - send report
//                              },
//                              color: Colors.white,
//                              textColor: Colors.orangeAccent,
//                              icon: Icon(Icons.report),
//                              label: Text("Báo cáo vi phạm",
//                                  style: TextStyle(
//                                      fontSize: 14,
//                                      fontWeight: FontWeight.w400))),
                        ],
                      ),
                    );
                  case Status.ERROR:
                    return UIError(
                        errorMessage: snapshot.data.message,
                        onRetryPressed: () =>
                            _itemsByCategoryBloc.requestItemDetail(postId));
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
//                      "Tin của bạn sẽ được hiện lên trang đầu");
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
