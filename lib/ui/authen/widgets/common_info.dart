import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/dummy/dummy_data.dart';
import 'package:conecapp/models/request/signup_request.dart';
import 'package:conecapp/ui/others/terms_condition_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../blocs/authen_bloc.dart';

// ignore: must_be_immutable
class CommonInfo extends StatefulWidget {
  String name;
  String birthday;
  String gender;
  Key key;
  void Function(bool) callback;

  CommonInfo.person(
      this.key, this.name, this.callback, this.birthday, this.gender);

  CommonInfo.club(this.key, this.name, this.callback);

  @override
  _CommonInfoState createState() => _CommonInfoState();
}

class _CommonInfoState extends State<CommonInfo> with AutomaticKeepAliveClientMixin<CommonInfo>{
  AuthenBloc _authenBloc;
  final _form = GlobalKey<FormState>();
  final _phoneFocusNode = FocusNode();
  final _passWordFocusNode = FocusNode();
  final _confirmPassWordFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  //
  String _phone,
      _passWord,
      _confirmPassword,
      _email,
      _city,
      _district,
      _ward,
      _address;

  SignUpRequest _signUpRequest;

  @override
  void initState() {
    super.initState();
    if (this.widget.key == ValueKey("person")) {
      _signUpRequest = SignUpRequest.person(
          name: this.widget.name,
          phone: '',
          passWord: '',
          confirmPassword: '',
          birthDay: this.widget.birthday,
          gender: this.widget.gender);
    } else {
      _signUpRequest = SignUpRequest.club(
          name: this.widget.name, phone: '', passWord: '', confirmPassword: '');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authenBloc = Provider.of<AuthenBloc>(context);
  }


  @override
  void dispose() {
    super.dispose();
    _phoneFocusNode.dispose();
    _passWordFocusNode.dispose();
    _confirmPassWordFocusNode.dispose();
    _emailFocusNode.dispose();
  }

  void doCallback() {
    this.widget.name.isEmpty
        ? this.widget.callback(true)
        : this.widget.callback(false);
  }

  void doSignUp() {
    doCallback();
    //
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    if (this.widget.key == ValueKey("person")) {
      _signUpRequest = SignUpRequest.person(
          name: this.widget.name,
          birthDay: this.widget.birthday,
          gender: this.widget.gender,
          phone: _phone,
          passWord: _passWord,
          confirmPassword: _confirmPassword,
          email: _email ?? "",
          address: _address ?? "",
          city: _city ?? "",
          district: _district ?? "",
          ward: _ward ?? "");
    } else {
      _signUpRequest = SignUpRequest.club(
          name: this.widget.name,
          phone: _phone,
          passWord: _passWord,
          confirmPassword: _confirmPassword,
          email: _email ?? "",
          address: _address ?? "",
          city: _city ?? "",
          district: _district ?? "",
          ward: _ward ?? "");
    }
    //call api here
    //final result = _authenBloc.requestSignUp(_signUpRequest);
    //TODO - call api
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      key: _form,
      child: Column(
        children: <Widget>[
          TextFormField(
            maxLines: 1,
            focusNode: _phoneFocusNode,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 18),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passWordFocusNode);
            },
            validator: (value) {
              if (value.length < 10) {
                return "Số điện thoại không hợp lệ";
              }
              return null;
            },
            onSaved: (value) {
              _phone = value;
            },
            decoration: InputDecoration(
                hintText: 'Tài khoản (số điện thoại)',
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 1)),
                contentPadding: EdgeInsets.only(left: 8),
                prefixIcon: Icon(
                  Icons.phone,
                  color: Colors.black,
                ),
                border: const OutlineInputBorder()),
          ),
          SizedBox(height: 8),
          TextFormField(
            maxLines: 1,
            style: TextStyle(fontSize: 18),
            focusNode: _passWordFocusNode,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_confirmPassWordFocusNode);
            },
            validator: (value) {
              if (value.length < 7) {
                return "Mật khẩu phải lớn hơn 6 kí tự";
              }
              return null;
            },
            onChanged: (value) {
              _passWord = value;
            },
            obscureText: true,
            decoration: InputDecoration(
                hintText: 'Mật khẩu',
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 1)),
                contentPadding: EdgeInsets.only(left: 8),
                prefixIcon: Icon(
                  Icons.vpn_key,
                  color: Colors.black,
                ),
                border: const OutlineInputBorder()),
          ),
          SizedBox(height: 8),
          TextFormField(
            maxLines: 1,
            style: TextStyle(fontSize: 18),
            focusNode: _confirmPassWordFocusNode,
            obscureText: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_emailFocusNode);
            },
            validator: (value) {
              debugPrint(value);
              debugPrint(_passWord);
              if (value != _passWord) {
                return "Xác nhận mật khẩu phải trùng với mật khẩu";
              }
              return null;
            },
            onSaved: (value) {
              _confirmPassword = value;
            },
            decoration: InputDecoration(
                hintText: 'Xác nhận mật khẩu (nhập lại mật khẩu)',
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 1)),
                contentPadding: EdgeInsets.only(left: 8),
                prefixIcon: Icon(
                  Icons.confirmation_number,
                  color: Colors.black,
                ),
                border: const OutlineInputBorder()),
          ),
          SizedBox(height: 8),
          TextFormField(
            maxLines: 1,
            style: TextStyle(fontSize: 18),
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            onSaved: (value) {
              _email = value;
            },
            decoration: InputDecoration(
                hintText: 'Email',
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 1)),
                contentPadding: EdgeInsets.only(left: 8),
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.black,
                ),
                border: const OutlineInputBorder()),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () =>
                showCityList(getIndex(DummyData.cityList, selectedCity)),
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.location_city),
                    SizedBox(width: 16),
                    Text(
                      selectedCity ?? "Tỉnh/Thành phố",
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
            onTap: () => selectedCity != null
                ? showDistrictList(
                    getIndex(DummyData.districtList, selectedDistrict))
                : null,
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.home),
                    SizedBox(width: 16),
                    Text(
                      selectedDistrict ?? "Quận/Huyện",
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Spacer(),
                    Text("Thay đổi",
                        style: AppTheme.changeTextStyle(selectedCity != null))
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () => selectedDistrict != null
                ? showWardList(getIndex(DummyData.wardList, selectedWard))
                : null,
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.wallpaper),
                    SizedBox(width: 16),
                    Text(
                      selectedWard ?? "Phường/Xã",
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Spacer(),
                    Text("Thay đổi",
                        style:
                            AppTheme.changeTextStyle(selectedDistrict != null))
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            maxLines: 1,
            style: TextStyle(fontSize: 18),
            textInputAction: TextInputAction.done,
            onSaved: (value) {
              _address = value;
            },
            decoration: InputDecoration(
                hintText: 'Số nhà, tên đường',
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 1)),
                contentPadding: EdgeInsets.only(left: 8),
                prefixIcon: Icon(
                  Icons.location_on,
                  color: Colors.black,
                ),
                border: const OutlineInputBorder()),
          ),
          SizedBox(height: 8),
          RichText(
            text: TextSpan(
                text:
                    "Bằng việc đăng ký sử dụng ứng dụng của chúng tôi, bạn đã đồng ý với các ",
                style: TextStyle(color: Colors.black, fontSize: 14),
                children: <TextSpan>[
                  TextSpan(
                      text: "Chính sách của Conec",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.of(context)
                            .pushNamed(TermConditionPage.ROUTE_NAME),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 14))
                ]),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () {
              doSignUp();
            },
            child: Container(
              //margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 45,
              child: Center(
                child: Text(
                  'Đăng ký',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  var selectedCity;
  var selectedDistrict;
  var selectedWard;

  //
  int getIndex(List<String> list, String selectedItem) {
    return selectedItem != null
        ? list.indexOf(list.firstWhere((element) => element == selectedItem))
        : 0;
  }

  //modal bottomsheet
  void showCityList(int index) {
    var controller = FixedExtentScrollController(initialItem: index);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            height: 250,
            child: CupertinoPicker(
              scrollController: controller,
              onSelectedItemChanged: (value) {
                setState(() {
                  selectedCity = DummyData.cityList[value];
                });
              },
              itemExtent: 32,
              children: DummyData.cityList.map((e) => Text(e)).toList(),
            ),
          );
        }).then((value) => debugPrint(selectedCity));
  }

  void showDistrictList(int index) {
    var controller = FixedExtentScrollController(initialItem: index);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            height: 250,
            child: CupertinoPicker(
              scrollController: controller,
              onSelectedItemChanged: (value) {
                setState(() {
                  selectedDistrict = DummyData.districtList[value];
                });
              },
              itemExtent: 32,
              children: DummyData.districtList.map((e) => Text(e)).toList(),
            ),
          );
        }).then((value) => debugPrint(selectedDistrict));
  }

  void showWardList(int index) {
    var controller = FixedExtentScrollController(initialItem: index);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            height: 250,
            child: CupertinoPicker(
              scrollController: controller,
              onSelectedItemChanged: (value) {
                setState(() {
                  selectedWard = DummyData.wardList[value];
                });
              },
              itemExtent: 32,
              children: DummyData.wardList.map((e) => Text(e)).toList(),
            ),
          );
        }).then((value) => debugPrint(selectedWard));
  }

  @override
  bool get wantKeepAlive => true;
}
