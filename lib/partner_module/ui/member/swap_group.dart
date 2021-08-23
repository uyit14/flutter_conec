import 'package:conecapp/partner_module/models/group_response.dart';
import 'package:conecapp/partner_module/models/members_response.dart';
import 'package:conecapp/partner_module/ui/member/member_bloc.dart';
import 'package:conecapp/partner_module/ui/member/search_group.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SwapGroup extends StatefulWidget {
  static const ROUTE_NAME = 'swap-group';

  @override
  _SwapGroupState createState() => _SwapGroupState();
}

class _SwapGroupState extends State<SwapGroup> {
  Member _member;
  Group _group;
  MemberBloc _memberBloc = MemberBloc();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _member = ModalRoute.of(context).settings.arguments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chuyển lớp")),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          children: [
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Từ lớp",
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 12)),
                    SizedBox(height: 6),
                    Text(_member.groupName ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15)),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 0.5,
                            color: Colors.grey,
                            margin: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        Icon(Icons.swap_vert),
                        Expanded(
                          child: Container(
                            height: 0.5,
                            color: Colors.grey,
                            margin: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ),
                    Text("Đến lớp",
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 12)),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Text(_group != null ? _group.name : "",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 15)),
                        Spacer(),
                        IconButton(
                            icon: Icon(Icons.navigate_next),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(SearchGroupPage.ROUTE_NAME)
                                  .then((value) {
                                if (value != null) {
                                  setState(() {
                                    _group = value;
                                  });
                                }
                              });
                            })
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomCenter,
              child: FlatButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onPressed: () async {
                    if (_group == null) {
                      Fluttertoast.showToast(
                          msg: "Vui lòng chọn lớp muốn chuyển",
                          textColor: Colors.black87);
                      return;
                    }
                    final result = await _memberBloc.requestSwapGroup(
                        _member.id, _group.userGroupId);
                    if (result) {
                      Fluttertoast.showToast(
                          msg: "Chuyển thành công", textColor: Colors.black87);
                      Navigator.of(context).pop(1);
                    } else {
                      Fluttertoast.showToast(
                          msg: "Vui lòng thử lại", textColor: Colors.black87);
                    }
                  },
                  color: Colors.blue,
                  textColor: Colors.white,
                  icon: Icon(Icons.swap_vert),
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 5),
                  label: Text("Chuyển lớp",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500))),
            )
          ],
        ),
      ),
    );
  }
}
