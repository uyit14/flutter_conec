import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/dummy/dummy_data.dart';
import 'package:conecapp/models/response/user_info.dart';
import 'package:conecapp/ui/authen/pages/signup_page.dart';
import 'package:conecapp/ui/profile/pages/edit_profile_page.dart';
import 'package:conecapp/ui/profile/widgets/detail_clipper.dart';
import 'package:flutter/material.dart';

class DetailProfilePage extends StatelessWidget {
  static const ROUTE_NAME = '/detail-profile';
  bool _isClub = false;
  var _userInfo = UserInfo(
      userId: "1",
      userName: "Nguyễn Văn A",
      gender: "Nam",
      birthDay: "20-10-1994",
      city: "Hồ Chí Minh",
      district: "Thủ Đức",
      ward: "Bình Thọ",
      address: "01 Hữu Nghị",
      phone: "0987654321",
      email: "vana.nguyen@gmail.com");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thông tin cá nhân"), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: AppTheme.appBarSize),
          child: Column(
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
                    right: MediaQuery.of(context).size.width / 2 - 50,
                    top: 0,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: CachedNetworkImageProvider(DummyData.imgList[0]),
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
                    Text(_isClub ? "Tên CLB" : "Họ tên",
                        style: AppTheme.profileTitle),
                    Text(_userInfo.userName, style: AppTheme.profileInfo),
                    Container(
                      height: 0.5,
                      color: Colors.black12,
                      margin: EdgeInsets.symmetric(vertical: 12),
                    ),
                    _isClub
                        ? Container()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Năm sinh", style: AppTheme.profileTitle),
                              Text(_userInfo.birthDay, style: AppTheme.profileInfo),
                              Container(
                                height: 0.5,
                                color: Colors.black12,
                                margin: EdgeInsets.symmetric(vertical: 12),
                              ),
                              Text("Giới tính", style: AppTheme.profileTitle),
                              Text(_userInfo.gender, style: AppTheme.profileInfo),
                              Container(
                                height: 0.5,
                                color: Colors.black12,
                                margin: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ],
                          ),
                    Text("Địa chỉ", style: AppTheme.profileTitle),
                    Text('${_userInfo.ward}, ${_userInfo.district}, ${_userInfo.city}',
                        style: AppTheme.profileInfo),
                    Container(
                      height: 0.5,
                      color: Colors.black12,
                      margin: EdgeInsets.symmetric(vertical: 12),
                    ),
                    Text("Điện thoại", style: AppTheme.profileTitle),
                    Text(_userInfo.phone, style: AppTheme.profileInfo),
                    Container(
                      height: 0.5,
                      color: Colors.black12,
                      margin: EdgeInsets.symmetric(vertical: 12),
                    ),
                    Text("Email", style: AppTheme.profileTitle),
                    Text(_userInfo.email, style: AppTheme.profileInfo),
                    Container(
                      height: 0.5,
                      color: Colors.black12,
                      margin: EdgeInsets.symmetric(vertical: 12),
                    ),
                    Text("Giới thiệu", style: AppTheme.profileTitle),
                    Text("Chưa có thông tin giới thiệu",
                        style: AppTheme.profileInfo),
                    Container(
                      height: 0.5,
                      color: Colors.black12,
                      margin: EdgeInsets.symmetric(vertical: 12),
                    ),
                    Text("Thư viện ảnh", style: AppTheme.profileTitle),
                    SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: DummyData.imgList[1],
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                Image.asset("assets/images/error.png"),
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        ),
                        SizedBox(width: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: DummyData.imgList[1],
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                Image.asset("assets/images/error.png"),
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 0.5,
                      color: Colors.black12,
                      margin: EdgeInsets.symmetric(vertical: 12),
                    ),
                    Text("Thư viện video", style: AppTheme.profileTitle),
                    SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: DummyData.imgList[1],
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                                errorWidget: (context, url, error) =>
                                    Image.asset("assets/images/error.png"),
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            ),
                            Positioned(
                              top: 38,
                              left: 38,
                              child: Icon(Icons.play_circle_outline,
                                  color: Colors.black),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(EditProfilePage.ROUTE_NAME, arguments: _userInfo);
        },
        backgroundColor: Colors.blue,
        label: Text("Chỉnh sửa"),
        icon: Icon(Icons.edit),
      ),
    );
  }
}
