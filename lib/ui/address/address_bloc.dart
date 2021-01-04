import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/location/city_response.dart';
import 'package:conecapp/repositories/mypost/mypost_repository.dart';
import 'package:tiengviet/tiengviet.dart';

class AddressBloc{
  MyPostRepository _repository;

  AddressBloc() {
    _repository = MyPostRepository();
  }

  List<Province> _originalProvince = List<Province>();
  List<Province> _originalDistrict = List<Province>();
  List<Province> _originalWard = List<Province>();

  //cityList
  StreamController<ApiResponse<List<Province>>> _provincesController = StreamController();
  Stream<ApiResponse<List<Province>>> get provincesStream =>
      _provincesController.stream;
  //districtList
  StreamController<ApiResponse<List<Province>>> _districtsController = StreamController();
  Stream<ApiResponse<List<Province>>> get districtsStream =>
      _districtsController.stream;
  //wardList
  StreamController<ApiResponse<List<Province>>> _wardsController = StreamController();
  Stream<ApiResponse<List<Province>>> get wardsStream =>
      _wardsController.stream;

  void requestGetProvinces() async{
    _provincesController.sink.add(ApiResponse.loading());
    try{
      final result = await _repository.getListProvince();
      _originalProvince.addAll(result);
      _provincesController.sink.add(ApiResponse.completed(result));
    }catch(e){
      print(e.toString());
      _provincesController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void clearProvinceSearch(){
    _provincesController.sink.add(ApiResponse.completed(_originalProvince));
  }

  void searchProvinceAction(String keyWord){
    List<Province> _searchResult = List<Province>();
    _originalProvince.forEach((province) {
      if(_searchProvince(province, keyWord)){
        _searchResult.add(province);
      }
    });
    _provincesController.sink.add(ApiResponse.completed(_searchResult));
  }


  bool _searchProvince(Province province, String txtSearch){
    if (TiengViet.parse(province.name).toLowerCase().contains(txtSearch.toLowerCase())) {
      return true;
    }
    return false;
  }

  void requestGetDistricts({String provinceId, String provinceName}) async{
    _districtsController.sink.add(ApiResponse.loading());
    var result;
    try{
      if(provinceId!=null){
         result = await _repository.getListDistrict(provinceId);
      }else{
         result = await _repository.getListDistrictByProvinceName(provinceName);
      }

      _originalDistrict.addAll(result);
      _districtsController.sink.add(ApiResponse.completed(result));
    }catch(e){
      print(e.toString());
      _districtsController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void searchDistrictAction(String keyWord){
    List<Province> _searchResult = List<Province>();
    _originalDistrict.forEach((district) {
      if(_searchProvince(district, keyWord)){
        _searchResult.add(district);
      }
    });
    _districtsController.sink.add(ApiResponse.completed(_searchResult));
  }

  void clearDistrictSearch(){
    _districtsController.sink.add(ApiResponse.completed(_originalDistrict));
  }

  void requestGetWards({String districtId, String districtName}) async{
    _wardsController.sink.add(ApiResponse.loading());
    var result;
    try{
      if(districtId!=null){
         result = await _repository.getListWard(districtId);
      }else{
         result = await _repository.getListWardByName(districtName);
      }
      _originalWard.addAll(result);
      _wardsController.sink.add(ApiResponse.completed(result));
    }catch(e){
      print(e.toString());
      _wardsController.sink.add(ApiResponse.error(e.toString()));
    }
  }

  void searchWardAction(String keyWord){
    List<Province> _searchResult = List<Province>();
    _originalWard.forEach((ward) {
      if(_searchProvince(ward, keyWord)){
        _searchResult.add(ward);
      }
    });
    _wardsController.sink.add(ApiResponse.completed(_searchResult));
  }

  void clearWardSearch(){
    _wardsController.sink.add(ApiResponse.completed(_originalWard));
  }

  void dispose() {
    _provincesController.close();
    _wardsController.close();
    _districtsController.close();
  }
}