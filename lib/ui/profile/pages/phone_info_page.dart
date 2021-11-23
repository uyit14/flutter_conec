import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';

class PhoneInfoPage extends StatefulWidget {
  static const ROUTE_NAME = "phone-info";

  @override
  _PhoneInfoPageState createState() => _PhoneInfoPageState();
}

class _PhoneInfoPageState extends State<PhoneInfoPage> {
  AndroidDeviceInfo androidInfo;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: FutureBuilder(
            future: deviceInfo.androidInfo,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              androidInfo = snapshot.data;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("display: " + androidInfo.display),
                  Text("androidId: " + androidInfo.androidId),
                  Text("device: " + androidInfo.device),
                  Text("product: " + androidInfo.product),
                  Text("model: " + androidInfo.model),
                  Text("width: " + w.toString()),
                  Text("height: " + h.toString()),
                ],
              );
            }),
      ),
    );
  }
}
