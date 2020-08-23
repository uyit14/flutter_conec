import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/dummy/dummy_data.dart';
import 'package:conecapp/models/response/slider.dart' as model;
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:conecapp/ui/home/widgets/categories_widget.dart';
import 'package:conecapp/ui/home/widgets/latest_items_widget.dart';
import 'package:conecapp/ui/home/widgets/new_product_widget.dart';
import 'package:conecapp/ui/home/widgets/new_sport_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_clipper.dart';
import 'package:flutter/material.dart';

import 'items_by_category_page.dart';

class HomePage extends StatefulWidget {
  final void Function(int, int) callback;

  HomePage({this.callback});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPageIndex = 0;
  HomeBloc _homeBloc;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void doCallback() {
    this.widget.callback(1, _selectedPageIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeBloc = Provider.of<HomeBloc>(context);
    _homeBloc.requestGetSlider();
  }

  @override
  void dispose() {
    super.dispose();
    _homeBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                ClipPath(
                  clipper: CustomShapeClipper(),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.red, Colors.redAccent[200]])),
                  ),
                ),
              ],
            ),
            StreamBuilder<ApiResponse<List<model.Slider>>>(
                stream: _homeBloc.sliderStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return UILoading(loadingMessage: snapshot.data.message);
                      case Status.COMPLETED:
                        List<model.Slider> slider = snapshot.data.data;
                        return CarouselSlider(
                          options: CarouselOptions(
                            height: 150,
                            autoPlay: true,
                            enlargeCenterPage: true,
                          ),
                          items: slider
                              .map((item) => Container(
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        child: Stack(
                                          children: <Widget>[
                                            CachedNetworkImage(
                                              imageUrl: item.thumbnail,
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                      "assets/images/placeholder.png"),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Image.asset(
                                                      "assets/images/error.png"),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                            Positioned(
                                              bottom: 0.0,
                                              left: 0.0,
                                              right: 0.0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(
                                                          200, 0, 0, 0),
                                                      Color.fromARGB(0, 0, 0, 0)
                                                    ],
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                  ),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 20.0),
//                                                child: Text(
//                                                  item.title,
//                                                  style: TextStyle(
//                                                    color: Colors.white,
//                                                    fontSize: 20.0,
//                                                    fontWeight: FontWeight.bold,
//                                                  ),
//                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ))
                              .toList(),
                        );
                      case Status.ERROR:
                        return UIError(
                            errorMessage: snapshot.data.message,
                            onRetryPressed: () => _homeBloc.requestGetSlider());
                    }
                  }
                  return Center(
                    child: Text(
                        "Không có dữ liệu, kiểm tra lại kết nối internet của bạn"),
                  );
                }),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                "Danh mục",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            CategoriesWidget(),
            SizedBox(height: 8),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 6, top: 6, right: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Tin mới nhất",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                ItemByCategory.ROUTE_NAME,
                                arguments: {'id': null, 'title': null});
                          },
                          child: Text(
                            "Xem thêm",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  LatestItemsWidget(),
                ],
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 6, top: 6, right: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Sản phẩm mới nhất",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        InkWell(
                          onTap: doCallback,
                          child: Text(
                            "Xem thêm",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton.icon(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: _selectedPageIndex == 0
                                      ? Colors.red
                                      : Colors.grey,
                                  width: 1,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(50)),
                          onPressed: () => _selectPage(0),
                          textColor: _selectedPageIndex == 0
                              ? Colors.red
                              : Colors.grey,
                          icon: Icon(Icons.shopping_cart),
                          label: Text("Rao vặt",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold))),
                      FlatButton.icon(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: _selectedPageIndex == 1
                                      ? Colors.red
                                      : Colors.grey,
                                  width: 1,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(50)),
                          textColor: _selectedPageIndex == 1
                              ? Colors.red
                              : Colors.grey,
                          onPressed: () => _selectPage(1),
                          icon: Icon(Icons.speaker_notes),
                          label: Text("Tin tức",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)))
                    ],
                  ),
                  _selectedPageIndex == 0
                      ? NewSportWidget()
                      : NewProductWidget(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
