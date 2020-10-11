import 'dart:convert';
import 'dart:io';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/models/request/latlong.dart';
import 'package:conecapp/models/request/post_action_request.dart';
import 'package:conecapp/models/response/location/city_response.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/ui/address/district_page.dart';
import 'package:conecapp/ui/address/province_page.dart';
import 'package:conecapp/ui/address/ward_page.dart';
import 'package:conecapp/ui/conec_home_page.dart';
import 'package:conecapp/ui/mypost/blocs/post_action_bloc.dart';
import 'package:conecapp/ui/mypost/pages/category_page.dart';
import 'package:conecapp/ui/others/terms_condition_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zefyr/zefyr.dart';

import '../../../common/ui/ui_loading.dart';

class PostActionPage extends StatefulWidget {
  static const ROUTE_NAME = '/post-action';

  @override
  _PostActionPageState createState() => _PostActionPageState();
}

class _PostActionPageState extends State<PostActionPage> {
  bool _term = true;
  int _currentSelectedIndex = -1;
  String _title;
  bool _isLoading = false;
  bool _isCallApi = false;
  PostActionBloc _postActionBloc = PostActionBloc();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _joiningFreeController = TextEditingController();
  TextEditingController _usesController = TextEditingController();
  List<Province> _listProvinces = List<Province>();
  Topic topic;
  Province provinceData;
  Province districtData;
  Province wardData;
  int _selectedType;
  int statusInt = 0;
  String statusType = "Mới";
  String _type;

  ZefyrController _controller;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = ZefyrController(NotusDocument());
    _isCallApi = true;
  }

  List<File> _images = List<File>();
  final picker = ImagePicker();

  Future getImageList() async {
    List<File> files = await FilePicker.getMultiFile(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'bmp'],
    );
    _images.addAll(files);
    setState(() {});
    Navigator.pop(context);
  }

  Future getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 75);
    _images.add(File(pickedFile.path));
    setState(() {});
    Navigator.pop(context);
  }

  bool _isPostButtonEnable() {
    if ( topic == null ||
        _title == null ||
        _controller.document.toPlainText().length <= 0 && !_term) {
      return false;
    }
    return true;
  }

  Widget _cameraHolder() {
    return InkWell(
      onTap: () {
        final act = CupertinoActionSheet(
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text('Chụp ảnh', style: TextStyle(color: Colors.blue)),
                onPressed: () => getImage(),
              ),
              CupertinoActionSheetAction(
                child: Text('Chọn từ thư viện',
                    style: TextStyle(color: Colors.blue)),
                onPressed: () => getImageList(),
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
      child: Container(
          decoration: BoxDecoration(
              color: Colors.black12, borderRadius: BorderRadius.circular(12)),
          width: 100,
          height: 100,
          child: Icon(Icons.camera_alt, size: 32)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _postActionBloc = PostActionBloc();
    if (_isCallApi) {
      _postActionBloc.requestGetTopicWithHeader();
      _postActionBloc.requestGetProvinces();
      _postActionBloc.provincesStream.listen((event) {
        switch (event.status) {
          case Status.COMPLETED:
            _listProvinces.addAll(event.data);
            break;
        }
      });
      setState(() {
        _isCallApi = false;
      });
    }
  }

  setSelectedIndex(Topic topic){
    if(topic.title == "Bản tin"){
      setState(() {
        _currentSelectedIndex = 6;
      });
    }
    else if(topic.title == "Rao vặt"){
      setState(() {
        _currentSelectedIndex = 7;
      });
    }else{
      setState(() {
        _currentSelectedIndex = -1;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("Đăng tin"),
          ),
          body: Stack(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //STEP 1
                      Text("Danh mục *"),
                      SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(CategoryPage.ROUTE_NAME,
                              arguments: {'category': topic}).then((value) {
                            if (value != null) {
                              setSelectedIndex(value);
                              setState(() {
                                topic = value;
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
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Icon(Icons.category),
                                Text(
                                  topic != null
                                      ? topic.title
                                      : "Chọn danh mục",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text("Thay đổi",
                                    style: AppTheme.changeTextStyle(true))
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      //STEP 2
                      Text("Tiêu đề *"),
                      SizedBox(height: 4),
                      TextFormField(
                        maxLines: 1,
                        style: TextStyle(fontSize: 18),
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {
                          setState(() {
                            _title = value;
                          });
                        },
                        decoration: InputDecoration(
                            hintText: 'Nhập tiêu đề',
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 1)),
                            contentPadding: EdgeInsets.only(left: 8),
                            prefixIcon: Icon(
                              Icons.title,
                              color: Colors.black,
                            ),
                            border: const OutlineInputBorder()),
                      ),
                      SizedBox(height: 12),
                      //STEP 3
                      Text("Mô tả *"),
                      SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8))),
                        height: 200,
                        child: ZefyrScaffold(
                          child: ZefyrEditor(
                            autofocus: false,
                            controller: _controller,
                            focusNode: _focusNode,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      _currentSelectedIndex == 7
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Công dụng"),
                                SizedBox(height: 4),
                                TextFormField(
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 18),
                                  textInputAction: TextInputAction.done,
                                  controller: _usesController,
                                  decoration: InputDecoration(
                                      hintText: 'Nhập công dụng',
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.green, width: 1)),
                                      contentPadding: EdgeInsets.only(left: 8),
                                      prefixIcon: Icon(
                                        Icons.accessibility,
                                        color: Colors.black,
                                      ),
                                      border: const OutlineInputBorder()),
                                ),
                              ],
                            )
                          : Container(),
                      _currentSelectedIndex == 7
                          ? SizedBox(height: 12)
                          : SizedBox(
                              height: 0,
                            ),
                      _currentSelectedIndex == 7
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Tình trạng"),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FlatButton(
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: statusInt == 0
                                                      ? Colors.red
                                                      : Colors.grey,
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              borderRadius:
                                              BorderRadius.circular(50)),
                                          textColor: statusInt == 0
                                              ? Colors.red
                                              : Colors.grey,
                                          onPressed: () {
                                            setState(() {
                                              statusType = "Mới";
                                              statusInt = 0;
                                            });
                                          },
                                          child: Text("Mới",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: FlatButton(
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: statusInt == 1
                                                      ? Colors.red
                                                      : Colors.grey,
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              borderRadius:
                                              BorderRadius.circular(50)),
                                          textColor: statusInt == 1
                                              ? Colors.red
                                              : Colors.grey,
                                          onPressed: () {
                                            setState(() {
                                              statusType = "Đã sử dụng";
                                              statusInt = 1;
                                            });
                                          },
                                          child: Text("Đã sử dụng",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                  ],
                                )
                              ],
                            )
                          : Container(),
                      SizedBox(height: 12),
                      //STEP 4
                      _currentSelectedIndex == 6
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_currentSelectedIndex == 7
                                    ? "Giá"
                                    : "Phí tham gia"),
                                SizedBox(height: 4),
                                TextFormField(
                                  maxLines: 1,
                                  controller: _joiningFreeController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  style: TextStyle(fontSize: 18),
                                  decoration: InputDecoration(
                                      hintText: _currentSelectedIndex == 7
                                          ? "Nhập giá"
                                          : 'Nhập phí tham gia',
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.green, width: 1)),
                                      contentPadding: EdgeInsets.only(left: 8),
                                      prefixIcon: Icon(
                                        Icons.attach_money,
                                        color: Colors.black,
                                      ),
                                      border: const OutlineInputBorder()),
                                ),
                                _currentSelectedIndex == 7 ? Container() : Row(
                                  children: [
                                    Expanded(
                                      child: FlatButton(
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: _selectedType == 0
                                                      ? Colors.red
                                                      : Colors.grey,
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              borderRadius:
                                              BorderRadius.circular(50)),
                                          textColor: _selectedType == 0
                                              ? Colors.red
                                              : Colors.grey,
                                          onPressed: () {
                                            setState(() {
                                              _type = "Giờ";
                                              _selectedType = 0;
                                            });
                                          },
                                          child: Text("Giờ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: FlatButton(
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
                                              _type = "Ngày";
                                              _selectedType = 1;
                                            });
                                          },
                                          child: Text("Ngày",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: FlatButton(
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
                                              _type = "Tháng";
                                              _selectedType = 2;
                                            });
                                          },
                                          child: Text("Tháng",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: FlatButton(
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: _selectedType == 3
                                                      ? Colors.red
                                                      : Colors.grey,
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              borderRadius:
                                              BorderRadius.circular(50)),
                                          textColor: _selectedType == 3
                                              ? Colors.red
                                              : Colors.grey,
                                          onPressed: () {
                                            setState(() {
                                              _type = "Năm";
                                              _selectedType = 3;
                                            });
                                          },
                                          child: Text("Năm",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12,)
                              ],
                            ),
                      //STEP 5
                      Text("Số điện thoại"),
                      SizedBox(height: 4),
                      TextFormField(
                        maxLines: 1,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                            hintText: 'Nhập số điện thoại',
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 1)),
                            contentPadding: EdgeInsets.only(left: 8),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Colors.black,
                            ),
                            border: const OutlineInputBorder()),
                      ),
                      SizedBox(height: 12),
                      //STEP 6
                      Text("Địa chỉ"),
                      SizedBox(height: 4),
                      Column(
                        children: <Widget>[
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Icon(Icons.location_city),
                                    Text(
                                      provinceData != null
                                          ? provinceData.name
                                          : "Tỉnh/Thành phố",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Icon(Icons.home),
                                    Text(
                                      districtData != null
                                          ? districtData.name
                                          : "Quận/Huyện",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Icon(Icons.wallpaper),
                                    Text(
                                      wardData!=null ? wardData.name : "Phường/Xã",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
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
                            controller: _addressController,
                            style: TextStyle(fontSize: 18),
                            textInputAction: TextInputAction.done,
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
                        ],
                      ),
                      SizedBox(height: 12),
                      //TEP 7
                      Text("Hình Ảnh"),
                      SizedBox(height: 4),
                      _images.length == 0
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: _cameraHolder(),
                            )
                          : Container(
                              height: 100,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: List.from(_images
                                    .map((e) => Stack(
                                      children: [
                                        Container(
                                              margin: EdgeInsets.only(right: 4),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: e != null
                                                    ? Image.file(
                                                        e,
                                                        fit: BoxFit.cover,
                                                        width: 100,
                                                        height: 100,
                                                      )
                                                    : Container(),
                                              ),
                                            ),
                                        Positioned(
                                          top: -14,
                                          right: -10,
                                          child: IconButton(
                                            onPressed: (){
                                              _images.removeWhere((element) => element == e);
                                              setState(() {

                                              });
                                            },
                                            icon: Icon(Icons.remove_circle, color: Colors.red,),
                                          ),
                                        )
                                      ],
                                    ))
                                    .toList())
                                  ..add(_cameraHolder()),
                              ),
                            ),
                      SizedBox(height: 12),
                      //STEP 8
                      Text("Chính sách của Conec"),
                      SizedBox(height: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Checkbox(
                                onChanged: (value) {
                                  setState(() {
                                    _term = value;
                                  });
                                },
                                value: _term,
                                activeColor: const Color(0xff00bbff),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                      text: "Tôi đồng ý với các điều khoản ",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: "Chính sách của Conec ",
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => Navigator.of(context)
                                                  .pushNamed(
                                                      TermConditionPage.ROUTE_NAME),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                                fontSize: 14)),
                                        TextSpan(
                                            text:
                                                "Nếu vi phạm sẽ chịu mọi xử lý từ Conec",
                                            style: TextStyle(
                                                color: Colors.black, fontSize: 14))
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      //STEP 9
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FlatButton.icon(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            onPressed: () async{
                              setState(() {
                                _isLoading = true;
                              });
                              //debugPrint(_selectedCategory + "_title: " + _title + "_des: " +_controller.document.toPlainText() + "_term: " + _term.toString());
                              if (!_isPostButtonEnable()) {
                                showFailDialog();
                              } else {
                                doPostAction();
                              }
//                              final result = await Helper.getLatLng('${_addressController.text}, $selectedWard, $selectedDistrict, $selectedCity');
//                              print(result.lat.toString() + "----" + result.long.toString());
                            },
                            color: Colors.orange,
                            textColor: Colors.white,
                            icon: Icon(Icons.check),
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width / 5),
                            label: Text("Đăng tin",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500))),
                      )
                    ],
                  ),
                ),
              ),
              _isLoading ? UILoadingOpacity() : Container()
            ],
          )),
    );
  }


  int getJoiningFree() {
    if (_currentSelectedIndex == 7 || _currentSelectedIndex == 6) {
      return null;
    } else {
      int i = _joiningFreeController.text.length > 0
          ? int.parse(_joiningFreeController.text)
          : 0;
      return i;
    }
  }

  int getPrice() {
    if (_currentSelectedIndex == 6) {
      return null;
    }
    if (_currentSelectedIndex == 7) {
      int i = _joiningFreeController.text.length > 0
          ? int.parse(_joiningFreeController.text)
          : 0;
      return i;
    } else {
      return null;
    }
  }
  void doPostAction() async{
    final result = provinceData != null && districtData!=null && wardData!=null
        ? await Helper.getLatLng(
        '${_addressController.text}, ${wardData.name}, ${districtData.name}, ${provinceData.name}')
        : LatLong(lat: 0.0, long: 0.0);
    print(result.lat.toString() + "----" + result.long.toString());
    PostActionRequest _postActionRequest = PostActionRequest(
        title: _title,
        content: _controller.document.toPlainText(),
        thumbnail: _images.length > 0
            ? {
                "fileName": _images[0].path.split("/").last,
                "base64": base64Encode(_images[0].readAsBytesSync())
              }
            : null,
        topicId: topic.id,
        images: base64ListImage(_images),
        province: provinceData!=null ? provinceData.name : null,
        district: districtData!=null ? districtData.name : null,
        ward: wardData!=null ? wardData.name : null,
        address: _addressController.text,
        joiningFee: getJoiningFree(),
        joiningFeePeriod: _type,
        price: getPrice(),
        uses: _usesController.text ?? null,
        generalCondition: statusType ?? null,
        phoneNumber: _phoneController.text,
        lat: result.lat ?? 0.0,
        lng: result.long ?? 0.0,
        status: "SUBMITTED");
//    Map inputs = jsonDecode(_postActionRequest);
    //print("aa: " + inputs.toString());
    print("images: " + base64ListImage(_images).length.toString());
    _postActionBloc.requestAddMyPost(
        jsonEncode(_postActionRequest.toJson()), "Add");
    _postActionBloc.addMyPostStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          setState(() {
            _isLoading = true;
          });
          break;
        case Status.COMPLETED:
          setState(() {
            _isLoading = false;
          });
//          Fluttertoast.showToast(
//              msg: "Đăng bài thành công!", textColor: Colors.black87);
          showOKDialog();
          break;
        case Status.ERROR:
          Fluttertoast.showToast(msg: event.message, textColor: Colors.black87);
          break;
      }
    });
  }

  List<Map> base64ListImage(List<File> fileList) {
    List<Map> s = new List<Map>();
    if (fileList.length > 0)
      fileList.forEach((element) {
        Map a = {
          'fileName': element.path.split("/").last,
          'base64': base64Encode(element.readAsBytesSync())
        };
        s.add(a);
      });
    return s;
  }

  showOKDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text("Đăng bài thành công"),
              content: Text("Bạn đã đăng bài thành công, quay lại trang chủ?"),
              actions: <Widget>[
                CupertinoDialogAction(
                    child: Text("OK"),
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(ConecHomePage.ROUTE_NAME,
                            (Route<dynamic> route) => false))
              ],
            ));
  }

  showFailDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text("Lỗi nhập thiếu"),
              content: Text("Bạn vui lòng điền đầy đủ thông tin bắt buộc"),
              actions: <Widget>[
                CupertinoDialogAction(
                    child: Text("OK"),
                    onPressed: () => Navigator.of(context).pop())
              ],
            ));
  }
}
