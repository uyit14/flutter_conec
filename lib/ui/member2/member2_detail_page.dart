import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/member2/member2_detail_response.dart';
import 'package:conecapp/ui/profile/widgets/detail_clipper.dart';
import 'package:flutter/material.dart';

import 'member2_bloc.dart';

enum TYPE { ADDRESS, NAME, PHONE, EMAIL, GROUP }

class Member2DetailPage extends StatefulWidget {
  static const ROUTE_NAME = "/member2-detail";

  @override
  _Member2DetailPageState createState() => _Member2DetailPageState();
}

class _Member2DetailPageState extends State<Member2DetailPage> {
  Member2Bloc _memberBloc = Member2Bloc();
  Member2Detail _member = Member2Detail();
  String id;
  String title;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    id = routeArgs['id'];
    title = routeArgs['title'];
    _memberBloc.requestGetMember2Detail(id);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text("Thông tin CLB/ HLV")),
      body: Container(
        margin: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: StreamBuilder<ApiResponse<Member2Detail>>(
              stream: _memberBloc.member2DetailStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  switch (snapshot.data.status) {
                    case Status.LOADING:
                      return UILoading(loadingMessage: snapshot.data.message);
                    case Status.ERROR:
                      return UIError(errorMessage: snapshot.data.message);
                    case Status.COMPLETED:
                      _member = snapshot.data.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  backgroundColor: Colors.grey,
                                  backgroundImage: _member.userAvatar == null
                                      ? AssetImage("assets/images/avatar.png")
                                      : CachedNetworkImageProvider(
                                          _member.userAvatar),
                                ),
                              )
                            ],
                          ),
                          Card(
                            elevation: 4,
                            margin: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 12),
                                infoCard(title ?? "", TYPE.NAME),
                                // SizedBox(height: 8),
                                // infoCard(_member.userName ?? "Họ tên", TYPE.NAME),
                                infoCard(
                                    _member.userPhoneNumber ?? "Số điện thoại",
                                    TYPE.PHONE),
                                infoCard(
                                    _member.userEmail ?? "Email", TYPE.EMAIL),
                                infoCard(
                                    _member.userAddress ?? "", TYPE.ADDRESS),
                                infoCard(_member.group ?? "", TYPE.GROUP),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text("Ngày tham gia"),
                          Card(
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(Icons.date_range, color: Colors.blue),
                                    SizedBox(width: 16),
                                    Text(
                                      _member.joinedDate ?? "",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text("Thông tin đóng Học phí"),
                          SizedBox(height: 4),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _member.payment2s.length,
                              itemBuilder: (context, index) {
                                List<Payment2> _payment = _member.payment2s;
                                return Stack(
                                  children: [
                                    Card(
                                      elevation: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Ngày đóng",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            SizedBox(height: 4),
                                            Text(
                                                _payment[index].paymentDate ??
                                                    "",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: _payment[index]
                                                            .status
                                                            .startsWith("C")
                                                        ? Colors.red
                                                        : Colors.green)),
                                            Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 4),
                                                width: double.infinity,
                                                height: 0.5,
                                                color: Colors.grey),
                                            Text("Số tiền",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            SizedBox(height: 4),
                                            Text(
                                                _payment[index]
                                                        .amount
                                                        .toString() ??
                                                    "",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: _payment[index]
                                                            .status
                                                            .startsWith("C")
                                                        ? Colors.red
                                                        : Colors.green)),
                                            Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 4),
                                                width: double.infinity,
                                                height: 0.5,
                                                color: Colors.grey),
                                            Text("Trạng thái",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            SizedBox(height: 4),
                                            Text(_payment[index].status,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: _payment[index]
                                                            .status
                                                            .startsWith("C")
                                                        ? Colors.red
                                                        : Colors.green)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              })
                        ],
                      );
                  }
                }
                return Center(child: CircularProgressIndicator());
              }),
        ),
      ),
    ));
  }

  Icon iconByType(TYPE type) {
    switch (type) {
      case TYPE.ADDRESS:
        return Icon(Icons.location_on, color: Colors.blue);
      case TYPE.NAME:
        return Icon(Icons.perm_identity_rounded, color: Colors.blue);
      case TYPE.PHONE:
        return Icon(Icons.phone_android, color: Colors.blue);
      case TYPE.EMAIL:
        return Icon(Icons.email, color: Colors.blue);
      case TYPE.GROUP:
        return Icon(Icons.group, color: Colors.blue);
      default:
        return Icon(Icons.email, color: Colors.blue);
    }
  }

  Widget infoCard(String info, TYPE type) {
    return InkWell(
      onTap: null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: <Widget>[
            iconByType(type),
            SizedBox(width: 16),
            Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Text(
                info,
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }
}
