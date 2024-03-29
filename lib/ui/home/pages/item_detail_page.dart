import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/models/response/image.dart' as myImage;
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/models/response/page/hidden_response.dart';
import 'package:conecapp/models/response/page/page_response.dart';
import 'package:conecapp/models/response/profile/gift_response.dart';
import 'package:conecapp/repositories/home/home_remote_repository.dart';
import 'package:conecapp/ui/chat/chat_page.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:conecapp/ui/home/pages/introduce_page.dart';
import 'package:conecapp/ui/home/pages/report_page.dart';
import 'package:conecapp/ui/home/widgets/comment_widget.dart';
import 'package:conecapp/ui/member2/member2_detail_page.dart';
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
  bool _isCallApi;
  bool _showNotify = true;
  String linkShare;
  bool isApprove = false;
  int _currentIndex = 0;
  String postId;
  String ownerId;
  String owner;
  String title;
  double lat = 10.8483258;
  double lng = 106.7686185;
  ItemsByCategoryBloc _itemsByCategoryBloc = ItemsByCategoryBloc();
  PostActionBloc _postActionBloc = PostActionBloc();
  PageController _pageController = PageController(initialPage: 0);
  String _token;
  bool _isTokenExpired = true;
  bool _isLoading = false;
  int _userViewPostCount = 0;
  ProfileBloc _profileBloc = ProfileBloc();
  HomeRemoteRepository _repository = HomeRemoteRepository();
  bool needReload = true;
  bool needReload2 = true;

  void getToken() async {
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
    });
  }

  bool isTokenInValid() {
    return _token == null || _token.length == 0;
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
      //requestGetHidden(postId);
      _itemsByCategoryBloc.requestItemDetail(postId);
      if (owner != null) {
        giftCheck();
      }
      _isCallApi = false;
    }
  }

  void doReload() {
    debugPrint("doReload");
    needReload = true;
    needReload2 = true;
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
        body: Stack(
          children: [
            StreamBuilder<ApiResponse<ItemDetail>>(
                stream: _itemsByCategoryBloc.itemDetailStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return UILoading(loadingMessage: snapshot.data.message);
                      case Status.COMPLETED:
                        ItemDetail itemDetail = snapshot.data.data;
                        isApprove = itemDetail.status == "APPROVED";
                        ownerId = itemDetail.ownerId;
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
                                      pageBuilder:
                                          (BuildContext context, _, __) =>
                                              ImageViewerPage(itemDetail.images,
                                                  _currentIndex)));
                                },
                                child: Hero(
                                  tag: postId,
                                  child: itemDetail.images.length > 0
                                      ? Stack(
                                          children: [
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
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8)),
                                                            child: Stack(
                                                              children: <
                                                                  Widget>[
                                                                CachedNetworkImage(
                                                                  imageUrl: item
                                                                      .fileName,
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
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                                Positioned(
                                                                  bottom: 0.0,
                                                                  left: 0.0,
                                                                  right: 0.0,
                                                                  child:
                                                                      Container(
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
                                                                          Color.fromARGB(
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
                                                                    padding: EdgeInsets.symmetric(
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
                                                      itemCount: itemDetail
                                                          .images.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Container(
                                                          width: 16,
                                                          height: 16,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                                  //borderRadius: BorderRadius.all(Radius.circular(16)),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border.all(
                                                                      width: 1,
                                                                      color: Colors
                                                                          .white),
                                                                  color: _currentIndex ==
                                                                          index
                                                                      ? Colors
                                                                          .white
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
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.streetview,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 8),
                                              Text("Xem thông tin",
                                                  style: AppTheme.commonDetail),
                                            ],
                                          ),
                                        ),
                                        //Spacer(),
                                        (isTokenInValid() ||
                                                itemDetail.ownerId ==
                                                    globals.ownerId)
                                            ? Container()
                                            : FutureBuilder(
                                                future: needReload
                                                    ? _repository
                                                        .fetchPageIntroduce(
                                                            itemDetail.ownerId)
                                                    : null,
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  }
                                                  Profile profile =
                                                      snapshot.data.profile;
                                                  needReload = false;
                                                  return FlatButton(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                      onPressed: () async {
                                                        if (profile.isMember) {
                                                          print("push: " +
                                                              profile
                                                                  .userMemberId);
                                                          Navigator.of(context)
                                                              .pushNamed(
                                                                  Member2DetailPage
                                                                      .ROUTE_NAME,
                                                                  arguments: {
                                                                'id': profile
                                                                    .userMemberId,
                                                                'title':
                                                                    profile.name
                                                              });
                                                        } else {
                                                          Helper.showInputDialog(
                                                              context,
                                                              "Đăng ký thành viên",
                                                              profile.name,
                                                              (value) async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            setState(() {
                                                              _isLoading = true;
                                                            });
                                                            bool result =
                                                                await _repository
                                                                    .requestMember(
                                                                        jsonEncode({
                                                              'userId': globals
                                                                  .ownerId,
                                                              'notes': value
                                                            }));
                                                            if (result)
                                                              setState(() {
                                                                _isLoading =
                                                                    false;
                                                              });
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Thành công",
                                                                textColor: Colors
                                                                    .black87);
                                                          });
                                                        }
                                                      },
                                                      color: Colors.green,
                                                      textColor: Colors.white,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: 100,
                                                        child: Text(
                                                            profile.isMember
                                                                ? "Thông tin"
                                                                : "Đăng ký",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                      ));
                                                }),
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
                                                  if (isTokenInValid()) {
                                                    Helper
                                                        .showAuthenticationDialog(
                                                            context);
                                                  } else {
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            IntroducePage
                                                                .ROUTE_NAME,
                                                            arguments: {
                                                          'clubId':
                                                              itemDetail.ownerId
                                                        });
                                                  }
                                                },
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 25,
                                                      backgroundColor:
                                                          Colors.grey,
                                                      backgroundImage: itemDetail
                                                                  .ownerAvatar !=
                                                              null
                                                          ? NetworkImage(
                                                              itemDetail
                                                                  .ownerAvatar)
                                                          : AssetImage(
                                                              "assets/images/avatar.png"),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              250,
                                                      child: Text(
                                                          itemDetail.owner,
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
                                                    HiddenResponse response =
                                                        await _itemsByCategoryBloc
                                                            .requestHiddenPostInfo(
                                                                globals.ownerId,
                                                                itemDetail
                                                                    .ownerId,
                                                                postId);
                                                    if (response.status) {
                                                      setState(() {
                                                        _userViewPostCount =
                                                            response
                                                                .userViewPostCount;
                                                      });
                                                      Helper.showInfoDialog(
                                                          context,
                                                          itemDetail
                                                              .phoneNumber,
                                                          itemDetail.getAddress,
                                                          () async {
                                                        await launch(
                                                            'tel:${itemDetail.phoneNumber}');
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
                                                  },
                                                  icon: Icon(Icons.phone,
                                                      color: Colors.blue),
                                                  label: Text(
                                                    "(${_userViewPostCount > 0 ? _userViewPostCount : itemDetail.userViewPostCount}) Liên hệ",
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
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8)),
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.attach_money,
                                          color: Colors.green,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text("Lệ phí",
                                            style: AppTheme.commonDetail),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            child: Text(
                                              itemDetail.joiningFee != null &&
                                                      itemDetail.joiningFee != 0
                                                  ? '${Helper.formatCurrency(itemDetail.joiningFee)} ${itemDetail.joiningFeePeriod != null ? "/" : ""} ${itemDetail.joiningFeePeriod ?? ""}'
                                                  : "Liên hệ",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    itemDetail.notifications != null &&
                                            itemDetail.notifications.length >
                                                0 &&
                                            _showNotify
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  width: double.infinity,
                                                  height: 1,
                                                  color: Colors.black12,
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 8)),
                                              Card(
                                                elevation: 5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .notifications_active,
                                                          color: Colors.yellow,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text("Thông báo",
                                                            style: AppTheme
                                                                .commonDetail),
                                                        Spacer(),
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons
                                                                  .clear_outlined,
                                                              size: 28),
                                                          onPressed: () {
                                                            setState(() {
                                                              _showNotify =
                                                                  false;
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    ListView.builder(
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        shrinkWrap: true,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        itemCount: itemDetail
                                                            .notifications
                                                            .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                100,
                                                            margin:
                                                                EdgeInsets.all(
                                                                    8),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        8),
                                                            color: Helper.getColorNotify(
                                                                    itemDetail
                                                                        .notifications[
                                                                            index]
                                                                        .color)
                                                                .color,
                                                            // child: Text(
                                                            //     itemDetail
                                                            //         .notifications[
                                                            //             index]
                                                            //         .content,
                                                            //     maxLines: 2,
                                                            //     overflow:
                                                            //         TextOverflow
                                                            //             .ellipsis),
                                                            child: Html(
                                                                data: itemDetail
                                                                    .notifications[
                                                                        index]
                                                                    .content),
                                                          );
                                                        }),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    Container(
                                        width: double.infinity,
                                        height: 1,
                                        color: Colors.black12,
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8)),
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.description,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 8),
                                        Text("Mô tả",
                                            style: AppTheme.commonDetail),
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
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8)),
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.question_answer,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 8),
                                        Text("Trao đổi với CLB qua chat",
                                            style: AppTheme.commonDetail),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: Helper.hardCodeMPost
                                            .map((e) => InkWell(
                                                  onTap: () {
                                                    if (isTokenInValid()) {
                                                      Helper
                                                          .showAuthenticationDialog(
                                                              context);
                                                    } else {
                                                      if (itemDetail.ownerId !=
                                                          globals.ownerId) {
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                                ChatPage
                                                                    .ROUTE_NAME,
                                                                arguments: {
                                                              "memberId":
                                                                  ownerId,
                                                              "postId": postId,
                                                              "mess": e
                                                            });
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Bạn không thể chat với chính mình");
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    margin: EdgeInsets.all(4),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 0),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: itemDetail
                                                                        .ownerId !=
                                                                    globals
                                                                        .ownerId
                                                                ? Colors.red
                                                                : Colors.grey,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                    child: Text(e,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: itemDetail
                                                                      .ownerId !=
                                                                  globals
                                                                      .ownerId
                                                              ? Colors.red
                                                              : Colors.grey,
                                                        )),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CommentWidget(postId, itemDetail, doReload),
                              SizedBox(height: 45)
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
            _isLoading ? UILoadingOpacity() : Container()
          ],
        ),
        floatingActionButton: StreamBuilder<ApiResponse<ItemDetail>>(
            stream: _itemsByCategoryBloc.itemDetailStream2,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.COMPLETED:
                    ItemDetail detail = snapshot.data.data;
                    return detail != null && detail.ownerId != globals.ownerId
                        ? FloatingActionButton.extended(
                            label: Text("Nhắn tin"),
                            icon: Icon(Icons.chat),
                            onPressed: () {
                              if (isTokenInValid()) {
                                Helper.showAuthenticationDialog(context);
                              } else {
                                Navigator.of(context)
                                    .pushNamed(ChatPage.ROUTE_NAME, arguments: {
                                  "memberId": ownerId,
                                  "postId": postId
                                });
                              }
                            },
                          )
                        : Container();
                  default:
                    return Container();
                }
              }
              return Container();
            }),
      ),
    );
  }
}
