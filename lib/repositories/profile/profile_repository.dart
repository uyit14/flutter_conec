import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/models/response/profile/profile_response.dart';
import '../../common/globals.dart' as globals;

class ProfileRepository{
  ApiBaseHelper _helper = ApiBaseHelper();
  static final _header = {
    'authorization': "Bearer ${globals.token}",
    'Content-Type': "application/json"
  };

  Future<ProfileResponse> fetchProfile() async {
    final response = await _helper.post("/api/Account/GetProfile", headers: _header);
    print(response);
    return ProfileResponse.fromJson(response);
  }
}