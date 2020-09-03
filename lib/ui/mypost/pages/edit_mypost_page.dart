import 'dart:convert';
import 'dart:io';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/request/latlong.dart';
import 'package:conecapp/models/request/post_action_request.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/models/response/location/city_response.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/models/response/image.dart' as myImage;
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:conecapp/ui/mypost/blocs/post_action_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';

import '../../conec_home_page.dart';

class EditMyPostPage extends StatefulWidget {
  static const ROUTE_NAME = 'edit-mypost';

  @override
  _EditMyPostPageState createState() => _EditMyPostPageState();
}

class _EditMyPostPageState extends State<EditMyPostPage> {
  int _currentSelectedIndex = -1;
  String _selectedCategoryId;
  String _selectedTopicName;
  ZefyrController _controller;
  FocusNode _focusNode = FocusNode();
  List<File> _images = List<File>();
  List<myImage.Image> _urlImages = List();
  final picker = ImagePicker();
  bool _isCallApi;
  String postId;
  ItemsByCategoryBloc _itemsByCategoryBloc = ItemsByCategoryBloc();
  PostActionBloc _postActionBloc = PostActionBloc();
  ItemDetail _itemDetail = ItemDetail();
  TextEditingController _titleController;
  TextEditingController _joiningFreeController;
  TextEditingController _phoneController;
  TextEditingController _addressController;
  TextEditingController _usesController;
  TextEditingController _conditionController;
  bool _isLoading = false;
  bool _isFirstTime = true;

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

  initValue() {
    setState(() {
      _titleController = TextEditingController(text: _itemDetail.title);
      _joiningFreeController =
          TextEditingController(text: _itemDetail.joiningFee.toString());
      _phoneController = TextEditingController(text: _itemDetail.phoneNumber);
      _addressController = TextEditingController(text: _itemDetail.address);
      selectedCity = _itemDetail.province;
      selectedDistrict = _itemDetail.district;
      selectedWard = _itemDetail.ward;
      _urlImages = _itemDetail.images;
      _usesController = TextEditingController(text: _itemDetail.uses);
      _conditionController =
          TextEditingController(text: _itemDetail.generalCondition);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _postActionBloc = PostActionBloc();
    if (_isCallApi) {
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, Object>;
      postId = routeArgs['postId'];
      _postActionBloc.requestGetProvinces();
      _postActionBloc.provincesStream.listen((event) {
        switch (event.status) {
          case Status.COMPLETED:
            _listProvinces.addAll(event.data);
            break;
        }
      });
      _itemsByCategoryBloc.requestItemDetail(postId);
      _itemsByCategoryBloc.itemDetailStream.listen((event) {
        switch (event.status) {
          case Status.COMPLETED:
            _itemDetail = event.data;
            _selectedTopicName = _itemDetail.topic;
            if (_itemDetail.content != null) {
              final document = _itemDetail.content != null
                  ? _loadDocument('${_itemDetail.content}\n')
                  : NotusDocument();
              _controller = ZefyrController(document);
            }
            _postActionBloc.requestGetTopicWithHeader();
            initValue();
            break;
        }
      });
      _isCallApi = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sửa bài đăng")),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //STEP 1
              Text("Danh mục"),
              Container(
                height: 35,
                child: StreamBuilder<ApiResponse<List<Topic>>>(
                    stream: _postActionBloc.topicStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        switch (snapshot.data.status) {
                          case Status.LOADING:
                            break;
                          case Status.COMPLETED:
                            List<Topic> topics = snapshot.data.data;
                            if (_isFirstTime) {
                              _currentSelectedIndex = topics.indexWhere(
                                  (element) =>
                                      element.title == _selectedTopicName);
                              _selectedCategoryId =
                                  topics[_currentSelectedIndex].id;
                              _isFirstTime = false;
                            }
                            return ListView.builder(
                                itemCount: topics.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 4),
                                    child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.grey,
                                                width: 1,
                                                style: BorderStyle.solid),
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        color: _currentSelectedIndex == index
                                            ? Colors.green
                                            : Colors.white,
                                        textColor:
                                            _currentSelectedIndex == index
                                                ? Colors.white
                                                : Colors.black,
                                        onPressed: () {
                                          setState(() {
                                            _selectedCategoryId =
                                                topics[index].id;
                                            _currentSelectedIndex = index;
                                          });
                                          print(topics[index].title);
                                        },
                                        child: Text(topics[index].title)),
                                  );
                                });
                          case Status.ERROR:
                            return UIError(
                                errorMessage: snapshot.data.message,
                                onRetryPressed: () => _postActionBloc
                                    .requestGetTopicWithHeader());
                        }
                      }
                      return Container(child: Text("Vui lòng chờ..."));
                    }),
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
                        TextFormField(
                          maxLines: 1,
                          style: TextStyle(fontSize: 18),
                          controller: _conditionController,
                          decoration: InputDecoration(
                              hintText:
                                  'Nhập tình trạng (Còn hàng, hết hàng, ...)',
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.green, width: 1)),
                              contentPadding: EdgeInsets.only(left: 8),
                              prefixIcon: Icon(
                                Icons.check,
                                color: Colors.black,
                              ),
                              border: const OutlineInputBorder()),
                        ),
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
                        SizedBox(height: 12),
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
                onTap: () =>
                    showCityList(getIndex(_listProvinces, selectedCity)),
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
                          selectedCity ?? "Tỉnh/Thành phố",
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
                onTap: () => selectedCity != null
                    ? showDistrictList(
                        getIndex(_districtList, selectedDistrict))
                    : null,
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
                          selectedDistrict ?? "Quận/Huyện",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text("Thay đổi",
                            style:
                                AppTheme.changeTextStyle(selectedCity != null))
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              InkWell(
                onTap: () => selectedDistrict != null
                    ? showWardList(getIndex(_wardList, selectedWard))
                    : null,
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
                          selectedWard ?? "Phường/Xã",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text("Thay đổi",
                            style: AppTheme.changeTextStyle(
                                selectedDistrict != null))
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
    );
  }

  //-----------------------post action -----------------------------//
  PostActionRequest _postActionRequest;

  void doUpdateAction() async{
    final result = selectedCity != null
        ? await Helper.getLatLng(
        '$_addressController.text, $selectedWard, $selectedDistrict, $selectedCity')
        : LatLong(lat: 0.0, long: 0.0);
    print(result.lat.toString() + "----" + result.long.toString());
    if (_currentSelectedIndex == 7) {
      _postActionRequest = PostActionRequest(
          postId: _itemDetail.postId,
          title: _titleController.text,
          content: _controller.document.toPlainText(),
          thumbnail: _images.length > 0 && _urlImages.length == 0
              ? {
                  "fileName": _images[0].path.split("/").last,
                  "base64": base64Encode(_images[0].readAsBytesSync())
                }
              : null,
          topicId: _selectedCategoryId,
          images: _images.length > 0 ? base64ListImage(_images) : null,
          province: selectedCity,
          district: selectedDistrict,
          ward: selectedWard,
          address: _addressController.text,
          price: _joiningFreeController.text.length > 0
              ? int.parse(_joiningFreeController.text)
              : null,
          uses: _usesController.text,
          generalCondition: _conditionController.text,
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
                  "fileName": _images[0].path.split("/").last,
                  "base64": base64Encode(_images[0].readAsBytesSync())
                }
              : null,
          topicId: _selectedCategoryId,
          images: _images.length > 0 ? base64ListImage(_images) : null,
          province: selectedCity,
          district: selectedDistrict,
          ward: selectedWard,
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
                  "fileName": _images[0].path.split("/").last,
                  "base64": base64Encode(_images[0].readAsBytesSync())
                }
              : null,
          topicId: _selectedCategoryId,
          images: _images.length > 0 ? base64ListImage(_images) : null,
          province: selectedCity,
          district: selectedDistrict,
          ward: selectedWard,
          address: _addressController.text,
          joiningFee: _joiningFreeController.text.length > 0
              ? int.parse(_joiningFreeController.text)
              : null,
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

  var selectedCity;
  String _selectCityId;
  var selectedDistrict;
  String _selectDistrictId;
  List<Province> _listProvinces = List<Province>();
  List<Province> _districtList = List<Province>();
  List<Province> _wardList = List<Province>();
  var selectedWard;
  String _selectWardId;

  //
  int getIndex(List<Province> list, String selectedItem) {
    int index = list.indexOf(list.firstWhere(
        (element) => element.name == selectedItem,
        orElse: () => list != null ? list[0] : null));
    if (index == -1) {
      return 0;
    }
    return selectedItem != null ? index : 0;
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
                  selectedCity = _listProvinces[value].name;
                  _selectCityId = _listProvinces[value].id;
                });
              },
              itemExtent: 32,
              children: _listProvinces.map((e) => Text(e.name)).toList(),
            ),
          );
        }).then((value) {
      getDistrictByProvinceId(
          _selectCityId ?? "8046b1ab-4479-4086-b986-3369fcb51f1a");
      print(_selectCityId ?? "8046b1ab-4479-4086-b986-3369fcb51f1a");
    });
  }

  void getDistrictByProvinceId(String id) {
    _postActionBloc.requestGetDistricts(id);
    _postActionBloc.districtsStream.listen((event) {
      switch (event.status) {
        case Status.COMPLETED:
          _districtList = event.data;
          break;
      }
    });
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
                  selectedDistrict = _districtList[value].name;
                  _selectDistrictId = _districtList[value].id;
                });
              },
              itemExtent: 32,
              children: _districtList.map((e) => Text(e.name)).toList(),
            ),
          );
        }).then((value) {
      getWardByDistrictId(
          _selectDistrictId ?? "83e9ce08-92da-4208-b178-2beb51a405ad");
      print(_selectDistrictId ?? "83e9ce08-92da-4208-b178-2beb51a405ad");
    });
  }

  void getWardByDistrictId(String id) {
    _postActionBloc.requestGetWards(id);
    _postActionBloc.wardsStream.listen((event) {
      switch (event.status) {
        case Status.COMPLETED:
          print("data: " + event.data.length.toString());
          _wardList = event.data;
          break;
      }
    });
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
                  selectedWard = _wardList[value].name;
                  _selectWardId = _wardList[value].id;
                });
              },
              itemExtent: 32,
              children: _wardList.map((e) => Text(e.name)).toList(),
            ),
          );
        }).then((value) => debugPrint(_selectWardId));
  }
}
