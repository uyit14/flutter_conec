import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/nearby_response.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../common/globals.dart' as globals;

class UserMapPage extends StatefulWidget {
  @override
  _UserMapPageState createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage> {
  HomeBloc _homeBloc = HomeBloc();
  bool _isLoading = false;
  bool _isShowEmpty = false;
  Iterable markers = [];

  @override
  void initState() {
    super.initState();
    _homeBloc.requestGetNearBy(globals.latitude, globals.longitude, 50);
    _homeBloc.nearByStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          setState(() {
            _isLoading = true;
          });
          return;
        case Status.COMPLETED:
          NearbyResponse nearbyResponse = event.data;
          if (nearbyResponse.data.users.length <= 0) {
            setState(() {
              _isShowEmpty = true;
              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
              _isShowEmpty = false;
            });
            Iterable _markers =
                Iterable.generate(nearbyResponse.data.users.length, (index) {
              LatLng latLngMarker = LatLng(nearbyResponse.data.users[index].lat,
                  nearbyResponse.data.users[index].lng);
              return Marker(
                markerId: MarkerId("marker$index"),
                position: latLngMarker,
                infoWindow: InfoWindow(
                    title: '${nearbyResponse.data.users[index].name ?? ""} ${nearbyResponse.data.users[index].phoneNumber ?? ""}',
                    snippet: nearbyResponse.data.users[index].getAddress ?? ""),
              );
            });

            setState(() {
              markers = _markers;
            });
          }
          return;
        case Status.ERROR:
          setState(() {
            _isShowEmpty = true;
            _isLoading = false;
          });
          return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: Set.from(
        markers,
      ),
      initialCameraPosition: CameraPosition(
          target: LatLng(globals.latitude ?? 0.0, globals.longitude ?? 0.0), zoom: 14),
      onMapCreated: (GoogleMapController controller) {},
    );
  }
}
