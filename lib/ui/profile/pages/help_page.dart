import 'dart:convert';

import 'package:conecapp/common/helper.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../common/globals.dart' as globals;

class Reason {
  int id;
  String reason;

  Reason(this.id, this.reason);
}

class HelpPage extends StatefulWidget {
  static const ROUTE_NAME = "help-page";

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  TextEditingController _controller = TextEditingController();
  ProfileBloc _profileBloc = ProfileBloc();
  String _fullName = globals.name;
  String _phoneNumber = globals.phone;
  String _emnail = globals.email;

  int selectedItem = 0;
  bool _isHaveToken = false;

  List<Reason> _reasonList = [
    Reason(0, "Đăng tin"),
    Reason(1, "Sửa tin"),
    Reason(2, "Thanh toán"),
    Reason(3, "Tài khoản"),
    Reason(4, "Khác")
  ];

  String _reason = 'Đăng tin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trợ giúp")),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                "Quý khách cần trợ giúp xin liên hệ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Container(
                height: 0.5,
                color: Colors.grey,
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              Input("Họ tên", (value) {
                setState(() {
                  _fullName = value;
                });
              }, Icons.person, globals.name),
              SizedBox(height: 24),
              Input("Số điện thoại", (value) {
                setState(() {
                  _phoneNumber = value;
                });
              }, Icons.phone, globals.phone),
              SizedBox(height: 24),
              Input("Email", (value) {
                setState(() {
                  _emnail = value;
                });
              }, Icons.email, globals.email),
              SizedBox(height: 24),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Về vấn đề"),
                    SizedBox(height: 2),
                    // DropdownButton<String>(
                    //   value: _reason,
                    //   icon: Icon(Icons.arrow_drop_down),
                    //   iconSize: 24,
                    //   elevation: 16,
                    //   style: TextStyle(color: Colors.black, fontSize: 18),
                    //   onChanged: (String data) {
                    //     setState(() {
                    //       _reason = data;
                    //     });
                    //   },
                    //   items: _reasonList
                    //       .map<DropdownMenuItem<String>>((String value) {
                    //     return DropdownMenuItem<String>(
                    //       value: value,
                    //       child: Text(value),l
                    //     );
                    //   }).toList(),
                    // ),
                    // Container(
                    //   height: 100,
                    //   child: GridView.builder(
                    //       gridDelegate:
                    //           SliverGridDelegateWithFixedCrossAxisCount(
                    //         crossAxisCount: 4,
                    //         childAspectRatio: 0.5,
                    //       ),
                    //       itemCount: _reasonList.length,
                    //       itemBuilder: (context, index) {
                    //         return Card(
                    //           elevation: 5,
                    //           child: Padding(
                    //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    //             child: Row(
                    //               mainAxisSize: MainAxisSize.min,
                    //               children: [
                    //                 Text(
                    //                   "aaaaa",
                    //                   style: TextStyle(color: Colors.black),
                    //                 ),
                    //                 Radio(
                    //                   value: _reasonList[index],
                    //                   groupValue: 0,
                    //                   activeColor: Color.fromRGBO(220, 65, 50, 1),
                    //                   onChanged: (value) {
                    //                     setState(() {
                    //                       _reason = value;
                    //                     });
                    //                   },
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         );
                    //       }),
                    // ),
                    Container(
                      width: double.infinity,
                      child: Wrap(
                        children: _reasonList
                            .map((e) => Container(
                                  margin: EdgeInsets.only(right: 8, bottom: 8),
                                  padding: EdgeInsets.only(left: 8),
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 1, offset: Offset(0, 1))
                                      ],
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Row(
                                    children: [
                                      Text(e.reason),
                                      Radio(
                                        value: e.id,
                                        groupValue: selectedItem,
                                        activeColor:
                                            Color.fromRGBO(220, 65, 50, 1),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedItem = value;
                                            _reason = e.reason;
                                          });
                                        },
                                      ),
                                    ],
                                    mainAxisSize: MainAxisSize.min,
                                  ),
                                ))
                            .toList(),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 24),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nội dung"),
                    SizedBox(height: 2),
                    TextFormField(
                      controller: _controller,
                      maxLines: 7,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontSize: 18),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.green, width: 1)),
                          contentPadding: EdgeInsets.only(left: 8),
                          border: const OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              InkWell(
                onTap: () async {
                  print(_reason);
                  bool result = await _profileBloc.requestReport(jsonEncode({
                    "fullName": _fullName,
                    "phoneNumber": _phoneNumber,
                    "email": _emnail,
                    "content": _controller.text,
                    "reason": _reason
                  }), _isHaveToken);
                  if (result) {
                    Helper.showCompleteDialog(context, "Gửi thành công",
                        "Ý kiến của bạn đã được ghi nhận, chúng tôi sẽ sớm có phải hồi cho bạn");
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 45,
                  child: Center(
                    child: Text(
                      'Gửi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Input extends StatefulWidget {
  final String title;
  final String initValue;
  final Function(String value) onTextChanged;
  final IconData icon;

  Input(this.title, this.onTextChanged, this.icon, this.initValue);

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initValue);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title),
          SizedBox(height: 2),
          TextFormField(
            maxLines: 1,
            controller: _controller,
            textInputAction: TextInputAction.next,
            style: TextStyle(fontSize: 18),
            keyboardType: TextInputType.text,
            onChanged: widget.onTextChanged,
            decoration: InputDecoration(
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 1)),
                contentPadding: EdgeInsets.only(left: 8),
                prefixIcon: Icon(
                  widget.icon,
                  color: Colors.black,
                ),
                border: const OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}
