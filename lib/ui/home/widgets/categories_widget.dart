import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:conecapp/ui/home/pages/items_by_category_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class CategoriesWidget extends StatefulWidget {
  @override
  _CategoriesWidgetState createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  HomeBloc _homeBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeBloc = Provider.of<HomeBloc>(context);
    _homeBloc.requestGetTopic();
  }

  @override
  void dispose() {
    super.dispose();
    _homeBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      child: StreamBuilder<ApiResponse<List<Topic>>>(
          stream: _homeBloc.topicStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return UILoading(loadingMessage: snapshot.data.message);
                case Status.COMPLETED:
                  List<Topic> topics = snapshot.data.data;
                  return ListView.builder(
                      itemCount: topics.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                ItemByCategory.ROUTE_NAME,
                                arguments: {
                                  'id': topics[index].id,
                                  'title': topics[index].title
                                });
                          },
                          child: Container(
                            width: 145,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    offset: Offset(
                                        2, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.all(4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6)),
                                      child: CachedNetworkImage(
                                        imageUrl: topics[index].thumbnail,
                                        placeholder: (context, url) =>
                                            Image.asset(
                                                "assets/images/placeholder.png"),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                                "assets/images/error.png"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    topics[index].title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 4),
                                ],
                              )),
                        );
                      });
                case Status.ERROR:
                  return UIError(
                      errorMessage: snapshot.data.message,
                      onRetryPressed: () => _homeBloc.requestGetTopic());
              }
            }
            return Container(child: Text("Không có dữ liệu, kiểm tra lại kết nối internet của bạn"));
          }),
    );
  }
}
