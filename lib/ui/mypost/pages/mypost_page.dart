import '../widgets/not_signed_widget.dart';
import '../widgets/signed_widget.dart';
import 'package:flutter/material.dart';
import '../../../common/globals.dart' as globals;

class MyPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return globals.isSigned
        ? Signed()
        : NotSigned();
  }
}



