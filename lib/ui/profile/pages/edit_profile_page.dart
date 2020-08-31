import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/custom_icons.dart';
import 'package:conecapp/dummy/dummy_data.dart';
import 'package:conecapp/models/response/profile/profile_response.dart';
import 'package:conecapp/ui/profile/widgets/detail_clipper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  static const ROUTE_NAME = '/edit-profile';

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File _image;
  final picker = ImagePicker();

  Future getImage(bool isCamera) async {
    final pickedFile = await picker.getImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool _showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    final routeArgs = ModalRoute.of(context).settings.arguments;
    Profile profile = routeArgs;
    return Scaffold(
      appBar: AppBar(title: Text("Chỉnh sửa thông tin"), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: AppTheme.appBarSize),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  final act = CupertinoActionSheet(
                      actions: <Widget>[
                        CupertinoActionSheetAction(
                          child: Text('Chụp ảnh',
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () =>  getImage(true),
                        ),
                        CupertinoActionSheetAction(
                          child: Text('Chọn từ thư viện',
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () => getImage(false),
                        )
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        child: Text('Hủy'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ));
                  showCupertinoModalPopup(
                      context: context, builder: (BuildContext context) => act);
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
                            ? CachedNetworkImageProvider(DummyData.imgList[0])
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
                              shape: BoxShape.circle, color: Colors.black12),
                        ),
                      ),
                      top: 65,
                      right: MediaQuery.of(context).size.width / 2 - 50,
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        //controller: _nameController,
                        maxLines: 1,
                        style: TextStyle(fontSize: 18),
                        textInputAction: TextInputAction.done,
                        initialValue: profile.name ?? "",
                        decoration: InputDecoration(
                            hintText: profile.type == "Club" ? "Tên CLB" : 'Họ và tên',
                            //errorText: _nameValidate ? "Vui lòng nhập họ tên" : null,
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 1)),
                            contentPadding: EdgeInsets.only(left: 8),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
                            border: const OutlineInputBorder()),
                      ),
                      SizedBox(height: 8),
                      profile.type == "club"
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                InkWell(
                                  onTap: () => _showDatePicker(),
                                  child: Card(
                                    margin: EdgeInsets.symmetric(horizontal: 0),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(Icons.date_range),
                                          SizedBox(width: 16),
                                          Text(
                                            _birthDay ?? profile.dob,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Spacer(),
                                          Text("Thay đổi",
                                              style: AppTheme.changeTextStyle(
                                                  true))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _showGenderPicker(),
                                  child: Card(
                                    margin: EdgeInsets.symmetric(horizontal: 0),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(Icons.group),
                                          SizedBox(width: 16),
                                          Text(
                                            _gender ?? profile.gender ?? "",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Spacer(),
                                          Text("Thay đổi",
                                              style: AppTheme.changeTextStyle(
                                                  true))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8)
                              ],
                            ),
                      InkWell(
                        onTap: () =>
                            showCityList(getIndex(DummyData.cityList, selectedCity)),
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(Icons.location_city),
                                SizedBox(width: 16),
                                Text(
                                  selectedCity ?? profile.province ?? "",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Spacer(),
                                Text("Thay đổi",
                                    style: AppTheme.changeTextStyle(true))
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () => selectedCity != null
                            ? showDistrictList(
                            getIndex(DummyData.districtList, selectedDistrict))
                            : null,
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(Icons.home),
                                SizedBox(width: 16),
                                Text(
                                  selectedDistrict ?? profile.district ?? "",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Spacer(),
                                Text("Thay đổi",
                                    style: AppTheme.changeTextStyle(selectedCity != null))
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () => selectedDistrict != null
                            ? showWardList(getIndex(DummyData.wardList, selectedWard))
                            : null,
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(Icons.wallpaper),
                                SizedBox(width: 16),
                                Text(
                                  selectedWard ?? profile.ward ?? "",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Spacer(),
                                Text("Thay đổi",
                                    style: AppTheme.changeTextStyle(selectedDistrict != null))
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        maxLines: 1,
                        style: TextStyle(fontSize: 18),
                        textInputAction: TextInputAction.next,
                        initialValue: profile.address ?? "",
                        decoration: InputDecoration(
                            hintText: 'Số nhà, tên đường',
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 1)),
                            contentPadding: EdgeInsets.only(left: 8),
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: Colors.black,
                            ),
                            border: const OutlineInputBorder()),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        maxLines: 1,
                        style: TextStyle(fontSize: 18),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        initialValue: profile.email ?? "",
                        decoration: InputDecoration(
                            hintText: 'Email',
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 1)),
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
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value.length < 7) {
                            return "Mật khẩu phải lớn hơn 6 kí tự";
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText: 'Mật khẩu mới',
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 1)),
                            contentPadding: EdgeInsets.only(left: 8),
                            prefixIcon: Icon(
                              Icons.vpn_key,
                              color: Colors.black,
                            ),
                            border: const OutlineInputBorder()),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        maxLines: 1,
                        style: TextStyle(fontSize: 18),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            hintText: 'Nhập lại mật khẩu mới',
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 1)),
                            contentPadding: EdgeInsets.only(left: 8),
                            prefixIcon: Icon(
                              Icons.confirmation_number,
                              color: Colors.black,
                            ),
                            border: const OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      //resizeToAvoidBottomPadding: false,
      floatingActionButton: _showFab
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context);
              },
              backgroundColor: Colors.green,
              label: Text("Lưu thay đổi"),
              icon: Icon(Icons.save),
            )
          : null,
    );
  }

  var selectedCity;
  var selectedDistrict;
  var selectedWard;
  var _birthDay;
  var _gender;
  var _isMale = true;

  //
  int getIndex(List<String> list, String selectedItem) {
    return selectedItem != null
        ? list.indexOf(list.firstWhere((element) => element == selectedItem))
        : 0;
  }

  //modal bottomsheet
  _showDatePicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: CupertinoDatePicker(
              initialDateTime: DateTime.now(),
              onDateTimeChanged: (date) {
                setState(() {
                  _birthDay = DateFormat('dd-MM-yyyy').format(date);
                });
              },
              mode: CupertinoDatePickerMode.date,
            ),
          );
        });
  }

  _showGenderPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: _isMale ? Colors.red : Colors.grey,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(50)),
                        onPressed: () {
                          setState(() {
                            _gender = "Nam";
                          });
                          setModalState(() {
                            _isMale = !_isMale;
                          });
                        },
                        textColor: _isMale ? Colors.red : Colors.grey,
                        icon: Icon(MyFlutterApp.male),
                        label: Text("Nam",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))),
                    FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: !_isMale ? Colors.red : Colors.grey,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(50)),
                        textColor: !_isMale ? Colors.red : Colors.grey,
                        onPressed: () {
                          setState(() {
                            _gender = "Nữ";
                          });
                          setModalState(() {
                            _isMale = !_isMale;
                          });
                        },
                        icon: Icon(MyFlutterApp.female),
                        label: Text("Nữ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)))
                  ],
                ),
              );
            },
          );
        });
  }


  void showCityList(int index) {
    var controller = FixedExtentScrollController(initialItem: index);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            height: 250,
            child: CupertinoPicker(
              scrollController: controller,
              onSelectedItemChanged: (value) {
                setState(() {
                  selectedCity = DummyData.cityList[value];
                });
              },
              itemExtent: 32,
              children: DummyData.cityList.map((e) => Text(e)).toList(),
            ),
          );
        }).then((value) => debugPrint(selectedCity));
  }

  void showDistrictList(int index) {
    var controller = FixedExtentScrollController(initialItem: index);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            height: 250,
            child: CupertinoPicker(
              scrollController: controller,
              onSelectedItemChanged: (value) {
                setState(() {
                  selectedDistrict = DummyData.districtList[value];
                });
              },
              itemExtent: 32,
              children: DummyData.districtList.map((e) => Text(e)).toList(),
            ),
          );
        }).then((value) => debugPrint(selectedDistrict));
  }

  void showWardList(int index) {
    var controller = FixedExtentScrollController(initialItem: index);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            height: 250,
            child: CupertinoPicker(
              scrollController: controller,
              onSelectedItemChanged: (value) {
                setState(() {
                  selectedWard = DummyData.wardList[value];
                });
              },
              itemExtent: 32,
              children: DummyData.wardList.map((e) => Text(e)).toList(),
            ),
          );
        }).then((value) => debugPrint(selectedWard));
  }
}
