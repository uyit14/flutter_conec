import 'dart:convert';
import 'dart:io';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/request/latlong.dart';
import 'package:conecapp/models/request/post_action_request.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/models/response/location/city_response.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/models/response/image.dart' as myImage;
import 'package:conecapp/ui/address/district_page.dart';
import 'package:conecapp/ui/address/province_page.dart';
import 'package:conecapp/ui/address/ward_page.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:conecapp/ui/mypost/blocs/post_action_bloc.dart';
import 'package:conecapp/ui/news/blocs/news_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:html/parser.dart';
import 'category_page.dart';

class EditMyPostPage extends StatefulWidget {
  static const ROUTE_NAME = 'edit-mypost';

  @override
  _EditMyPostPageState createState() => _EditMyPostPageState();
}

class _EditMyPostPageState extends State<EditMyPostPage> {
  int _currentSelectedIndex = -1;
  Topic topic;
  ZefyrController _controller;
  FocusNode _focusNode = FocusNode();
  List<File> _images = List<File>();
  List<myImage.Image> _urlImages = List();
  final picker = ImagePicker();
  bool _isCallApi;
  String postId;
  String typePost;
  int _selectedType;
  String _type;
  ItemsByCategoryBloc _itemsByCategoryBloc = ItemsByCategoryBloc();
  NewsBloc _newsBloc = NewsBloc();
  PostActionBloc _postActionBloc = PostActionBloc();
  dynamic _itemDetail;
  TextEditingController _titleController;
  TextEditingController _joiningFreeController;
  TextEditingController _phoneController;
  TextEditingController _addressController;
  TextEditingController _usesController;
  TextEditingController _conditionController;
  bool _isLoading = false;
  Province provinceData;
  Province districtData;
  Province wardData;
  int statusInt = 0;
  String statusType = "Mới";

  @override
  void initState() {
    super.initState();
    _isCallApi = true;
    _controller = ZefyrController(NotusDocument());
  }

  /// Loads the document to be edited in Zefyr.
  NotusDocument _loadDocument(String data) {
    // For simplicity we hardcode a simple document with one line of text
    // saying "Zefyr Quick Start".
    // (Note that delta must always end with newline.)
    final Delta delta = Delta()..insert(data);
    return NotusDocument.fromDelta(delta);
  }

  Future getImageList() async {
    List<File> files = await FilePicker.getMultiFile(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'bmp'],
    );
    _images.addAll(files);
    setState(() {});
    Navigator.pop(context);
  }

  Future getImageListIOS() async {
    List<Asset> assets = await MultiImagePicker.pickImages(maxImages: 10);
    print("size ${assets.length}");
    assets.forEach((element) async{
      final filePath = await FlutterAbsolutePath.getAbsolutePath(element.identifier);
      File tempFile = File(filePath);
      if (tempFile.existsSync()) {
        //files.add(tempFile);
        setState(() {
          _images.add(tempFile);
        });
      }
    });
    Navigator.pop(context);
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    _images.add(File(pickedFile.path));
    setState(() {});
    Navigator.pop(context);
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
                onPressed: () => Platform.isAndroid ? getImageList() : getImageListIOS(),
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

  initValue() {
    setState(() {
      if(typePost=="post"){
        getSelectedType(_itemDetail.joiningFeePeriod);
        _joiningFreeController =
            TextEditingController(text: _itemDetail.joiningFee.toString());
        _type = _itemDetail.joiningFeePeriod;
      }else if(typePost=="sell"){
        _joiningFreeController =
            TextEditingController(text: _itemDetail.price.toString());
        _usesController = TextEditingController(text: _itemDetail.uses);
        _conditionController =
            TextEditingController(text: _itemDetail.generalCondition);
      }else{
        _joiningFreeController = TextEditingController();
        _conditionController = TextEditingController();
        _usesController = TextEditingController();
      }
      _titleController = TextEditingController(text: _itemDetail.title);
      _phoneController = TextEditingController(text: _itemDetail.phoneNumber);
      _addressController = TextEditingController(text: _itemDetail.address);
      provinceData = Province(name: _itemDetail.province);
      districtData = Province(name: _itemDetail.district);
      wardData = Province(name: _itemDetail.ward);
      topic = Topic(id: _itemDetail.topicId, title: _itemDetail.topic);
      setSelectedIndex(topic);
      _urlImages = _itemDetail.images;
    });
  }

  getSelectedType(String type){
    switch(type){
      case "Giờ":
        _selectedType = 0;
        break;
      case "Ngày":
        _selectedType = 1;
        break;
      case "Tháng":
        _selectedType = 2;
        break;
      case "Năm":
        _selectedType = 3;
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _postActionBloc = PostActionBloc();
    if (_isCallApi) {
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, Object>;
      postId = routeArgs['postId'];
      typePost = routeArgs['type'];
      if(typePost=="news"){
        _newsBloc.requestNewsDetail(postId);
        _newsBloc.newsDetailStream.listen((event) {
          switch (event.status) {
            case Status.COMPLETED:
              _itemDetail = event.data;
              topic = Topic(id: _itemDetail.topicId, title: _itemDetail.topic);
              if (_itemDetail.content != null) {
                final document = parse(_itemDetail.content ?? "");
                final String parsedString = parse(document.body.text).documentElement.text;
                final notusDocument = _itemDetail.content != null
                    ? _loadDocument('$parsedString\n')
                    : NotusDocument();
                _controller = ZefyrController(notusDocument);
              }
              initValue();
              break;
          }
        });
      }else if(typePost=="sell"){
        _newsBloc.requestAdsDetail(postId);
        _newsBloc.adsDetailStream.listen((event) {
          switch (event.status) {
            case Status.COMPLETED:
              _itemDetail = event.data;
              topic = Topic(id: _itemDetail.topicId, title: _itemDetail.topic);
              if (_itemDetail.content != null) {
                final document = parse(_itemDetail.content ?? "");
                final String parsedString = parse(document.body.text).documentElement.text;
                final notusDocument = _itemDetail.content != null
                    ? _loadDocument('$parsedString\n')
                    : NotusDocument();
                _controller = ZefyrController(notusDocument);
              }
              initValue();
              break;
          }
        });
      }else{
        _itemsByCategoryBloc.requestItemDetail(postId);
        _itemsByCategoryBloc.itemDetailStream.listen((event) {
          switch (event.status) {
            case Status.COMPLETED:
              _itemDetail = event.data;
              topic = Topic(id: _itemDetail.topicId, title: _itemDetail.topic);
              if (_itemDetail.content != null) {
                final document = parse(_itemDetail.content ?? "");
                final String parsedString = parse(document.body.text).documentElement.text;
                final notusDocument = _itemDetail.content != null
                    ? _loadDocument('$parsedString\n')
                    : NotusDocument();
                _controller = ZefyrController(notusDocument);
              }
              initValue();
              break;
          }
        });
      }
      _isCallApi = false;
    }
  }

  setSelectedIndex(Topic topic){
    if(topic.id == "333f691d-6595-443d-bae3-9a2681025b53"){
      setState(() {
        _currentSelectedIndex = 6;
      });
    }else if(topic.id == "333f691d-6585-443a-bae3-9a2681025b53"){
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
        appBar: AppBar(title: Text("Sửa bài đăng")),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //STEP 1
                Text("Danh mục"),
                SizedBox(height: 4,),
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
                Text("Tiêu đề"),
                TextFormField(
                  maxLines: 1,
                  style: TextStyle(fontSize: 18),
                  controller: _titleController,
                  decoration: InputDecoration(
                      hintText: 'Nhập tiêu đề',
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 1)),
                      contentPadding: EdgeInsets.only(left: 8),
                      prefixIcon: Icon(
                        Icons.title,
                        color: Colors.black,
                      ),
                      border: const OutlineInputBorder()),
                ),
                SizedBox(height: 12),
                //STEP 3
                Text("Mô tả"),
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
                          TextFormField(
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(fontSize: 18),
                            controller: _joiningFreeController,
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
                TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  controller: _phoneController,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                      hintText: 'Nhập số điện thoại',
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 1)),
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
                      padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(Icons.location_city),
                          Text(
                            provinceData != null && provinceData.name!=null
                                ? provinceData.name
                                : "Tỉnh/Thành phố",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text("Thay đổi", style: AppTheme.changeTextStyle(true))
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
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
                      padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(Icons.home),
                          Text(
                            districtData != null && districtData.name!=null
                                ? districtData.name
                                : "Quận/Huyện",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text("Thay đổi",
                              style:
                                  AppTheme.changeTextStyle(provinceData != null))
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
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
                      padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(Icons.wallpaper),
                          Text(
                            wardData!=null && wardData.name!=null ? wardData.name : "Phường/Xã",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text("Thay đổi",
                              style: AppTheme.changeTextStyle(
                                  districtData != null))
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  maxLines: 1,
                  style: TextStyle(fontSize: 18),
                  textInputAction: TextInputAction.done,
                  controller: _addressController,
                  decoration: InputDecoration(
                      hintText: 'Số nhà, tên đường',
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 1)),
                      contentPadding: EdgeInsets.only(left: 8),
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: Colors.black,
                      ),
                      border: const OutlineInputBorder()),
                ),
                SizedBox(height: 12),
                //STEP 7
                Text("Hình Ảnh"),
                _images.length == 0 && _urlImages.length == 0
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: _cameraHolder(),
                      )
                    : Container(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: List.from(_urlImages
                              .map((e) => Stack(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 4),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: e != null
                                              ? Image.network(
                                                  e.fileName,
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
                                          onPressed: () {
                                            //TODO - call api
                                            _urlImages.removeWhere(
                                                (element) => element.id == e.id);
                                            _postActionBloc.requestDeleteImage(e.id, "MyPost");
                                            setState(() {});
                                          },
                                          icon: Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    ],
                                  ))
                              .toList())
                            ..addAll(List.from(_images
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
                                            onPressed: () {
                                              _images.removeWhere(
                                                  (element) => element == e);
                                              setState(() {});
                                            },
                                            icon: Icon(
                                              Icons.remove_circle,
                                              color: Colors.red,
                                            ),
                                          ),
                                        )
                                      ],
                                    ))
                                .toList()))
                            ..add(_cameraHolder()),
                        ),
                      ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _isLoading
                      ? UILoading()
                      : FlatButton.icon(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          onPressed: () {
                            doUpdateAction();
                          },
                          color: Colors.orange,
                          textColor: Colors.white,
                          icon: Icon(Icons.check),
                          padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width / 5),
                          label: Text("Lưu thay đổi",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //-----------------------post action -----------------------------//
  PostActionRequest _postActionRequest;

  void doUpdateAction() async{
    File image01;
    if(_images.length > 0){
      image01 = _images[0];
    }
    var result;
    if(_addressController.text.length >0){
      try{
        result = provinceData != null && districtData!=null && wardData!=null
            ? await Helper.getLatLng(
            '${_addressController.text ?? ""}, ${wardData.name}, ${districtData.name}, ${provinceData.name}')
            : LatLong(lat: 0.0, long: 0.0);
        print(result.lat.toString() + "----" + result.long.toString());
      }catch(e){
        Helper.showMissingDialog(context, "Sai địa chỉ", "Vui lòng nhập đúng địa chỉ");
        setState(() {
          _isLoading = false;
        });
      }

    }else{
      result = LatLong(lat: 0.0, long: 0.0);
    }
    if (_currentSelectedIndex == 7) {
      _postActionRequest = PostActionRequest(
          postId: _itemDetail.postId,
          title: _titleController.text,
          content: _controller.document.toPlainText(),
          thumbnail: _images.length > 0 && _urlImages.length == 0
              ? {
                  "fileName": image01.path.split("/").last,
                  "base64": base64Encode(image01.readAsBytesSync())
                }
              : null,
          topicId: topic.id,
          images: _images.length > 0 ? base64ListImage(_images) : null,
          province: provinceData.name,
          district: districtData.name,
          ward: wardData.name,
          address: _addressController.text,
          price: _joiningFreeController.text.length > 0
              ? int.parse(_joiningFreeController.text)
              : null,
          uses: _usesController.text,
          generalCondition: statusType ?? null,
          phoneNumber: _phoneController.text,
          lat: result.lat ?? 0.0,
          lng: result.long ?? 0.0,
          status: "SUBMITTED");
    } else if (_currentSelectedIndex == 6) {
      _postActionRequest = PostActionRequest(
          postId: _itemDetail.postId,
          title: _titleController.text,
          content: _controller.document.toPlainText(),
          thumbnail: _images.length > 0
              ? {
                  "fileName": image01.path.split("/").last,
                  "base64": base64Encode(image01.readAsBytesSync())
                }
              : null,
          topicId: topic.id,
          images: _images.length > 0 ? base64ListImage(_images) : null,
          province: provinceData.name,
          district: districtData.name,
          ward: wardData.name,
          address: _addressController.text,
          phoneNumber: _phoneController.text,
          lat: result.lat ?? 0.0,
          lng: result.long ?? 0.0,
          status: "SUBMITTED");
    } else {
      _postActionRequest = PostActionRequest(
          postId: _itemDetail.postId,
          title: _titleController.text,
          content: _controller.document.toPlainText(),
          thumbnail: _images.length > 0
              ? {
                  "fileName": image01.path.split("/").last,
                  "base64": base64Encode(image01.readAsBytesSync())
                }
              : null,
          topicId: topic.id,
          images: _images.length > 0 ? base64ListImage(_images) : null,
          province: provinceData.name,
          district: districtData.name,
          ward: wardData.name,
          address: _addressController.text,
          joiningFee: _joiningFreeController.text.length > 0
              ? int.parse(_joiningFreeController.text)
              : null,
          joiningFeePeriod: _type,
          phoneNumber: _phoneController.text,
          lat: result.lat ?? 0.0,
          lng: result.long ?? 0.0,
          status: "SUBMITTED");
    }
    _postActionBloc.requestAddMyPost(
        jsonEncode(_postActionRequest.toJson()), "Update");
    _postActionBloc.addMyPostStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          setState(() {
            _isLoading = true;
          });
          break;
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

  showOKDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text("Cập nhật thành công"),
              content: Text("Bạn đã cập nhật thành công, quay lại trang chủ?"),
              actions: <Widget>[
                CupertinoDialogAction(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(true);
                    })
              ],
            ));
  }

}
