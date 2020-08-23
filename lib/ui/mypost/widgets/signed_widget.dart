import 'package:conecapp/dummy/dummy_data.dart';
import 'package:conecapp/ui/mypost/widgets/archive_mypost.dart';
import 'package:conecapp/ui/mypost/widgets/approve_mypost.dart';
import 'package:conecapp/ui/mypost/widgets/hidden_mypost.dart';
import 'package:conecapp/ui/mypost/widgets/item_mypost.dart';
import 'package:conecapp/ui/mypost/widgets/pending_mypost.dart';
import 'package:conecapp/ui/mypost/widgets/rejected_mypost.dart';
import 'package:flutter/material.dart';

class Signed extends StatefulWidget {
  @override
  _SignedState createState() => _SignedState();
}

class _SignedState extends State<Signed> {
  PageController _pageController = PageController(initialPage: 0);
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 200,
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22))),
        ),
        Positioned.fill(
          left: 16,
          right: 16,
          child: Column(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "Tin đã đăng",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  )),
//              Row(
//                children: <Widget>[
//                  Expanded(
//                    child: Container(
//                      decoration: BoxDecoration(
//                        borderRadius: BorderRadius.circular(10),
//                        color: Colors.white,
//                      ),
//                      height: 40,
//                      child: TextFormField(
//                        maxLines: 1,
//                        style: TextStyle(fontSize: 18),
//                        decoration: InputDecoration(
//                            hintText: 'Nhập thông tin bạn muốn tìm kiếm',
//                            enabledBorder: OutlineInputBorder(
//                                borderRadius: BorderRadius.circular(10),
//                                borderSide:
//                                    BorderSide(color: Colors.white, width: 1)),
//                            focusedBorder: OutlineInputBorder(
//                                borderSide:
//                                    BorderSide(color: Colors.white, width: 1),
//                                borderRadius: BorderRadius.circular(10)),
//                            contentPadding: EdgeInsets.only(left: 8)),
//                      ),
//                    ),
//                  ),
//                  SizedBox(width: 8),
//                  InkWell(
//                    child: Text("Hủy",
//                        style: TextStyle(
//                            color: Colors.white,
//                            fontWeight: FontWeight.w500,
//                            fontSize: 16)),
//                    onTap: () {
//                      //TODO - clear seach
//                    },
//                  )
//                ],
//              ),
              //SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        onPressed: () => _selectPage(0),
                        textColor: _selectedPageIndex == 0
                            ? Colors.blue
                            : Colors.white,
                        color: _selectedPageIndex == 0
                            ? Colors.white
                            : Colors.grey,
                        icon: Icon(Icons.view_list, size: 22),
                        label: Text("Hoàn thành",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold))),
                    SizedBox(width: 4),
                    FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        onPressed: () => _selectPage(1),
                        textColor: _selectedPageIndex == 1
                            ? Colors.green
                            : Colors.white,
                        color: _selectedPageIndex == 1
                            ? Colors.white
                            : Colors.grey,
                        icon: Icon(Icons.unarchive, size: 22),
                        label: Text("Đã duyệt",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold))),
                    SizedBox(width: 4),
                    FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        onPressed: () => _selectPage(2),
                        textColor: _selectedPageIndex == 2
                            ? Colors.orange
                            : Colors.white,
                        color: _selectedPageIndex == 2
                            ? Colors.white
                            : Colors.grey,
                        icon: Icon(Icons.archive, size: 22),
                        label: Text("Chờ duyệt",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold))),
                    SizedBox(width: 4),
                    FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        onPressed: () => _selectPage(3),
                        textColor:
                            _selectedPageIndex == 3 ? Colors.red : Colors.white,
                        color: _selectedPageIndex == 3
                            ? Colors.white
                            : Colors.grey,
                        icon: Icon(Icons.not_interested, size: 22),
                        label: Text("Từ chối",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold))),
                    SizedBox(width: 4),
                    FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        onPressed: () => _selectPage(4),
                        textColor:
                        _selectedPageIndex == 4 ? Colors.grey : Colors.white,
                        color: _selectedPageIndex == 4
                            ? Colors.white
                            : Colors.grey,
                        icon: Icon(Icons.not_interested, size: 22),
                        label: Text("Đã ẩn",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    ArchiveMyPost(),
                    ApproveMyPost(),
                    PendingMyPost(),
                    RejectedMyPost(),
                    HiddenMyPost()
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
