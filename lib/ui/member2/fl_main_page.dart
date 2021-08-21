import 'package:flutter/material.dart';

import 'follower_page.dart';
import 'member_2_page.dart';

class FlMainPage extends StatefulWidget {
  static const ROUTE_NAME = "/fl-main-page";

  @override
  _FlMainPageState createState() => _FlMainPageState();
}

class _FlMainPageState extends State<FlMainPage> {
  int _selectedPageIndex = 0;
  PageController _pageController = PageController();

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("Thành viên"),
          ),
          body: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2 - 30,
                    child: FlatButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: _selectedPageIndex == 0
                                    ? Colors.red
                                    : Colors.grey,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(50)),
                        onPressed: () => _selectPage(0),
                        textColor:
                            _selectedPageIndex == 0 ? Colors.red : Colors.grey,
                        child: Text("Thành viên",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2 - 30,
                    child: FlatButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: _selectedPageIndex == 1
                                    ? Colors.red
                                    : Colors.grey,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(50)),
                        textColor:
                            _selectedPageIndex == 1 ? Colors.red : Colors.grey,
                        onPressed: () => _selectPage(1),
                        child: Text("Theo dõi",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                  )
                ],
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[Member2Page(), FollowerPage()],
                ),
              )
            ],
          )),
    );
  }
}
