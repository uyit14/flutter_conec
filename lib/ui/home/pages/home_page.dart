import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/latest_item.dart';
import 'package:conecapp/models/response/slider.dart' as model;
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:conecapp/ui/home/widgets/categories_widget.dart';
import 'package:conecapp/ui/home/widgets/latest_items_widget.dart';
import 'package:conecapp/ui/home/widgets/new_product_widget.dart';
import 'package:conecapp/ui/home/widgets/new_sport_widget.dart';
import 'package:conecapp/ui/news/pages/news_detail_page.dart';
import 'package:conecapp/ui/news/pages/sell_detail_page.dart';
import '../../../common/globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/custom_clipper.dart';
import 'package:flutter/material.dart';
import 'item_detail_page.dart';
import 'items_by_category_page.dart';

class HomePage extends StatefulWidget {
  final void Function(int, int) callback;

  HomePage({this.callback});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPageIndex = 0;
  HomeBloc _homeBloc = HomeBloc();
  //ScrollController _scrollController = ScrollController();
  List<LatestItem> clubs = List<LatestItem>();

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void doCallback({int page}) {
    this.widget.callback(1, page == 0 ? 0 : _selectedPageIndex);
  }

  @override
  void initState() {
    super.initState();
    _homeBloc.requestGetSlider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getLocation();
  }

  void getLocation() async {
    print("hereeeeeee");
    Position position = await Geolocator.getCurrentPosition();
    print("latttt: ${position.latitude}" ?? "---aaa---");
    print("longgg: ${position.longitude}" ?? "---aaa---");
    globals.latitude = position.latitude;
    globals.longitude = position.longitude;
    _homeBloc.requestGetNearByClub(position.latitude, position.longitude);
    _homeBloc.nearByClubStream.listen((event) {
      if (event.status == Status.COMPLETED) {
        if (event.data.length > 0) {
          setState(() {
            clubs = event.data;
          });
          //_scrollToBottom();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _homeBloc.dispose();
    //_scrollController.dispose();
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
                            height: Helper.isTablet(context) ? 300 : 175,
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
                                                    vertical: 5.0,
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
            clubs.length > 0
                ? Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tin ưu tiên",
                          style:
                              TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          onTap: () => doCallback(page: 0),
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
                  )
                : Container(),
            clubs.length > 0
                ? Card(
              child: CarouselSlider(
                options: CarouselOptions(
                    height: Helper.isTablet(context) ? 300 : 150,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.3
                ),
                // items: clubs
                //     .map((item) => Banner(
                //   message: "Ưu tiên",
                //   location: BannerLocation.topEnd,
                //   color: Colors.deepOrange,
                //       child: InkWell(
                //         onTap: (){
                //           if(item.topicId == "333f691d-6595-443d-bae3-9a2681025b53"){
                //             Navigator.of(context).pushNamed(
                //                 NewsDetailPage.ROUTE_NAME,
                //                 arguments: {
                //                   'postId': item.postId,
                //                 });
                //           }else if(item.topicId == "333f691d-6585-443a-bae3-9a2681025b53"){
                //             Navigator.of(context).pushNamed(
                //                 SellDetailPage.ROUTE_NAME,
                //                 arguments: {
                //                   'postId': item.postId,
                //                 });
                //           }else{
                //             Navigator.of(context).pushNamed(
                //                 ItemDetailPage.ROUTE_NAME,
                //                 arguments: {
                //                   'postId': item.postId,
                //                   'title': item.title,
                //                 });
                //           }
                //         },
                //         child: Container(
                //   child: ClipRRect(
                //           borderRadius: BorderRadius.all(
                //               Radius.circular(8)),
                //           child: Stack(
                //             children: <Widget>[
                //               CachedNetworkImage(
                //                 imageUrl: item.thumbnail,
                //                 placeholder: (context, url) =>
                //                     Image.asset(
                //                         "assets/images/placeholder.png"),
                //                 errorWidget: (context, url,
                //                     error) =>
                //                     Image.asset(
                //                         "assets/images/error.png"),
                //                 fit: BoxFit.cover,
                //                 width: double.infinity,
                //               ),
                //               Positioned(
                //                 bottom: 0.0,
                //                 left: 0.0,
                //                 right: 0.0,
                //                 child: Container(
                //                   decoration: BoxDecoration(
                //                     gradient: LinearGradient(
                //                       colors: [
                //                         Color.fromARGB(
                //                             200, 0, 0, 0),
                //                         Color.fromARGB(0, 0, 0, 0)
                //                       ],
                //                       begin:
                //                       Alignment.bottomCenter,
                //                       end: Alignment.topCenter,
                //                     ),
                //                   ),
                //                   padding: EdgeInsets.symmetric(
                //                       vertical: 10.0,
                //                       horizontal: 20.0),
                //                                  child: Column(
                //                                    children: [
                //                                      Text(
                //                                        item.title,
                //                                        maxLines: 3,
                //                                        overflow: TextOverflow.ellipsis,
                //                                        style: TextStyle(
                //                                          color: Colors.white,
                //                                          fontSize: 16,
                //                                          fontWeight: FontWeight.bold,
                //                                        ),
                //                                      ),
                //                                      SizedBox(height: 6),
                //                                      Text(
                //                                        item.price != null &&
                //                                            item.price != 0
                //                                            ? '${Helper.formatCurrency(item.price)} VND'
                //                                            : "Liên hệ",
                //                                        style: TextStyle(
                //                                          color: Colors.white,
                //                                          fontSize: 16,
                //                                          fontWeight: FontWeight.bold,
                //                                        ),
                //                                      ),
                //                                    ],
                //                                  ),
                //                 ),
                //               ),
                //             ],
                //           )),
                // ),
                //       ),
                //     ))
                //     .toList(),
                items: clubs
                    .map((item) => InkWell(
                      onTap: (){
                        if(item.topicId == "333f691d-6595-443d-bae3-9a2681025b53"){
                          Navigator.of(context).pushNamed(
                              NewsDetailPage.ROUTE_NAME,
                              arguments: {
                                'postId': item.postId,
                              });
                        }else if(item.topicId == "333f691d-6585-443a-bae3-9a2681025b53"){
                          Navigator.of(context).pushNamed(
                              SellDetailPage.ROUTE_NAME,
                              arguments: {
                                'postId': item.postId,
                              });
                        }else{
                          Navigator.of(context).pushNamed(
                              ItemDetailPage.ROUTE_NAME,
                              arguments: {
                                'postId': item.postId,
                                'title': item.title,
                              });
                        }
                      },
                      child: Container(
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
                                    child: Column(
                                      children: [
                                        Text(
                                          item.title,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          item.price != null &&
                                              item.price != 0
                                              ? '${Helper.formatCurrency(item.price)} VND'
                                              : "Liên hệ",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ))
                    .toList(),
              ),
                  )
                : Container(),
            clubs.length > 0 ? SizedBox(height: 8) : Container(),
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
                          label: Text("Bản tin",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
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
                          label: Text("Dụng cụ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold))),
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
