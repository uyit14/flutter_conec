import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/partner_module/models/requestsmember_response.dart';
import 'package:conecapp/partner_module/ui/member/accept_request.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'member_bloc.dart';

class RequestPage extends StatefulWidget {
  static const ROUTE_NAME = '/request-page';

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  MemberBloc _memberBloc = MemberBloc();

  @override
  void initState() {
    super.initState();
    _memberBloc.requestGetMemberRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yêu cầu kết nạp")),
      body: Container(
        child: StreamBuilder<ApiResponse<List<Request>>>(
            stream: _memberBloc.requestStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    return UILoading(loadingMessage: snapshot.data.message);
                  case Status.ERROR:
                    return UIError(errorMessage: snapshot.data.message);
                  case Status.COMPLETED:
                    List<Request> requests = snapshot.data.data;
                    if (requests.length > 0) {
                      return ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              child: Card(
                                color: Colors.white70,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(requests[index].name,
                                          style: TextStyle(fontSize: 16)),
                                      SizedBox(height: 4),
                                      Text(requests[index].notes,
                                          style: TextStyle(fontSize: 13)),
                                      SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          FlatButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              onPressed: () async {
                                                Navigator.of(context)
                                                    .pushNamed(
                                                        AcceptRequestPage
                                                            .ROUTE_NAME,
                                                        arguments:
                                                            requests[index])
                                                    .then((value) => _memberBloc
                                                        .requestGetMemberRequest());
                                              },
                                              color: Colors.blue,
                                              textColor: Colors.white,
                                              child: Text("Xác nhận",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500))),
                                          SizedBox(width: 8),
                                          FlatButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 42),
                                              onPressed: () {
                                                Helper.showDeleteDialog(
                                                    context,
                                                    "Xóa yêu cầu",
                                                    "Bạn có chắc chắn muốn xóa yêu cầu này?",
                                                    () async {
                                                  final result =
                                                      await _memberBloc
                                                          .requestDeleteGroup(
                                                              requests[index]
                                                                  .id);
                                                  if (result) {
                                                    Fluttertoast.showToast(
                                                        msg: "Xóa thành công",
                                                        gravity: ToastGravity
                                                            .CENTER);
                                                    Navigator.of(context)
                                                        .pop(1);
                                                    Navigator.of(context)
                                                        .pop(1);
                                                  } else {
                                                    Navigator.of(context).pop();
                                                    Fluttertoast.showToast(
                                                        msg: "Vui lòng thử lại",
                                                        gravity: ToastGravity
                                                            .CENTER);
                                                  }
                                                });
                                              },
                                              color: Colors.grey,
                                              textColor: Colors.white,
                                              child: Text("Xóa",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500)))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    }
                    return Center(
                        child: Text(
                      "Chưa có yêu cầu nào",
                      style: TextStyle(fontSize: 18),
                    ));
                }
              }
              return CircularProgressIndicator();
            }),
      ),
    );
  }
}
