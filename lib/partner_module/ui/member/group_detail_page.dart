import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/partner_module/models/group_response.dart';
import 'package:conecapp/partner_module/models/members_response.dart';
import 'package:conecapp/partner_module/ui/member/member_bloc.dart';
import 'package:flutter/material.dart';

class GroupDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/group-detail';

  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  Group _group;
  List<Member> _members = List();
  MemberBloc _memberBloc = MemberBloc();
  ScrollController _scrollController;
  bool _shouldLoadMore = true;
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context).settings.arguments;
    _group = routeArgs;
    _memberBloc.requestGetMembers(_currentPage, userGroupId: _group.userGroupId);
    _currentPage = 1;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 250) {
      if (_shouldLoadMore) {
        _shouldLoadMore = false;
        _memberBloc.requestGetMembers(_currentPage, userGroupId: _group.userGroupId);
        setState(() {
          _currentPage++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chi tiết")),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6),
              Text("Thông tin nhóm",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
              SizedBox(height: 4),
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Tên nhóm",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 12)),
                      SizedBox(
                        height: 4,
                      ),
                      Text(_group.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          width: double.infinity,
                          height: 0.5,
                          color: Colors.grey),
                      Text("Số lượng thành viên",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 12)),
                      SizedBox(
                        height: 4,
                      ),
                      Text(_group.orderNo.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 15)),
                      Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          width: double.infinity,
                          height: 0.5,
                          color: Colors.grey),
                      Text("Thời gian tập luyện",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 12)),
                      SizedBox(
                        height: 4,
                      ),
                      Text(_group.times ?? "",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 15)),
                      Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          width: double.infinity,
                          height: 0.5,
                          color: Colors.grey),
                      Text("Ghi chú",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 12)),
                      Text(_group.notes ?? "",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text("Danh sách thành viên",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
              Container(
                margin: EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 50),
                child: StreamBuilder<ApiResponse<List<Member>>>(
                    stream: _memberBloc.membersStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        switch (snapshot.data.status) {
                          case Status.LOADING:
                            return UILoading(
                                loadingMessage: snapshot.data.message);
                          case Status.ERROR:
                            return UIError(errorMessage: snapshot.data.message);
                          case Status.COMPLETED:
                            if (snapshot.data.data.length > 0) {
                              print("at UI: " +
                                  snapshot.data.data.length.toString());
                              _members.addAll(snapshot.data.data);
                              _shouldLoadMore = true;
                            } else {
                              _shouldLoadMore = false;
                            }
                            if (_members.length > 0) {
                              return ListView.builder(
                                  itemCount: _members.length,
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
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
                                                Row(
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              100,
                                                      child: Text(
                                                          "Tên thành viên",
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 16)),
                                                    ),
                                                    CircleAvatar(
                                                      radius: 20,
                                                      backgroundColor:
                                                          Colors.grey,
                                                      backgroundImage: _members[
                                                                      index]
                                                                  .avatar !=
                                                              null
                                                          ? NetworkImage(
                                                              _members[index]
                                                                  .avatar)
                                                          : AssetImage(
                                                              "assets/images/avatar.png"),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(height: 4),
                                                Text(_members[index].name ?? "",
                                                    style:
                                                        TextStyle(fontSize: 16)),
                                                Container(
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: 4),
                                                    width: double.infinity,
                                                    height: 0.5,
                                                    color: Colors.grey),
                                                Text("Ngày đóng tiền",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16)),
                                                SizedBox(height: 4),
                                                Text(
                                                    _members[index].paymentDate ??
                                                        "",
                                                    style:
                                                        TextStyle(fontSize: 16)),
                                                Container(
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: 4),
                                                    width: double.infinity,
                                                    height: 0.5,
                                                    color: Colors.grey),
                                                doubleRows("Số điện thoại",
                                                    "Email", true),
                                                SizedBox(height: 4),
                                                doubleRows(
                                                    _members[index].phoneNumber ??
                                                        "",
                                                    _members[index].email ?? "",
                                                    false),
                                                Container(
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: 4),
                                                    width: double.infinity,
                                                    height: 0.5,
                                                    color: Colors.grey),
                                                doubleRows("Ngày tham gia",
                                                    "Ngày đóng tiền", true),
                                                SizedBox(height: 4),
                                                doubleRows(
                                                    _members[index].joinedDate ??
                                                        "",
                                                    _members[index].paymentDate ??
                                                        "",
                                                    false),
                                                Container(
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: 4),
                                                    width: double.infinity,
                                                    height: 0.5,
                                                    color: Colors.grey),
                                                Text("Số tiền",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16)),
                                                SizedBox(height: 4),
                                                Text(
                                                    '${_members[index].amount ?? ""} / ${_members[index].joiningFeePeriod ?? ""}',
                                                    style:
                                                        TextStyle(fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        _members[index].memberId == null
                                            ? Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.deepOrangeAccent,
                                                  size: 24,
                                                ))
                                            : Container()
                                      ],
                                    );
                                  });
                            }
                            return Center(
                                child: Text(
                              "Chưa có thành viên nào",
                              style: TextStyle(fontSize: 18),
                            ));
                        }
                      }
                      return CircularProgressIndicator();
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget doubleRows(String strFirst, strSecond, bool bold) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(strFirst,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w400,
                  fontSize: 16)),
        ),
        Expanded(
          child: Text(strSecond,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w400,
                  fontSize: 16)),
        ),
      ],
    );
  }
}
