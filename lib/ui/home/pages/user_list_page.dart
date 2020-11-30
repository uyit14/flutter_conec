import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/nearby_response.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:flutter/material.dart';
import '../../../common/globals.dart' as globals;

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  HomeBloc _homeBloc = HomeBloc();
  List<Users> listTrainers = [];

  @override
  void initState() {
    super.initState();
    //initDummy();
    _homeBloc.requestGetNearBy(globals.latitude, globals.longitude, 50);
  }

  initDummy() {
    listTrainers = List.generate(
        10,
        (index) => Users(
            id: index.toString(),
            avatar: "https://conec.vn" +
                "/files/account/06-Oct-2020/image_picker126325627618262735.jpg",
            name: "An Yoga",
            gender: "Nam",
            dob: Helper.formatDob("1990-08-04T00:00:00"),
            phoneNumber: "0874589658",
            distance: 5,
            getAddress: "1 Vo Van Ngan, P. Binh Tho, Quận Thủ Đức, TP. Ho Chi Minh"));
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
                  //List<Users> listTrainers = snapshot.data.data.data.users;
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
                                        flex: 3,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: CachedNetworkImage(
                                            imageUrl: listTrainers[index].avatar,
                                            placeholder: (context, url) =>
                                                Image.asset(
                                                    "assets/images/placeholder.png",
                                                    width: 100,
                                                    height: 120),
                                            fit: BoxFit.cover,
                                            height: 100,
                                            width: 120,
                                          ),
                                        )),
                                    SizedBox(width: 12),
                                    Expanded(
                                      flex: 8,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            listTrainers[index].name ?? "",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "SDT: ${listTrainers[index].phoneNumber}",
                                            style: TextStyle(
                                                fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "Cách đây: ${listTrainers[index].distance} km",
                                            style: TextStyle(
                                                fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            listTrainers[index].getAddress ?? "",
                                            style: TextStyle(
                                                fontSize: 14, color: Colors.grey),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
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
