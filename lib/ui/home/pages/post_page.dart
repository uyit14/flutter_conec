import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/nearby_response.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import '../../../common/globals.dart' as globals;

import 'item_detail_page.dart';

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  HomeBloc _homeBloc = HomeBloc();
  List<Trainer> listTrainers = [];

  @override
  void initState() {
    super.initState();
    //initDummy();
    _homeBloc.requestGetNearBy(globals.latitude, globals.longitude, 5);
  }

  initDummy() {
    listTrainers = List.generate(
        10,
        (index) => Trainer(
            id: index.toString(),
            avatar: Helper.baseURL +
                "/files/account/06-Oct-2020/image_picker126325627618262735.jpg",
            name: "An Yoga",
            gender: "Nam",
            dob: Helper.formatDob("1990-08-04T00:00:00"),
            phoneNumber: "0874589658",
            getAddress: "1 Vo Van Ngan, Quận Thủ Đức"));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<ApiResponse<NearbyResponse>>(
          stream: _homeBloc.nearByStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return UILoading(loadingMessage: snapshot.data.message);
                case Status.COMPLETED:
                  List<Trainer> listTrainers = snapshot.data.data.data.trainers;
                  if(listTrainers.length > 0){
                    return ListView.builder(
                        itemCount: listTrainers.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              //
                            },
                            child: Card(
                              margin: EdgeInsets.all(8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                        flex: 4,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: CachedNetworkImage(
                                            imageUrl: listTrainers[index].avatar,
                                            progressIndicatorBuilder: (context,
                                                url, downloadProgress) =>
                                                CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress),
                                            errorWidget: (context, url, error) =>
                                                Image.asset(
                                                  "assets/images/error.png",
                                                  height: 100,
                                                  width: 120,
                                                ),
                                            fit: BoxFit.cover,
                                            height: 100,
                                            width: 120,
                                          ),
                                        )),
                                    SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listTrainers[index].name ?? "",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          listTrainers[index].phoneNumber ?? "",
                                          style: TextStyle(
                                              fontSize: 18),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          listTrainers[index].getAddress ?? "",
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  }
                  return Container(
                      child: Center(
                          child: Text("Không có câu lạc bộ nào gần đây!")));
                case Status.ERROR:
                  return UIError(errorMessage: snapshot.data.message);
              }
            }
            return Container(
                child: Center(child: Text("Không có câu lạc bộ nào gần đây!")));
          }),
    );
  }
}
