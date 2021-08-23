import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/partner_module/models/group_response.dart';
import 'package:conecapp/partner_module/ui/member/add_group_page.dart';
import 'package:conecapp/partner_module/ui/member/group_detail_page.dart';
import 'package:conecapp/partner_module/ui/member/member_bloc.dart';
import 'package:conecapp/partner_module/ui/member/member_page.dart';
import 'package:conecapp/partner_module/ui/member/update_group_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MemberGroupPage extends StatefulWidget {
  static const ROUTE_NAME = '/member-group';

  @override
  _MemberGroupPageState createState() => _MemberGroupPageState();
}

class _MemberGroupPageState extends State<MemberGroupPage> {
  MemberBloc _memberBloc = MemberBloc();
  String groupId;

  @override
  void initState() {
    super.initState();
    _memberBloc.requestGetGroup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Thành viên")),
        body: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FlatButton.icon(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.blue,
                                  width: 1,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(50)),
                          textColor: Colors.black,
                          color: Colors.blue,
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AddGroupPage.ROUTE_NAME)
                                .then((value) {
                              if (value == 1) {
                                _memberBloc.requestGetGroup();
                              }
                            });
                          },
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text("Thêm nhóm",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white))),
                      FlatButton(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.green,
                                  width: 1,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(50)),
                          textColor: Colors.black,
                          color: Colors.green,
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(MemberPage.ROUTE_NAME, arguments: groupId);
                          },
                          child: Text("Tất cả thành viên",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white))),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text("Danh sách nhóm"),
                  SizedBox(height: 4),
                  StreamBuilder<ApiResponse<List<Group>>>(
                      stream: _memberBloc.groupSearchStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          switch (snapshot.data.status) {
                            case Status.LOADING:
                              return UILoading(
                                  loadingMessage: snapshot.data.message);
                            case Status.ERROR:
                              return UIError(
                                  errorMessage: snapshot.data.message);
                            case Status.COMPLETED:
                              List<Group> _groups = snapshot.data.data;
                              return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _groups.length,
                                  itemBuilder: (context, index) {
                                    ColorNotify _colorN = Helper.getColorGroup(
                                        _groups[index].color);
                                    String _status = Helper.statusResponse(
                                        _groups[index].active);
                                    return Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 6),
                                          child: Card(
                                            elevation: 5,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text("Tên nhóm",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 12)),
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(_groups[index].name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16)),
                                                  Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 4),
                                                      width: double.infinity,
                                                      height: 0.5,
                                                      color: Colors.grey),
                                                  Text("Số lượng thành viên",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 12)),
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(
                                                      _groups[index]
                                                          .orderNo
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 15)),
                                                  Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 4),
                                                      width: double.infinity,
                                                      height: 0.5,
                                                      color: Colors.grey),
                                                  Text("Thời gian tập luyện: ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 12)),
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(_groups[index].times ?? "",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 15)),
                                                  Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 4),
                                                      width: double.infinity,
                                                      height: 0.5,
                                                      color: Colors.grey),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text("Màu",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 12)),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            "Trạng thái",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 4),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                            _colorN.text,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: _colorN
                                                                    .color,
                                                                fontSize: 14)),
                                                      ),
                                                      Expanded(
                                                        child: Text(_status,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: _groups[
                                                                            index]
                                                                        .active
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red,
                                                                fontSize: 15)),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            right: -12,
                                            top: -7,
                                            child: PopupMenuButton(
                                              itemBuilder: (context) {
                                                return [
                                                  PopupMenuItem(
                                                    value: 'detail',
                                                    child: Text('Chi tiết'),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text('Chỉnh sửa'),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text('Xóa lớp'),
                                                  )
                                                ];
                                              },
                                              onSelected: (String value) {
                                                if (value == "delete") {
                                                  Helper.showDeleteDialog(
                                                      context,
                                                      "Xóa thành viên",
                                                      "Bạn có chắc chắn muốn xóa nhóm này?",
                                                      () async {
                                                    final result =
                                                        await _memberBloc
                                                            .requestDeleteGroup(
                                                                _groups[index]
                                                                    .userGroupId);
                                                    if (result) {
                                                      _groups.removeWhere(
                                                          (element) =>
                                                              element
                                                                  .userGroupId ==
                                                              _groups[index]
                                                                  .userGroupId);
                                                      setState(() {});
                                                      Navigator.of(context)
                                                          .pop();
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Vui lòng thử lại",
                                                          gravity: ToastGravity
                                                              .CENTER);
                                                    }
                                                  });
                                                } else if (value == "edit") {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          UpdateGroupPage
                                                              .ROUTE_NAME,
                                                          arguments:
                                                              _groups[index])
                                                      .then((value) {
                                                    if (value == 1) {
                                                      _memberBloc
                                                          .requestGetGroup();
                                                    }
                                                  });
                                                } else if (value == "detail") {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          GroupDetailPage
                                                              .ROUTE_NAME,
                                                          arguments:
                                                              _groups[index]);
                                                }
                                              },
                                            ))
                                      ],
                                    );
                                  });
                          }
                        }
                        return Center(child: CircularProgressIndicator());
                      }),
                ],
              )),
        ));
  }
}
