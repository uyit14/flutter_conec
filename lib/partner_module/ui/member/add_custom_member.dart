import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/partner_module/models/search_m_response.dart';
import 'package:conecapp/ui/profile/widgets/detail_clipper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CustomMemberPage extends StatefulWidget {
  static const ROUTE_NAME = '/custom-member';

  @override
  _CustomMemberPageState createState() => _CustomMemberPageState();
}

class _CustomMemberPageState extends State<CustomMemberPage> {
  File _image;
  final picker = ImagePicker();
  String _avatar;
  String _name;
  String _email;
  String _phone;
  String _userName;

  Future getImageAvatar(bool isCamera) async {
    final pickedFile = await picker.getImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(title: Text("Thêm thành viên")),
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        final act = CupertinoActionSheet(
                            actions: <Widget>[
                              CupertinoActionSheetAction(
                                child: Text('Chụp ảnh',
                                    style: TextStyle(color: Colors.blue)),
                                onPressed: () => getImageAvatar(true),
                              ),
                              CupertinoActionSheetAction(
                                child: Text('Chọn từ thư viện',
                                    style: TextStyle(color: Colors.blue)),
                                onPressed: () => getImageAvatar(false),
                              )
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: Text('Hủy'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ));
                        showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) => act);
                      },
                      child: Stack(
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
                              backgroundImage: _image == null
                                  ? (_avatar == null
                                      ? AssetImage("assets/images/avatar.png")
                                      : CachedNetworkImageProvider(_avatar))
                                  : FileImage(_image),
                            ),
                          ),
                          Positioned(
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  ThemeData.light().scaffoldBackgroundColor,
                              child: Container(
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey,
                                ),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black12),
                              ),
                            ),
                            top: 65,
                            right: MediaQuery.of(context).size.width / 2 - 50,
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        children: [
                          SizedBox(height: 12),
                          TextFormField(
                            //controller: _nameController,
                            maxLines: 1,
                            style: TextStyle(fontSize: 18),
                            textInputAction: TextInputAction.done,
                            initialValue: _userName ?? "",
                            onChanged: (value) {
                              setState(() {
                                _userName = value;
                              });
                            },
                            decoration: InputDecoration(
                                hintText: 'Tên tài khoản',
                                //errorText: _nameValidate ? "Vui lòng nhập họ tên" : null,
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.green, width: 1)),
                                contentPadding: EdgeInsets.only(left: 8),
                                prefixIcon: Icon(
                                  Icons.account_box,
                                  color: Colors.black,
                                ),
                                border: const OutlineInputBorder()),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            //controller: _nameController,
                            maxLines: 1,
                            style: TextStyle(fontSize: 18),
                            textInputAction: TextInputAction.done,
                            initialValue: _name ?? "",
                            onChanged: (value) {
                              setState(() {
                                _name = value;
                              });
                              print(_name);
                            },
                            decoration: InputDecoration(
                                hintText: 'Họ và tên',
                                //errorText: _nameValidate ? "Vui lòng nhập họ tên" : null,
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.green, width: 1)),
                                contentPadding: EdgeInsets.only(left: 8),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.black,
                                ),
                                border: const OutlineInputBorder()),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            maxLines: 1,
                            style: TextStyle(fontSize: 18),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            initialValue: _email ?? "",
                            onChanged: (value) {
                              _email = value;
                            },
                            decoration: InputDecoration(
                                hintText: 'Email',
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.green, width: 1)),
                                contentPadding: EdgeInsets.only(left: 8),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Colors.black,
                                ),
                                border: const OutlineInputBorder()),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            maxLines: 1,
                            style: TextStyle(fontSize: 18),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            initialValue: _phone ?? "",
                            onChanged: (value) {
                              setState(() {
                                _phone = value;
                              });
                            },
                            decoration: InputDecoration(
                                hintText: 'Số điện thoại',
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.green, width: 1)),
                                contentPadding: EdgeInsets.only(left: 8),
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: Colors.black,
                                ),
                                border: const OutlineInputBorder()),
                          ),
                          SizedBox(height: 16),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: FlatButton.icon(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                onPressed: () async {
                                  if (!_isPostButtonEnable()) {
                                    Helper.showFailDialog(context);
                                  } else {
                                    doAddAction(context);
                                  }
                                },
                                color: Colors.green,
                                textColor: Colors.white,
                                icon: Icon(Icons.check),
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width / 5),
                                label: Text("Lưu lại",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500))),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }

  bool _isPostButtonEnable() {
    if (_name == null || _phone == null || _userName == null) {
      return false;
    }
    return true;
  }

  void doAddAction(BuildContext context) async {
    MemberSearch _member = MemberSearch(
        phoneNumber: _phone,
        email: _email,
        name: _name,
        userName: _userName,
        avatarSource: _image);
    Navigator.of(context).pop(_member);
  }
}
