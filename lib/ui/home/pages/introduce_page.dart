import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/page/page_response.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:conecapp/ui/profile/widgets/detail_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:video_player/video_player.dart';

import 'item_detail_page.dart';

class IntroducePage extends StatefulWidget {
  static const ROUTE_NAME = "/intro-page";

  @override
  _IntroducePageState createState() => _IntroducePageState();
}

class _IntroducePageState extends State<IntroducePage> {
  HomeBloc _homeBloc = HomeBloc();
  VideoPlayerController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    _homeBloc.requestPageIntroduce(
        routeArgs['clubId'] ?? "40fcdb4a-6c82-4150-be23-4509a7d64ec6");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Giới thiệu trang"), elevation: 0),
        body: SingleChildScrollView(
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
                      //
                      _controller =
                          VideoPlayerController.network("http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4")
                            ..initialize().then((_) {
                              // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                              setState(() {});
                              print("initVideo");
                            });
                      return Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              ClipPath(
                                clipper: DetailClipper(),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(color: Colors.red),
                                ),
                              ),
                              Positioned(
                                right:
                                    MediaQuery.of(context).size.width / 2 - 50,
                                top: 0,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: profile.avatar == null
                                      ? AssetImage("assets/images/avatar.png")
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
                                  margin: EdgeInsets.symmetric(vertical: 12),
                                ),
                                profile.type == "Club"
                                    ? Container()
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Năm sinh",
                                              style: AppTheme.profileTitle),
                                          Text(profile.dob ?? "",
                                              style: AppTheme.profileInfo),
                                          Container(
                                            height: 0.5,
                                            color: Colors.black12,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                          Text("Giới tính",
                                              style: AppTheme.profileTitle),
                                          Text(profile.gender ?? "",
                                              style: AppTheme.profileInfo),
                                          Container(
                                            height: 0.5,
                                            color: Colors.black12,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                        ],
                                      ),
                                Text("Địa chỉ", style: AppTheme.profileTitle),
                                Text(
                                    profile.province == null
                                        ? ""
                                        : '${profile.ward ?? ""}, ${profile.district ?? ""}, ${profile.province ?? ""}',
                                    style: AppTheme.profileInfo),
                                Container(
                                  height: 0.5,
                                  color: Colors.black12,
                                  margin: EdgeInsets.symmetric(vertical: 12),
                                ),
                                Text("Điện thoại",
                                    style: AppTheme.profileTitle),
                                Text(profile.phoneNumber ?? "",
                                    style: AppTheme.profileInfo),
                                Container(
                                  height: 0.5,
                                  color: Colors.black12,
                                  margin: EdgeInsets.symmetric(vertical: 12),
                                ),
                                Text("Email", style: AppTheme.profileTitle),
                                Text(profile.email ?? "",
                                    style: AppTheme.profileInfo),
                                Container(
                                  height: 0.5,
                                  color: Colors.black12,
                                  margin: EdgeInsets.symmetric(vertical: 12),
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
                                  margin: EdgeInsets.symmetric(vertical: 12),
                                ),
                                Text("Thư viện ảnh",
                                    style: AppTheme.profileTitle),
                                SizedBox(height: 8),
                                profile.images != null &&
                                        profile.images.length > 0
                                    ? Row(
                                        children: profile.images
                                            .map((image) => Container(
                                                  margin:
                                                      EdgeInsets.only(right: 8),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    child: CachedNetworkImage(
                                                      imageUrl: image.fileName,
                                                      progressIndicatorBuilder: (context,
                                                              url,
                                                              downloadProgress) =>
                                                          CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress),
                                                      placeholder: (context,
                                                              url) =>
                                                          Image.asset(
                                                              "assets/images/placeholder.png",
                                                              width: 100,
                                                              height: 100),
                                                      errorWidget: (context,
                                                              url, error) =>
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
                                                ))
                                            .toList(),
                                      )
                                    : Text("Chưa có ảnh nào"),
                                Container(
                                  height: 0.5,
                                  color: Colors.black12,
                                  margin: EdgeInsets.symmetric(vertical: 12),
                                ),
                                Text("Thư viện video",
                                    style: AppTheme.profileTitle),
                                SizedBox(height: 8),
                                Container(
                                  child: Stack(
                                    children: <Widget>[
                                      _controller.value.initialized ? AspectRatio(
                                          aspectRatio:
                                              _controller.value.aspectRatio,
                                          child: VideoPlayer(_controller)) : Container(),
                                      Align(
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          icon: Icon(
                                            _controller.value.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _controller.value.isPlaying
                                                  ? _controller.pause()
                                                  : _controller.play();
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 0.5,
                                  color: Colors.black12,
                                  margin: EdgeInsets.symmetric(vertical: 12),
                                ),
                                Text("Tin đăng gần đây",
                                    style: AppTheme.profileTitle),
                                SizedBox(height: 8),
                                Container(
                                  child: GridView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: profile.posts.length,
                                      padding: EdgeInsets.all(4),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2),
                                      itemBuilder: (_, index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                                ItemDetailPage.ROUTE_NAME,
                                                arguments: {
                                                  'postId': profile.posts[index].postId,
                                                  'title': profile.posts[index].title
                                                });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.all(4),
                                            child: Stack(
                                              children: <Widget>[
                                                index < 4 ? Banner(
                                                  message: "Mới",
                                                  location: BannerLocation.topEnd,
                                                  color: Colors.green,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(15),
                                                    child: Hero(
                                                      tag: profile.posts[index].postId,
                                                      child: CachedNetworkImage(
                                                        imageUrl: profile.posts[index].thumbnail ?? "",
                                                        progressIndicatorBuilder: (context, url,
                                                            downloadProgress) =>
                                                            CircularProgressIndicator(
                                                                value:
                                                                downloadProgress.progress),
                                                        placeholder: (context,
                                                            url) =>
                                                            Image.asset(
                                                                "assets/images/placeholder.png"),
                                                        errorWidget: (context, url, error) =>
                                                            Image.asset(
                                                                "assets/images/error.png"),
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                      ),
                                                    ),
                                                  ),
                                                ) : Container(),
                                                Align(
                                                  alignment: Alignment.bottomCenter,
                                                  child: Container(
                                                    padding:
                                                    EdgeInsets.symmetric(horizontal: 16),
                                                    decoration: BoxDecoration(
                                                        color:
                                                        Color(0xFF0E3311).withOpacity(0.5),
                                                        borderRadius: BorderRadius.only(
                                                            bottomLeft: Radius.circular(15),
                                                            bottomRight: Radius.circular(15))),
                                                    height: 70,
                                                    width: double.infinity,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Text(
                                                          profile.posts[index].title,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.white),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        Text(
                                                          profile.posts[index].description ?? "",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.white),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}