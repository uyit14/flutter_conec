import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/page/page_response.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:conecapp/ui/profile/pages/edit_info_page.dart';
import 'package:conecapp/ui/profile/pages/video_player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class InfoPage extends StatefulWidget {
  static const ROUTE_NAME = "/page-info";

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  ProfileBloc _profileBloc = ProfileBloc();
  Profile _profile = Profile();

  @override
  void initState() {
    super.initState();
    _profileBloc.requestGetPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thông tin trang")),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: AppTheme.appBarSize),
        child: StreamBuilder<ApiResponse<Profile>>(
            stream: _profileBloc.pageStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    return UILoading();
                  case Status.COMPLETED:
                    Profile profile = snapshot.data.data;
                    _profile = snapshot.data.data;
                    return Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Giới thiệu", style: AppTheme.profileTitle),
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
                          Text("Thư viện ảnh", style: AppTheme.profileTitle),
                          SizedBox(height: 8),
                          profile.images != null && profile.images.length > 0
                              ? Row(
                                  children: profile.images
                                      .map((image) => Container(
                                            margin: EdgeInsets.only(right: 8),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: CachedNetworkImage(
                                                imageUrl: image.fileName,
                                                placeholder: (context, url) =>
                                                    Image.asset(
                                                        "assets/images/placeholder.png",
                                                        width: 100,
                                                        height: 100),
                                                errorWidget:
                                                    (context, url, error) =>
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
                          Text("Thư viện video", style: AppTheme.profileTitle),
                          SizedBox(height: 8),
                          _profile.videoLink == null
                              ? Container(
                                  color: Colors.black12,
                                  height: 200,
                                  child: Stack(
                                    children: <Widget>[
                                      // Center(
                                      //   child: Image.asset(
                                      //       "assets/images/placeholder.png",
                                      //      fit: BoxFit.cover,),
                                      // ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: InkWell(
                                          onTap: () {
                                            // Navigator.of(context).pushNamed(
                                            //     VideoPlayerPage.ROUTE_NAME,
                                            //     arguments: {
                                            //       "videoLink":
                                            //           _profile.videoLink ?? "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
                                            //     });
                                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoPlayerPage(_profile.videoLink ?? "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")));
                                          },
                                          child: Icon(
                                            Icons.play_arrow,
                                            color: Colors.black,
                                            size: 58,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    );
                  case Status.ERROR:
                    return UIError(errorMessage: snapshot.data.message);
                }
              }
              return Container();
            }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context)
              .pushNamed(EditInfoPage.ROUTE_NAME, arguments: _profile)
              .then((value) {
            if (value == 0) {
              print("0");
              _profileBloc.requestGetPage();
            }
          });
        },
        backgroundColor: Colors.blue,
        label: Text("Chỉnh sửa"),
        icon: Icon(Icons.edit),
      ),
    );
  }
}
