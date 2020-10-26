import 'package:conecapp/ui/news/widgets/news_widget.dart';
import 'package:conecapp/ui/news/widgets/sell_widget.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  final int initIndex;

  NewsPage(this.initIndex);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  int _selectedPageIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initIndex);
    _selectedPageIndex = widget.initIndex;
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 4),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width / 2 - 30,
                child: FlatButton.icon(
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
                    icon: Icon(Icons.shopping_cart),
                    label: Text("Dụng cụ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2 - 30,
                child: FlatButton.icon(
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
                    icon: Icon(Icons.speaker_notes),
                    label: Text("Tin tức",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
              )
            ],
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: <Widget>[SellWidget(), NewsWidget()],
            ),
          )
        ],
      ),
    );
  }
}
