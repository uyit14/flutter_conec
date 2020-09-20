import 'dart:convert';
import 'dart:io';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/models/request/page_info_request.dart';
import 'package:conecapp/models/response/page/page_response.dart';
import 'package:conecapp/ui/mypost/blocs/post_action_bloc.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html_editor/html_editor.dart';
import 'package:image_picker/image_picker.dart';

class EditInfoPage extends StatefulWidget {
  static const ROUTE_NAME = "/edit-info-page";

  @override
  _EditInfoPageState createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  ProfileBloc _profileBloc = ProfileBloc();
  Profile profile = Profile();
  GlobalKey<HtmlEditorState> keyEditor = GlobalKey();
  PostActionBloc _postActionBloc = PostActionBloc();
  List<File> _images = List<File>();
  final picker = ImagePicker();
  List<Images> _urlImages = List();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context).settings.arguments;
    profile = routeArgs;
    _urlImages = profile.images;
    print(profile.name ?? "U");
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

  void doUpdatePage() async{
    final txt = await keyEditor.currentState.getText();
    PageInfoRequest _request = PageInfoRequest(
      about: txt,
      images: _images.length > 0 ? base64ListImage(_images) : null,
    );
    _profileBloc.requestUpdatePage(jsonEncode(_request.toJson()));
    _profileBloc.updatePageStream.listen((event) {
      if (event.status == Status.LOADING) {
        setState(() {
          _isLoading = true;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Chỉnh sửa thông tin trang")),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: AppTheme.appBarSize, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Giới thiệu", style: AppTheme.profileTitle),
                  SizedBox(height: 8,),
                  HtmlEditor(
                      //hint: "Your text here...",
                      value: profile.about ?? "Nhập thông tin giới thiệu",
                      key: keyEditor,
                      showBottomToolbar: false),
                  SizedBox(height: 8,),
                  Text("Thư viện ảnh", style: AppTheme.profileTitle),
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
                                _postActionBloc.requestDeleteImage(e.id);
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
                ],
              ),
            ),
            _isLoading ? UILoadingOpacity() : Container()
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: doUpdatePage,
          backgroundColor: Colors.green,
          label: Text("Lưu thay đổi"),
          icon: Icon(Icons.save),
        ),
      ),
    );
  }
}
