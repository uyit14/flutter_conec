import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/models/response/page/hidden_response.dart';
import 'package:conecapp/models/response/page/page_response.dart';
import 'package:conecapp/ui/chat/chat_page.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:conecapp/ui/member2/member2_detail_page.dart';
import 'package:conecapp/ui/profile/widgets/detail_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart';

import '../../../common/globals.dart' as globals;
import '../../chat/chat_page.dart';
import 'image_viewer_intropage.dart';
import 'image_viewer_page.dart';
import 'item_detail_page.dart';

class IntroducePage extends StatefulWidget {
  static const ROUTE_NAME = "/intro-page";

  @override
  _IntroducePageState createState() => _IntroducePageState();
}

class _IntroducePageState extends State<IntroducePage> {
  HomeBloc _homeBloc = HomeBloc();

  String clubId;
  String _token;
  bool _isTokenExpired = true;
  bool _shouldShow = false;
  String _errorText = "";
  bool _isLoading = false;

  void getToken() async {
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
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
    clubId = routeArgs['clubId'];
    if (routeArgs['clubId'] != null)
      _homeBloc.requestPageIntroduce(routeArgs['clubId']);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Giới thiệu trang"), elevation: 0),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: AppTheme.appBarSize),
              child: StreamBuilder<ApiResponse<Profile>>(
                  stream: _homeBloc.pageIntroStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      switch (snapshot.data.status) {
                        case Status.LOADING:
                          return UILoading();
                        case Status.COMPLETED:
                          Profile profile = snapshot.data.data;
                          return Column(
                            children: <Widget>[
                              Stack(
                                children: <Widget>[
                                  ClipPath(
                                    clipper: DetailClipper(),
                                    child: Container(
                                      height: 100,
                                      decoration:
                                          BoxDecoration(color: Colors.red),
                                    ),
                                  ),
                                  Positioned(
                                    right:
                                        MediaQuery.of(context).size.width / 2 -
                                            50,
                                    top: 0,
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: profile.avatar == null
                                          ? AssetImage(
                                              "assets/images/avatar.png")
                                          : CachedNetworkImageProvider(
                                              profile.avatar),
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          profile.ratingAvg
                                                  .toStringAsFixed(1) ??
                                              "0",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Icon(Icons.star, color: Colors.amber),
                                        Text(
                                            "(${profile.ratingCount ?? "0"} đánh giá)"),
                                        SizedBox(
                                          width: 28,
                                        ),
                                        FlatButton.icon(
                                            padding: EdgeInsets.all(0),
                                            onPressed: () {
                                              if (_token == null ||
                                                  _token.length == 0) {
                                                Helper.showAuthenticationDialog(
                                                    context);
                                              } else {
                                                if (_isTokenExpired) {
                                                  Helper.showTokenExpiredDialog(
                                                      context);
                                                } else {
                                                  showModalBottomSheet(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        int rating = 5;
                                                        return Container(
                                                          height: 150,
                                                          alignment:
                                                              Alignment.center,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: <Widget>[
                                                              RatingBar.builder(
                                                                initialRating:
                                                                    5,
                                                                minRating: 1,
                                                                direction: Axis
                                                                    .horizontal,
                                                                allowHalfRating:
                                                                    true,
                                                                itemCount: 5,
                                                                itemPadding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            4.0),
                                                                itemBuilder:
                                                                    (context,
                                                                            _) =>
                                                                        Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .amber,
                                                                ),
                                                                onRatingUpdate:
                                                                    (value) {
                                                                  rating = value
                                                                      .toInt();
                                                                },
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  print(
                                                                      "uprating");
                                                                  _homeBloc
                                                                      .requestRatingClub(
                                                                          jsonEncode({
                                                                    "userId":
                                                                        profile
                                                                            .id,
                                                                    "rating":
                                                                        rating
                                                                  }));
                                                                  _homeBloc
                                                                      .ratingIntroStream
                                                                      .listen(
                                                                          (event) {
                                                                    if (event
                                                                        .data) {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              true);
                                                                    }
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      border: Border.all(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              Colors.grey)),
                                                                  height: 45,
                                                                  width: 250,
                                                                  child: Center(
                                                                    child: Text(
                                                                      'Gửi đánh giá',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          color: Colors
                                                                              .black87,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }).then((value) {
                                                    if (value) {
                                                      _homeBloc
                                                          .requestPageIntroduce(
                                                              clubId);
                                                    }
                                                  });
                                                }
                                              }
                                            },
                                            icon: Icon(
                                              Icons.rate_review,
                                              color: Colors.blue,
                                            ),
                                            label: Text(
                                              "Đánh giá",
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 18),
                                            ))
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    !_shouldShow
                                        ? Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              _errorText.length > 0 &&
                                                      _errorText != null
                                                  ? _errorText
                                                  : "Thông tin bị ẩn, vui lòng nhấn chi tiết để xem thêm",
                                              style: TextStyle(
                                                  color:
                                                      _errorText.length > 0 &&
                                                              _errorText != null
                                                          ? Colors.red
                                                          : Colors.black),
                                            ),
                                          )
                                        : Container(),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          FlatButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              onPressed: () async {
                                                if (profile.isMember) {
                                                  print("push: " + profile.userMemberId);
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          Member2DetailPage
                                                              .ROUTE_NAME,
                                                          arguments: {
                                                        'id': profile
                                                            .userMemberId,
                                                        'title': profile.name
                                                      });
                                                } else {
                                                  Helper.showInputDialog(
                                                      context,
                                                      "Đăng ký thành viên",
                                                      profile.name,
                                                      (value) async {
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                    bool result =
                                                        await _homeBloc
                                                            .requestMember(
                                                                jsonEncode({
                                                      'userId': globals.ownerId,
                                                      'notes': value
                                                    }));
                                                    if (result)
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                    Fluttertoast.showToast(
                                                        msg: "Thành công",
                                                        textColor:
                                                            Colors.black87);
                                                  });
                                                }
                                              },
                                              color: Colors.green,
                                              textColor: Colors.white,
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: 100,
                                                child: Text(
                                                    profile.isMember
                                                        ? "Thông tin"
                                                        : "Đăng ký",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              )),
                                          FlatButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              onPressed: !_shouldShow
                                                  ? () async {
                                                      HiddenResponse response =
                                                          await _homeBloc
                                                              .requestHidden(
                                                                  globals
                                                                      .ownerId,
                                                                  clubId);
                                                      setState(() {
                                                        _shouldShow =
                                                            response.status;
                                                        _errorText =
                                                            response.message ??
                                                                "";
                                                      });
                                                    }
                                                  : null,
                                              color: !_shouldShow
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              textColor: Colors.white,
                                              child: Container(
                                                width: 100,
                                                alignment: Alignment.center,
                                                child: Text("Chi tiết",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ))
                                        ],
                                      ),
                                    ),
                                    _shouldShow
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  profile.type == "Club"
                                                      ? "Tên CLB"
                                                      : "Họ tên",
                                                  style: AppTheme.profileTitle),
                                              Text(profile.name ?? "",
                                                  style: AppTheme.profileInfo),
                                              Container(
                                                height: 0.5,
                                                color: Colors.black12,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 12),
                                              ),
                                              profile.type == "Club"
                                                  ? Container()
                                                  : Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text("Năm sinh",
                                                            style: AppTheme
                                                                .profileTitle),
                                                        Text(
                                                            profile != null &&
                                                                    !profile
                                                                        .hideDOB
                                                                ? profile.dob
                                                                : "**********",
                                                            style: AppTheme
                                                                .profileInfo),
                                                        Container(
                                                          height: 0.5,
                                                          color: Colors.black12,
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 12),
                                                        ),
                                                        Text("Giới tính",
                                                            style: AppTheme
                                                                .profileTitle),
                                                        Text(
                                                            profile.gender ??
                                                                "",
                                                            style: AppTheme
                                                                .profileInfo),
                                                        Container(
                                                          height: 0.5,
                                                          color: Colors.black12,
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 12),
                                                        ),
                                                      ],
                                                    ),
                                              Text("Địa chỉ",
                                                  style: AppTheme.profileTitle),
                                              Text(profile.getAddress ?? "",
                                                  style: AppTheme.profileInfo),
                                              Container(
                                                height: 0.5,
                                                color: Colors.black12,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 12),
                                              ),
                                              Text("Điện thoại",
                                                  style: AppTheme.profileTitle),
                                              Text(profile.phoneNumber ?? "",
                                                  style: AppTheme.profileInfo),
                                              Container(
                                                height: 0.5,
                                                color: Colors.black12,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 12),
                                              ),
                                              Text("Email",
                                                  style: AppTheme.profileTitle),
                                              Text(profile.email ?? "",
                                                  style: AppTheme.profileInfo),
                                            ],
                                          )
                                        : Container(),
                                    Container(
                                      height: 0.5,
                                      color: Colors.black12,
                                      margin:
                                          EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    Text("Giới thiệu",
                                        style: AppTheme.profileTitle),
                                    profile.about != null
                                        ? Html(
                                            data: profile.about,
                                          )
                                        : Text("Chưa có thông tin giới thiệu",
                                            style: AppTheme.profileInfo),
                                    Container(
                                      height: 0.5,
                                      color: Colors.black12,
                                      margin:
                                          EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    Text("Thư viện ảnh",
                                        style: AppTheme.profileTitle),
                                    SizedBox(height: 8),
                                    profile.images != null &&
                                            profile.images.length > 0
                                        ? SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: profile.images
                                                  .map((image) => InkWell(
                                                        onTap: () {
                                                          Navigator.of(context).push(PageRouteBuilder(
                                                              opaque: false,
                                                              pageBuilder: (BuildContext
                                                                          context,
                                                                      _,
                                                                      __) =>
                                                                  ImageViewerIntroPage(
                                                                      profile
                                                                          .images,
                                                                      image
                                                                          .id)));
                                                        },
                                                        child: Container(
                                                          height: 100,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 8),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl: image
                                                                  .fileName,
                                                              placeholder: (context,
                                                                      url) =>
                                                                  Image.asset(
                                                                      "assets/images/placeholder.png",
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Image.asset(
                                                                "assets/images/error.png",
                                                                width: 100,
                                                                height: 100,
                                                              ),
                                                              fit: BoxFit.cover,
                                                              width: 100,
                                                              height: 100,
                                                            ),
                                                          ),
                                                        ),
                                                      ))
                                                  .toList(),
                                            ),
                                          )
                                        : Text("Chưa có ảnh nào"),
//                                Container(
//                                  height: 0.5,
//                                  color: Colors.black12,
//                                  margin: EdgeInsets.symmetric(vertical: 12),
//                                ),
//                                Text("Thư viện video",
//                                    style: AppTheme.profileTitle),
//                                SizedBox(height: 8),
//                                profile.videoLink == null
//                                    ? Container(
//                                        color: Colors.black12,
//                                        height: 200,
//                                        child: Stack(
//                                          children: <Widget>[
//                                            // Center(
//                                            //   child: Image.asset(
//                                            //       "assets/images/placeholder.png",
//                                            //      fit: BoxFit.cover,),
//                                            // ),
//                                            Align(
//                                              alignment: Alignment.center,
//                                              child: InkWell(
//                                                onTap: () {
//                                                  // Navigator.of(context).pushNamed(
//                                                  //     VideoPlayerPage.ROUTE_NAME,
//                                                  //     arguments: {
//                                                  //       "videoLink":
//                                                  //       profile.videoLink ?? "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
//                                                  //     });
//                                                  Navigator.of(context).push(
//                                                      MaterialPageRoute(
//                                                          builder: (context) =>
//                                                              VideoPlayerPage(profile
//                                                                      .videoLink ??
//                                                                  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")));
//                                                },
//                                                child: Icon(
//                                                  Icons.play_arrow,
//                                                  color: Colors.black,
//                                                  size: 58,
//                                                ),
//                                              ),
//                                            )
//                                          ],
//                                        ),
//                                      )
//                                    : Container(),
                                    Container(
                                      height: 0.5,
                                      color: Colors.black12,
                                      margin:
                                          EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    Text("Tin đăng gần đây",
                                        style: AppTheme.profileTitle),
                                    SizedBox(height: 8),
                                    profile.posts.length > 0
                                        ? Container(
                                            color: Colors.black12,
                                            child: GridView.builder(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                scrollDirection: Axis.vertical,
                                                shrinkWrap: true,
                                                itemCount: profile.posts.length,
                                                padding: EdgeInsets.all(4),
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2),
                                                itemBuilder: (_, index) {
                                                  final document = parse(profile
                                                          .posts[index]
                                                          .description ??
                                                      "");
                                                  final String parsedString =
                                                      parse(document.body.text)
                                                          .documentElement
                                                          .text;
                                                  return InkWell(
                                                    onTap: () {
                                                      // Navigator.of(context)
                                                      //     .pushNamed(
                                                      //         ItemDetailPage
                                                      //             .ROUTE_NAME,
                                                      //         arguments: {
                                                      //       'postId': profile
                                                      //           .posts[index]
                                                      //           .postId,
                                                      //       'title': profile
                                                      //           .posts[index]
                                                      //           .title
                                                      //     });
                                                      Helper.navigatorToPost(
                                                          profile.posts[index].postId,
                                                          profile.posts[index].topicId,
                                                          profile.posts[index].title,
                                                          context);
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.all(4),
                                                      child: Stack(
                                                        children: <Widget>[
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            child: Hero(
                                                              tag: profile
                                                                  .posts[index]
                                                                  .postId,
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: profile
                                                                        .posts[
                                                                            index]
                                                                        .thumbnail ??
                                                                    "",
                                                                placeholder: (context,
                                                                        url) =>
                                                                    Image.asset(
                                                                        "assets/images/placeholder.png"),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Image.asset(
                                                                        "assets/images/error.png"),
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: double
                                                                    .infinity,
                                                                height: double
                                                                    .infinity,
                                                              ),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          16),
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                          0xFF0E3311)
                                                                      .withOpacity(
                                                                          0.5),
                                                                  borderRadius: BorderRadius.only(
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              15),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              15))),
                                                              height: 70,
                                                              width: double
                                                                  .infinity,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    profile
                                                                        .posts[
                                                                            index]
                                                                        .title,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: Colors
                                                                            .white),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  Text(
                                                                    parsedString ??
                                                                        "",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .white),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          )
                                        : Text("Chưa có")
                                  ],
                                ),
                              )
                            ],
                          );
                        case Status.ERROR:
                          return UIError(errorMessage: snapshot.data.message);
                      }
                    }
                    return Container();
                  }),
            ),
            _isLoading ? UILoadingOpacity() : Container()
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Text("Nhắn tin"),
          icon: Icon(Icons.chat),
          onPressed: () {
            Navigator.of(context).pushNamed(ChatPage.ROUTE_NAME,
                arguments: {"memberId": clubId});
          },
        ),
      ),
    );
  }
}
