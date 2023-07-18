import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  Future<bool> setLogIn(String state) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool result = await sharedPreferences.setString('state', state);
    return result;
  }
  Future<String?> isLogIn()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? result = await sharedPreferences.getString('state');
    return result;
  }
}
