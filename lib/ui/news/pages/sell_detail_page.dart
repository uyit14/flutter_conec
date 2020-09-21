import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/ads_detail.dart';
import 'package:conecapp/ui/home/pages/google_map_page.dart';
import 'package:conecapp/ui/home/pages/introduce_page.dart';
import 'package:conecapp/ui/news/blocs/news_bloc.dart';
import 'package:conecapp/ui/news/widgets/ads_comment_widget.dart';
import 'package:conecapp/models/response/image.dart' as myImage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class SellDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/sell-detail';

  @override
  _SellDetailPageState createState() => _SellDetailPageState();
}

class _SellDetailPageState extends State<SellDetailPage> {
  String postId;
  NewsBloc _newsBloc = NewsBloc();
  String phoneNumber;
  String _currentImageUrl;
  int _currentIndex = 0;
  double lat = 10.8483258;
  double lng = 106.7686185;
  bool _firstCalculate = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    postId = routeArgs['postId'];
    _newsBloc.requestAdsDetail(postId);
  }

  void getLatLng(String address) async {
    final result = await Helper.getLatLng(address);
    setState(() {
      lat = result.lat;
      lng = result.long;
    });
  }

  void doReload() {
    debugPrint("doReload");
    _newsBloc.requestAdsDetail(postId);
  }

  String getImageUrl(String thumnail, List<myImage.Image> img) {
    if (img == null || img.length == 0) {
      return thumnail ?? "";
    }
    return img[0].fileName;
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
        body: StreamBuilder<ApiResponse<AdsDetail>>(
            stream: _newsBloc.adsDetailStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    return UILoading(loadingMessage: snapshot.data.message);
                  case Status.COMPLETED:
                    AdsDetail adsDetail = snapshot.data.data;
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
                            child: CachedNetworkImage(
                              imageUrl: _currentImageUrl ??
                                  getImageUrl(
                                      adsDetail.thumbnail, adsDetail.images),
                              key: new ValueKey<String>(_currentImageUrl ?? ""),
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  Image.asset("assets/images/error.png"),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 225,
                            ),
                          ),
                          if (adsDetail.images.length > 0)
                            Container(
                              height: 55,
                              margin: EdgeInsets.only(top: 4),
                              child: Center(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: adsDetail.images.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _currentImageUrl = adsDetail
                                                .images[index].fileName;
                                            _currentIndex = index;
                                          });
                                        },
                                        child: Container(
                                          decoration: _currentIndex == index
                                              ? BoxDecoration(
                                            border: Border.all(
                                                width: 2,
                                                color: Colors.green),
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(8)),
                                          )
                                              : null,
                                          margin: EdgeInsets.only(right: 2),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6)),
                                            child: CachedNetworkImage(
                                              imageUrl: adsDetail
                                                  .images[index].fileName,
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                      "assets/images/placeholder.png"),
                                              errorWidget: (context, url,
                                                  error) =>
                                                  Image.asset(
                                                      "assets/images/error.png"),
                                              fit: BoxFit.cover,
                                              width: 55,
                                              height: 55,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            )
                          else
                            Container(),
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
                                                backgroundImage: adsDetail.ownerAvatar !=
                                                    null
                                                    ? NetworkImage(
                                                    adsDetail.ownerAvatar)
                                                    : AssetImage(
                                                    "assets/images/avatar.png"),
                                              ),
                                              SizedBox(width: 8),
                                              Text(adsDetail.owner,
                                                  style: TextStyle(fontSize: 18)),
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
                                        adsDetail.price != null ? '${Helper.formatCurrency(adsDetail.price)} VND' : "Liên hệ",
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
                                  child: Text(
                                      adsDetail.getAddress ?? "",
                                      style: TextStyle(fontSize: 14)),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        GoogleMapPage.ROUTE_NAME,
                                        arguments: {
                                          'lat': lat,
                                          'lng': lng,
                                          'postId': adsDetail.postId,
                                          'title': adsDetail.title,
                                          'address':
                                          '${adsDetail.getAddress}'
                                        });
                                  },
                                  child: Image.network(
                                    Helper.generateLocationPreviewImage(
                                        lat: adsDetail.lat != 0.0
                                            ? adsDetail.lat
                                            : lat,
                                        lng: adsDetail.long != 0.0
                                            ? adsDetail.long
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
                                  child: Text(
                                    adsDetail.description ?? "",
                                    style: TextStyle(fontSize: 15),
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
