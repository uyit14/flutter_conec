import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/partner_module/models/group_response.dart';
import 'package:conecapp/partner_module/ui/member/member_bloc.dart';
import 'package:flutter/material.dart';

class SearchGroupPage extends StatefulWidget {
  static const ROUTE_NAME = '/search-group';

  @override
  _SearchGroupPageState createState() => _SearchGroupPageState();
}

class _SearchGroupPageState extends State<SearchGroupPage> {
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
        appBar: AppBar(title: Text("Chọn nhóm / lớp")),
        body: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
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
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context)
                                            .pop(_groups[index]);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 6),
                                        child: Card(
                                          elevation: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
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
                                                        .memberCount
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
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
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
