import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UILoadingOpacity extends StatelessWidget {
  final String loadingMessage;

  const UILoadingOpacity({Key key, this.loadingMessage}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CupertinoActivityIndicator(radius: 16),
            SizedBox(height: 8),
            Text(
              loadingMessage??"",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.lightGreen,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
