import 'package:conecapp/common/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/custom_icons.dart';

class Person extends StatefulWidget {
  @override
  _PersonState createState() => _PersonState();
}

class _PersonState extends State<Person> {

  var _birthDay = "1-1-2000";
  var _gender = "Nam";
  var _isMale = true;
  var _nameController = TextEditingController();
  var _nameValidate = false;

  validationName(bool isValidate) {
    setState(() {
      _nameValidate = isValidate;
    });
  }

  @override
  Widget build(BuildContext context) {
    ;
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
                    controller: _nameController,
                    maxLines: 1,
                    style: TextStyle(fontSize: 18),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        hintText: 'Họ và tên',
                        errorText:
                            _nameValidate ? "Vui lòng nhập họ tên" : null,
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
                  InkWell(
                    onTap: _showDatePicker,
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.date_range),
                            SizedBox(width: 16),
                            Text(
                              _birthDay,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Spacer(),
                            Text("Thay đổi", style: AppTheme.changeTextStyle(true))
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: _showGenderPicker,
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.group),
                            SizedBox(width: 16),
                            Text(
                              _gender,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Spacer(),
                            Text("Thay đổi", style: AppTheme.changeTextStyle(true))
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  // CommonInfo.person(ValueKey("person"), _nameController.text,
                  //     validationName, _birthDay, _gender)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showDatePicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: CupertinoDatePicker(
              initialDateTime: DateTime.now(),
              onDateTimeChanged: (date) {
                setState(() {
                  _birthDay = DateFormat('dd-MM-yyyy').format(date);
                });
              },
              mode: CupertinoDatePickerMode.date,
            ),
          );
        });
  }

  _showGenderPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: _isMale ? Colors.red : Colors.grey,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(50)),
                        onPressed: () {
                          setState(() {
                            _gender = "Nam";
                          });
                          setModalState(() {
                            _isMale = !_isMale;
                          });
                        },
                        textColor: _isMale ? Colors.red : Colors.grey,
                        icon: Icon(MyFlutterApp.male),
                        label: Text("Nam",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))),
                    FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: !_isMale ? Colors.red : Colors.grey,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(50)),
                        textColor: !_isMale ? Colors.red : Colors.grey,
                        onPressed: () {
                          setState(() {
                            _gender = "Nữ";
                          });
                          setModalState(() {
                            _isMale = !_isMale;
                          });
                        },
                        icon: Icon(MyFlutterApp.female),
                        label: Text("Nữ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)))
                  ],
                ),
              );
            },
          );
        });
  }
}
