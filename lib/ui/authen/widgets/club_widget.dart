import 'package:flutter/material.dart';

class Club extends StatefulWidget {
  @override
  _ClubState createState() => _ClubState();
}

class _ClubState extends State<Club> {
  var _clubNameController = TextEditingController();
  var _clubNameValidate = false;

  validationName(bool isValidate){
    setState(() {
      _clubNameValidate = isValidate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Card(
            elevation: 8,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _clubNameController,
                    maxLines: 1,
                    style: TextStyle(fontSize: 18),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        hintText: 'Tên câu lạc bộ',
                        errorText: _clubNameValidate ? "Vui lòng nhập tên câu lạc bộ" : null,
                        focusedBorder: const OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.green, width: 1)),
                        contentPadding: EdgeInsets.only(left: 8),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        border: const OutlineInputBorder()),
                  ),
                  SizedBox(height: 8),
                  //CommonInfo.club(ValueKey("club"), _clubNameController.text, validationName)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}