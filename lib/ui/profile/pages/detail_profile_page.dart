import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/dummy/dummy_data.dart';
import 'package:conecapp/models/response/profile/profile_response.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:conecapp/ui/profile/pages/edit_profile_page.dart';
import 'package:conecapp/ui/profile/widgets/detail_clipper.dart';
import 'package:flutter/material.dart';

class DetailProfilePage extends StatefulWidget {
  static const ROUTE_NAME = '/detail-profile';

  @override
  _DetailProfilePageState createState() => _DetailProfilePageState();
}

class _DetailProfilePageState extends State<DetailProfilePage> {
  Profile _profile = Profile();

//  var _userInfo = UserInfo(
//      userId: "1",
//      userName: "Nguyễn Văn A",
//      gender: "Nam",
//      birthDay: "20-10-1994",
//      city: "Hồ Chí Minh",
//      district: "Thủ Đức",
//      ward: "Bình Thọ",
//      address: "01 Hữu Nghị",
//      phone: "0987654321",
//      email: "vana.nguyen@gmail.com");
  ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileBloc.requestGetProfile();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Thông tin cá nhân"), elevation: 0),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: AppTheme.appBarSize),
            child: StreamBuilder<ApiResponse<Profile>>(
                stream: _profileBloc.profileStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return UILoading();
                      case Status.COMPLETED:
                        Profile profile = snapshot.data.data;
                        _profile = snapshot.data.data;
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context)
                .pushNamed(EditProfilePage.ROUTE_NAME, arguments: _profile).then((value) {
                  if(value==0){
                    _profileBloc.requestGetPage();
                  }
            });
          },
          backgroundColor: Colors.blue,
          label: Text("Chỉnh sửa"),
          icon: Icon(Icons.edit),
        ),
      ),
    );
  }
}
