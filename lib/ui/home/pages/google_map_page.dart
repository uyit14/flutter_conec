import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapPage extends StatefulWidget {
  static const ROUTE_NAME = '/google-map';

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  double lat;
  double lng;
  String postId;
  String title;
  String address;
  Set<Marker> markers = Set();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
    ModalRoute.of(context).settings.arguments as Map<String, Object>;
    lat = routeArgs['lat'] as double;
    lng = routeArgs['lng'] as double;
    postId = routeArgs['postId'];
    title = routeArgs['title'];
    address = routeArgs['address'];
    final marker = Marker(
        markerId: MarkerId(postId),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: address),
    );
    markers.add(marker);
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Quay lại"),),
        body: GoogleMap(
          initialCameraPosition:
              CameraPosition(target: LatLng(lat, lng), zoom: 16),
          myLocationButtonEnabled: true,
          mapToolbarEnabled: true,
          markers: markers,
        ),
      ),
    );
  }
}
