import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:track_test/model/UserModel.dart';

class AuthService {
  bool isAuth = false;
  String url = "https://bike-go.workaround.services/api"; // emulator
  String errorRegister = "";
  String errorLogin = "";
  String token = "";

  final Storage = FlutterSecureStorage();

  late User user;

  AuthService() {
    getUserFromStorage();
  }

  Future<void> getUserFromStorage() async {
    var token = await Storage.read(key: "token");
    var user_data = await Storage.read(key: "user");
    if (token != null && user_data != null) {
      user = User.fromJson(jsonDecode(user_data));
      this.token = token;
      isAuth = true;
    } else {
      isAuth = false;
    }
  }

  Future<void> logout() async {
    await Storage.delete(key: "token");
  }

  Future<bool> Register(String nom, String email, String password) async {
    final request = {"name": nom, "email": email, "password": password};
    try {
      final response = await http.post(Uri.parse("$url/RegitserUser"),
          body: jsonEncode(request),
          headers: {"Content-Type": "application/json;charset=utf-8"});
      if (response.statusCode == 200) {
        return true;
      } else {
        errorRegister = response.body;
        return false;
      }
    } catch (e) {
      print(e);
      errorRegister = e.toString();
      return false;
    }
  }

  Future<bool> LoginUser(String email, String password) async {
    final request = {"email": email, "password": password};
    try {
      final response = await http.post(
          Uri.parse(
            "$url/AuthUser",
          ),
          body: jsonEncode(request),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 201) {
        isAuth = true;
        final Map<String, dynamic> responseData = json.decode(response.body);
        final userData = responseData['user'];
        final token_data = responseData['token'];
        if (userData != null) {
          user = User.fromJson(userData);
          String token = token_data.toString();
          isAuth = true;
          this.token = token;
          Storage.write(key: "token", value: token);
          Storage.write(key: "user", value: jsonEncode(user!.toJson()));
          return true;
        } else {
          errorLogin = "User data not found in response !!!! ";
          return false;
        }
      } else {
        errorLogin = response.body;
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
