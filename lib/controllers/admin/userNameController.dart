import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
class UserNameController extends GetxController {
  var name = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadValue();
  }

  void loadValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name.value = prefs.getString('name') ?? '';
  }

  void saveValue(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', username);
    name.value = username;
  }
}
