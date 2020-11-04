import 'dart:io';
import 'package:conecapp/common/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'app_exception.dart';

class ApiBaseHelper {
  final String _baseUrl = "https://conec.vn";

  Future<dynamic> get(String url, {dynamic headers}) async {
    debugPrint('Api Get, url ${_baseUrl+url} \n header $headers');
    var responseJson;
    try {
      final response = await http.get(_baseUrl + url, headers: headers);
      responseJson = _returnResponse(response);
    } on SocketException {
      debugPrint('No net');
      throw FetchDataException('No Internet connection');
    } catch (e) {
      print("aaaa" + e.toString());
    }
    debugPrint('api get recieved!');
    Helper.log("Api Get, body", '${responseJson.toString()}');
    return responseJson;
  }

  Future<dynamic> post(String url, {dynamic body, dynamic headers}) async {
    debugPrint('Api Post, url ${_baseUrl+url}');
    Helper.log("Api Post, body", '$body');
    debugPrint('Api Post, header $headers');
    var responseJson;
    var response;
    try {
      response = await http
          .post(_baseUrl + url,
              body: body,
              headers: headers == null ? Helper.headerNoToken : headers)
          .timeout(Duration(seconds: 20));
      responseJson = _returnResponse(response);
    } catch (e) {
      debugPrint(e.toString() + "--------");
      throw FetchDataException("Có lỗi xảy ra, vui lòng thử lại sau!");
    }
    debugPrint('api post.');
    return responseJson;
  }

  Future<dynamic> put(String url, dynamic body) async {
    debugPrint('Api Put, url $url');
    var responseJson;
    try {
      final response = await http.put(_baseUrl + url, body: body);
      responseJson = _returnResponse(response);
    } on SocketException {
      debugPrint('No net');
      throw FetchDataException('No Internet connection');
    }
    debugPrint('api put.');
    debugPrint(responseJson.toString());
    return responseJson;
  }

  Future<dynamic> delete(String url) async {
    debugPrint('Api delete, url $url');
    var apiResponse;
    try {
      final response = await http.delete(_baseUrl + url);
      apiResponse = _returnResponse(response);
    } on SocketException {
      debugPrint('No net');
      throw FetchDataException('No Internet connection');
    }
    debugPrint('api delete.');
    return apiResponse;
  }
}



dynamic _returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      var responseJson = json.decode(response.body.toString());
      //debugPrint(responseJson.toString());
      return responseJson;
    case 400:
      throw BadRequestException(response.body.toString());
    case 401:
    case 403:
      throw UnauthorisedException(response.body.toString());
    case 500:
      throw FetchDataException('Error : ${response.body.toString()}');
    default:
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
  }
}
