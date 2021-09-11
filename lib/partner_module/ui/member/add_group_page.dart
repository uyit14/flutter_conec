import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/partner_module/models/group_request.dart';
import 'package:conecapp/partner_module/ui/member/member_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddGroupPage extends StatefulWidget {
  static const ROUTE_NAME = '/add-group';

  @override
  _AddGroupPageState createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  MemberBloc _memberBloc = MemberBloc();
  bool _isLoading = false;
  String selectedStatus = Helper.statusList[0];
  String _title;
  int _orderNo = 1;
  String notes;
  String _time;

  int tag = 0;

  Color getColorByTag(int mTag) {
    switch (mTag) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.blue[300];
      case 4:
        return Colors.yellow[700];
      case 5:
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  bool _isPostButtonEnable() {
    if (_title == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bool _showFab = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Thêm nhóm"),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tên nhóm *"),
                  TextFormField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 18),
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        setState(() {
                          _title = value;
                        });
                      }),
                  SizedBox(height: 12),
                  Text("Thứ tự"),
                  TextFormField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 18),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _orderNo = int.parse(value);
                        });
                      }),
                  SizedBox(height: 12),
                  // Text("Màu sắc"),
                  // ChipsChoice<int>.single(
                  //   value: tag,
                  //   wrapped: true,
                  //   onChanged: (val) => setState(() => tag = val),
                  //   choiceItems: C2Choice.listFrom<int, String>(
                  //     source: Helper.options,
                  //     value: (i, v) => i,
                  //     label: (i, v) => v,
                  //     style: (i, v) {
                  //       return C2ChoiceStyle(
                  //           color: getColorByTag(i),
                  //           showCheckmark: i == tag,
                  //           labelStyle: TextStyle(
                  //               fontWeight: i == tag
                  //                   ? FontWeight.bold
                  //                   : FontWeight.w400));
                  //     },
                  //   ),
                  // ),
                  // SizedBox(height: 12),
                  Text("Trạng thái"),
                  Row(
                    children: Helper.statusList
                        .map((e) => Row(
                              children: [
                                Radio(
                                  value: e,
                                  groupValue: selectedStatus,
                                  activeColor: Color.fromRGBO(220, 65, 50, 1),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedStatus = value;
                                    });
                                  },
                                ),
                                Text(e, style: TextStyle(fontSize: 18)),
                                SizedBox(width: 12)
                              ],
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 12),
                  Text("Thời gian tập luyện"),
                  TextFormField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 18),
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        setState(() {
                          _time = value;
                        });
                      }),
                  SizedBox(height: 12),
                  Text("Ghi chú"),
                  SizedBox(height: 4),
                  TextFormField(
                      style: TextStyle(fontSize: 18),
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        setState(() {
                          notes = value;
                        });
                      }),
                  SizedBox(height: 16),
                  //STEP 9
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        onPressed: () async {
                          if (!_isPostButtonEnable()) {
                            Helper.showFailDialog(context);
                          } else {
                            setState(() {
                              _isLoading = true;
                            });
                            doAddAction();
                          }
                        },
                        color: Colors.green,
                        textColor: Colors.white,
                        icon: Icon(Icons.check),
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 5),
                        label: Text("Lưu lại",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500))),
                  )
                ],
              ),
            ),
          ),
          _isLoading ? UILoadingOpacity() : Container()
        ],
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton.extended(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              backgroundColor: Colors.green,
              label: Text("Xong"),
              icon: Icon(Icons.check),
            )
          : null,
    ));
  }

  void doAddAction() async {
    GroupRequest _groupRequest = GroupRequest(
        name: _title,
        //color: Helper.paramsGroup[tag],
        notes: notes,
        orderNo: _orderNo,
        times: _time,
        active: Helper.statusRequest(selectedStatus));
    //
    print("add_groupy_request: " + jsonEncode(_groupRequest.toJson()));
    final result =
        await _memberBloc.addGroup(jsonEncode(_groupRequest.toJson()));
    if (result) {
      setState(() {
        _isLoading = false;
      });
      Helper.showOKDialog(context, () {
        Navigator.of(context).pop();
        Navigator.of(context).pop(1);
      }, "Thêm thành công");
    } else {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Vui lòng thử lại", textColor: Colors.black87);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _memberBloc.dispose();
  }
}
