import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:conecapp/ui/home/pages/google_map_page.dart';
import 'package:conecapp/ui/home/pages/introduce_page.dart';
import 'package:conecapp/ui/home/widgets/comment_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:conecapp/models/response/image.dart' as myImage;
import '../../../common/globals.dart' as globals;
import '../../../common/helper.dart';

class ItemDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/items-detail';

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  bool _isFavorite = false;
  bool _isCallApi;
  String phoneNumber;
  String linkShare;
  int _currentIndex = 0;
  bool _setBanners = true;
  String postId;
  String title;
  double lat = 10.8483258;
  double lng = 106.7686185;
  bool _firstCalculate = true;
  ItemsByCategoryBloc _itemsByCategoryBloc = ItemsByCategoryBloc();
  PageController _pageController = PageController(initialPage: 0);
  String _token;

  void getToken() async {
    String token = await Helper.getToken();
    setState(() {
      _token = token;
    });
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
      _itemsByCategoryBloc.requestItemDetail(postId);
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

  void getLatLng(String address) async {
    final result = await Helper.getLatLng(address);
    setState(() {
      lat = result.lat;
      lng = result.long;
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
//            IconButton(
//              onPressed: () {
//                setState(() {
//                  _isFavorite = !_isFavorite;
//                });
//              },
//              icon: Icon(
//                _isFavorite ? Icons.favorite : Icons.favorite_border,
//                color: Colors.red,
//              ),
//            ),
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
        body: StreamBuilder<ApiResponse<ItemDetail>>(
            stream: _itemsByCategoryBloc.itemDetailStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    return UILoading(loadingMessage: snapshot.data.message);
                  case Status.COMPLETED:
                    ItemDetail itemDetail = snapshot.data.data;
                    if (itemDetail.images.length > 0 && _setBanners) {
                      autoPlayBanners(itemDetail.images);
                      _setBanners = false;
                    }
                    phoneNumber = itemDetail.phoneNumber;
                    linkShare = itemDetail.shareLink;
                    if (_firstCalculate) {
                      getLatLng(itemDetail.getAddress);
                      _firstCalculate = false;
                    }
                    return SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Hero(
                            tag: postId,
                            child: itemDetail.images.length > 0
                                ? Stack(
                                  children: [
                                    Container(
                                        height: 225,
                                        child: PageView.builder(
                                            itemCount: itemDetail.images.length,
                                            controller: _pageController,
                                            onPageChanged: (currentPage) {
                                              setState(() {
                                                _currentIndex = currentPage;
                                              });
                                            },
                                            itemBuilder: (context, index) {
                                              return CachedNetworkImage(
                                                imageUrl: itemDetail
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
                                              itemDetail.images.length,
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
                                    imageUrl: itemDetail.thumbnail,
                                    placeholder: (context, url) => Image.asset(
                                        "assets/images/placeholder.png"),
                                    errorWidget: (context, url, error) =>
                                        Image.asset("assets/images/error.png"),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 225,
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
                                                  child: Text(itemDetail.title,
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
                                                await launch(
                                                    'tel:${itemDetail.phoneNumber}');
                                              },
                                              icon: Icon(Icons.phone,
                                                  color: Colors.blue),
                                              label: Text(
                                                itemDetail.phoneNumber ?? "",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ))
                                        ],
                                      ),
                                      // Row(
                                      //   children: <Widget>[
                                      //     Text(
                                      //         itemDetail.ratingAvg.toString() ??
                                      //             "0"),
                                      //     Icon(Icons.star, color: Colors.amber),
                                      //     Text(
                                      //         "(${itemDetail.ratingCount ?? "0"} đánh giá)"),
                                      //     Spacer(),
                                      //     FlatButton.icon(
                                      //         padding: EdgeInsets.all(0),
                                      //         onPressed: () {
                                      //           if (_token == null) {
                                      //             Helper
                                      //                 .showAuthenticationDialog(
                                      //                 context);
                                      //           } else {
                                      //             showModalBottomSheet(
                                      //                 context: context,
                                      //                 builder: (BuildContext
                                      //                 context) {
                                      //                   int rating = 5;
                                      //                   return Container(
                                      //                     height: 150,
                                      //                     alignment:
                                      //                     Alignment
                                      //                         .center,
                                      //                     child: Column(
                                      //                       mainAxisAlignment:
                                      //                       MainAxisAlignment
                                      //                           .spaceAround,
                                      //                       children: <
                                      //                           Widget>[
                                      //                         RatingBar(
                                      //                           initialRating:
                                      //                           5,
                                      //                           minRating:
                                      //                           1,
                                      //                           direction: Axis
                                      //                               .horizontal,
                                      //                           allowHalfRating:
                                      //                           true,
                                      //                           itemCount:
                                      //                           5,
                                      //                           itemPadding:
                                      //                           EdgeInsets.symmetric(
                                      //                               horizontal:
                                      //                               4.0),
                                      //                           itemBuilder:
                                      //                               (context,
                                      //                               _) =>
                                      //                               Icon(
                                      //                                 Icons
                                      //                                     .star,
                                      //                                 color: Colors
                                      //                                     .amber,
                                      //                               ),
                                      //                           onRatingUpdate:
                                      //                               (value) {
                                      //                             rating = value
                                      //                                 .toInt();
                                      //                           },
                                      //                         ),
                                      //                         InkWell(
                                      //                           onTap: () {
                                      //                             print(
                                      //                                 "uprating");
                                      //                             _itemsByCategoryBloc
                                      //                                 .requestRating(
                                      //                                 jsonEncode({
                                      //                                   "postId":
                                      //                                   itemDetail.postId,
                                      //                                   "rating":
                                      //                                   rating
                                      //                                 }));
                                      //                             Navigator.of(
                                      //                                 context)
                                      //                                 .pop();
                                      //                           },
                                      //                           child:
                                      //                           Container(
                                      //                             decoration: BoxDecoration(
                                      //                                 color: Colors
                                      //                                     .white,
                                      //                                 borderRadius: BorderRadius.circular(
                                      //                                     8),
                                      //                                 border: Border.all(
                                      //                                     width: 1,
                                      //                                     color: Colors.grey)),
                                      //                             height:
                                      //                             45,
                                      //                             width:
                                      //                             250,
                                      //                             child:
                                      //                             Center(
                                      //                               child:
                                      //                               Text(
                                      //                                 'Gửi đánh giá',
                                      //                                 textAlign:
                                      //                                 TextAlign.center,
                                      //                                 style: TextStyle(
                                      //                                     fontSize: 18,
                                      //                                     color: Colors.black87,
                                      //                                     fontWeight: FontWeight.w500),
                                      //                               ),
                                      //                             ),
                                      //                           ),
                                      //                         ),
                                      //                       ],
                                      //                     ),
                                      //                   );
                                      //                 })
                                      //                 .then((value) =>
                                      //                 debugPrint(
                                      //                     "selectedCity"));
                                      //           }
                                      //         },
                                      //         icon: Icon(
                                      //           Icons.rate_review,
                                      //           color: Colors.blue,
                                      //         ),
                                      //         label: Text(
                                      //           "Đánh giá",
                                      //           style: TextStyle(
                                      //               color: Colors.blue,
                                      //               fontSize: 18),
                                      //         ))
                                      //   ],
                                      // )
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
                                      itemDetail.joiningFee != null && itemDetail.joiningFee!=0
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
                                  child: Text(itemDetail.getAddress ?? "",
                                      style: TextStyle(fontSize: 14)),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        GoogleMapPage.ROUTE_NAME,
                                        arguments: {
                                          'lat': lat,
                                          'lng': lng,
                                          'postId': itemDetail.postId,
                                          'title': itemDetail.title,
                                          'address': '${itemDetail.getAddress}'
                                        });
                                  },
                                  child: Image.network(
                                    Helper.generateLocationPreviewImage(
                                        lat: itemDetail.lat != 0.0
                                            ? itemDetail.lat
                                            : lat,
                                        lng: itemDetail.long != 0.0
                                            ? itemDetail.long
                                            : lng),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
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
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Html(
                                    data: itemDetail.content ?? "",
                                  )
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
//        floatingActionButton: Column(
//          mainAxisSize: MainAxisSize.min,
//          children: <Widget>[
//            FloatingActionButton(
//              heroTag: "call",
//              onPressed: () async {
//                await launch('tel:$phoneNumber');
//              },
//              backgroundColor: Colors.blue,
//              child: Icon(Icons.call),
//            ),
//            SizedBox(height: 4),
//            FloatingActionButton(
//              heroTag: "mess",
//              onPressed: () async {
//                await launch('sms:$phoneNumber');
//              },
//              backgroundColor: Colors.green,
//              child: Icon(Icons.message),
//            )
//          ],
//        ),
      ),
    );
  }
}
