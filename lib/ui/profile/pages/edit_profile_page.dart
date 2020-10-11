import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/custom_icons.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/models/request/latlong.dart';
import 'package:conecapp/models/request/profile_request.dart';
import 'package:conecapp/models/response/location/city_response.dart';
import 'package:conecapp/models/response/profile/profile_response.dart';
import 'package:conecapp/ui/address/district_page.dart';
import 'package:conecapp/ui/address/province_page.dart';
import 'package:conecapp/ui/address/ward_page.dart';
import 'package:conecapp/ui/mypost/blocs/post_action_bloc.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:conecapp/ui/profile/widgets/detail_clipper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  String _name;
  String _gender = "Nam";
  String _address;
  String _email;
  String _phone;
  int _selectedType;
  String _type;
  bool _isLoading = false;
  List<Province> _listProvinces = List<Province>();
  PostActionBloc _postActionBloc;
  ProfileBloc _profileBloc = ProfileBloc();
  bool _isApiCall = true;
  Province provinceData;
  Province districtData;
  Province wardData;

  Future getImage(bool isCamera) async {
    final pickedFile = await picker.getImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
    Navigator.pop(context);
  }

  Profile profile = Profile();

  @override
  void initState() {
    super.initState();
    _postActionBloc = PostActionBloc();
    _postActionBloc.requestGetTopicWithHeader();
    _postActionBloc.requestGetProvinces();
    _postActionBloc.provincesStream.listen((event) {
      switch (event.status) {
        case Status.COMPLETED:
          _listProvinces.addAll(event.data);
          break;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context).settings.arguments;
    profile = routeArgs;
    //init value
    if (_isApiCall) {
      _name = profile.name;
      _gender = profile.gender ?? "Nam";
      _birthDay = DateTime(
          int.parse(profile.dob.substring(6)),
          int.parse(profile.dob.substring(3, 5)),
          int.parse(profile.dob.substring(0, 2)));
      _address = profile.address;
      _email = profile.email;
      _phone = profile.phoneNumber;
      _type = profile.type;
      provinceData = Province(name: profile.province);
      districtData = Province(name: profile.district);
      wardData = Province(name: profile.ward);
      if (profile.type != null && profile.type == "Club") {
        _selectedType = 0;
        _type = "Club";
      } else if (profile.type == "Personal") {
        _type = "Personal";
        _selectedType = 1;
      } else {
        _type = "Trainer";
        _selectedType = 2;
      }
      _isApiCall = false;
    }
  }

  String restrictFractionalSeconds(String dateTime) =>
      dateTime.replaceFirstMapped(RegExp(r"(\.\d{6})\d+"), (m) => m[1]);

  @override
  Widget build(BuildContext context) {
    final bool _showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Chỉnh sửa thông tin"), elevation: 0),
        body: Stack(
          children: [
            SingleChildScrollView(
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
                              onPressed: () => getImage(true),
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
                                ? (profile.avatar == null
                                    ? AssetImage("assets/images/avatar.png")
                                    : CachedNetworkImageProvider(
                                        profile.avatar))
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
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                FlatButton(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: _selectedType == 0
                                                ? Colors.red
                                                : Colors.grey,
                                            width: 1,
                                            style: BorderStyle.solid),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    onPressed: () {
                                      setState(() {
                                        _type = "Club";
                                        _selectedType = 0;
                                      });
                                    },
                                    textColor: _selectedType == 0
                                        ? Colors.red
                                        : Colors.grey,
                                    child: Text("Câu lạc bộ",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold))),
                                FlatButton(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: _selectedType == 1
                                                ? Colors.red
                                                : Colors.grey,
                                            width: 1,
                                            style: BorderStyle.solid),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    textColor: _selectedType == 1
                                        ? Colors.red
                                        : Colors.grey,
                                    onPressed: () {
                                      setState(() {
                                        _type = "Personal";
                                        _selectedType = 1;
                                      });
                                    },
                                    child: Text("Cá nhân",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold))),
                                FlatButton(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: _selectedType == 2
                                                ? Colors.red
                                                : Colors.grey,
                                            width: 1,
                                            style: BorderStyle.solid),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    textColor: _selectedType == 2
                                        ? Colors.red
                                        : Colors.grey,
                                    onPressed: () {
                                      setState(() {
                                        _type = "Trainer";
                                        _selectedType = 2;
                                      });
                                    },
                                    child: Text("Huấn luyện viên",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)))
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            //controller: _nameController,
                            maxLines: 1,
                            style: TextStyle(fontSize: 18),
                            textInputAction: TextInputAction.done,
                            initialValue: profile.name ?? "",
                            onChanged: (value) {
                              setState(() {
                                _name = value;
                              });
                              print(_name);
                            },
                            decoration: InputDecoration(
                                hintText: _selectedType == 0
                                    ? "Tên CLB"
                                    : 'Họ và tên',
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
                          _selectedType == 0
                              ? Container()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        DatePicker.showDatePicker(context,
                                            showTitleActions: true,
                                            minTime: DateTime(1945, 1, 1),
                                            maxTime: DateTime(2030, 31, 12),
                                            theme: DatePickerTheme(
                                                headerColor: Colors.orange,
                                                backgroundColor: Colors.blue,
                                                itemStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                                doneStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16)),
                                            onChanged: (date) {
                                          setState(() {
                                            _birthDay =
                                                date != null ? date : null;
                                          });
                                        }, onConfirm: (date) {
                                          setState(() {
                                            _birthDay =
                                                date != null ? date : null;
                                          });
                                        },
                                            currentTime: _birthDay
                                                    .toString()
                                                    .contains("0001")
                                                ? DateTime(2000, 6, 16)
                                                : _birthDay,
                                            locale: LocaleType.vi);
                                      },
                                      child: Card(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 0),
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
                                                DateFormat('dd-MM-yyyy')
                                                    .format(_birthDay),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Spacer(),
                                              Text("Thay đổi",
                                                  style:
                                                      AppTheme.changeTextStyle(
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
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 0),
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
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Spacer(),
                                              Text("Thay đổi",
                                                  style:
                                                      AppTheme.changeTextStyle(
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
                            onTap: () {
                              Navigator.of(context).pushNamed(ProvincePage.ROUTE_NAME,
                                  arguments: {'province': provinceData}).then((value) {
                                if (value != null) {
                                  setState(() {
                                    provinceData = value;
                                  });
                                }
                              });
                            },
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
                                      provinceData != null
                                          ? provinceData.name
                                          : "Tỉnh/Thành phố",
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
                            onTap: () {
                              if (provinceData != null) {
                                Navigator.of(context).pushNamed(DistrictPage.ROUTE_NAME,
                                    arguments: {
                                      'district': districtData,
                                      'provinceId': provinceData.id
                                    }).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      districtData = value;
                                    });
                                  }
                                });
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Vui lòng chọn tỉnh, thành");
                              }
                            },
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
                                      districtData != null
                                          ? districtData.name
                                          : "Quận/Huyện",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Spacer(),
                                    Text("Thay đổi",
                                        style: AppTheme.changeTextStyle(
                                            provinceData != null))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              if (districtData != null) {
                                Navigator.of(context).pushNamed(WardPage.ROUTE_NAME,
                                    arguments: {
                                      'districtId': districtData.id
                                    }).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      wardData = value;
                                    });
                                  }
                                });
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Vui lòng chọn quận, huyện");
                              }
                            },
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
                                      wardData!=null ? wardData.name : "Phường/Xã",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Spacer(),
                                    Text("Thay đổi",
                                        style: AppTheme.changeTextStyle(
                                            districtData != null))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            maxLines: 1,
                            style: TextStyle(fontSize: 18),
                            textInputAction: TextInputAction.done,
                            initialValue: profile.address ?? "",
                            onChanged: (value) {
                              setState(() {
                                _address = value;
                              });
                            },
                            decoration: InputDecoration(
                                hintText: 'Số nhà, tên đường',
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.green, width: 1)),
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
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            initialValue: profile.phoneNumber ?? "",
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
                          SizedBox(height: 8),
                          TextFormField(
                            maxLines: 1,
                            style: TextStyle(fontSize: 18),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            initialValue: profile.email ?? "",
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
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            _isLoading ? UILoadingOpacity() : Container()
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        //resizeToAvoidBottomPadding: false,
        floatingActionButton: _showFab
            ? FloatingActionButton.extended(
                onPressed: doUpdateProfile,
                backgroundColor: Colors.green,
                label: Text("Lưu thay đổi"),
                icon: Icon(Icons.save),
              )
            : null,
      ),
    );
  }

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  void doUpdateProfile() async {
    setState(() {
      _isLoading = true;
    });
    final result = provinceData != null && districtData!=null && wardData!=null
        ? await Helper.getLatLng(
        '$_address, ${wardData.name}, ${districtData.name}, ${provinceData.name}')
        : LatLong(lat: 0.0, long: 0.0);
    print(result.lat.toString() + "----" + result.long.toString());
    //
    ProfileRequest _request = ProfileRequest(
      province: provinceData.name,
      district: districtData.name,
      ward: wardData.name,
      gender: _gender,
      name: _name,
      email: _email,
      address: _address,
      phoneNumber: _phone,
      dob: myEncode(_birthDay),
      type: _type,
      lat: result.lat ?? 0.0,
      lng: result.long ?? 0.0,
      avatar: _image != null
          ? {
              "fileName": _image.path.split("/").last,
              "base64": base64Encode(_image.readAsBytesSync())
            }
          : null,
    );
    _profileBloc.requestUpdateProfile(jsonEncode(_request.toJson()));
    _profileBloc.updateProfileStream.listen((event) {
      if (event.status == Status.COMPLETED) {
        setState(() {
          _isLoading = false;
        });
        showOKDialog(context);
      }
      if (event.status == Status.ERROR) {
        Fluttertoast.showToast(msg: event.message, textColor: Colors.black87);
      }
    });
  }

  showOKDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text("Thành công"),
                content: Text("Bạn đã cập nhật thông tin thành công?"),
                actions: <Widget>[
                  CupertinoDialogAction(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(0);
                      })
                ]));
  }

  var _birthDay;
  var _isMale = true;

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
                  _birthDay = date != null ? date : null;
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
}
