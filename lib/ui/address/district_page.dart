import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/location/city_response.dart';
import 'package:conecapp/ui/address/address_bloc.dart';
import 'package:flutter/material.dart';

class DistrictPage extends StatefulWidget {
  static const ROUTE_NAME = '/district';

  @override
  _DistrictPageState createState() => _DistrictPageState();
}

class _DistrictPageState extends State<DistrictPage> {
  AddressBloc _addressBloc = AddressBloc();
  var _district;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
    ModalRoute.of(context).settings.arguments as Map<String, Object>;
    _addressBloc.requestGetDistricts(routeArgs['provinceId']);
  }

  @override
  void dispose() {
    super.dispose();
    _addressBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Chọn quận / huyện"),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black12,
                  ),
                  height: 40,
                  child: TextFormField(
                    maxLines: 1,
                    onChanged: (value) {
                      if(value.length == 0){
                        _addressBloc.clearDistrictSearch();
                      }
                      _addressBloc.searchDistrictAction(value);
                    },
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                        hintText: 'Tìm quận, huyện',
                        prefixIcon: Icon(Icons.search),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white, width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: EdgeInsets.only(left: 8)),
                  ),
                ),
                _district!=null ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Chọn gần đây",
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: FontWeight.w400)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(_district.name ?? "",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400)),
                          Spacer(),
                          Icon(Icons.check)
                        ],
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ) : Container(),
                Container(
                  color: Colors.black12,
                  width: double.infinity,
                  height: 1,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: StreamBuilder<ApiResponse<List<Province>>>(
                      stream: _addressBloc.districtsStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          switch (snapshot.data.status) {
                            case Status.LOADING:
                              return UILoading();
                            case Status.COMPLETED:
                              List<Province> provinces = snapshot.data.data;
                              return ListView.builder(
                                  itemCount: provinces.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: (){
                                        Navigator.of(context).pop(provinces[index]);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              provinces[index].name ?? "",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            SizedBox(height: 12),
                                            Container(
                                              color: Colors.black12,
                                              width: double.infinity,
                                              height: .5,
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            case Status.ERROR:
                              return UIError(errorMessage: snapshot.data.message);
                          }
                        }
                        return Center(child: Text("Không có dữ liệu"));
                      }),
                ),
              ],
            ),
          ),
        ));
  }
}
