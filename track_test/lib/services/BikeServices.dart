import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:track_test/global/env.dart';
import 'package:track_test/model/BikeModel.dart';
import 'package:track_test/model/MenuModel.dart';
import 'package:track_test/services/AuthServices.dart';

class BikeSrvice {
  bool correctAnswer = true;
  late AuthService authService = AuthService();

  Future<List<BikeModel>> getBikes() async {
    await authService.getUserFromStorage();
    try {
      final response = await http.get(Uri.parse(
          "$BASE_URL_BACKEND/getBikes/" + authService.user!.id.toString()));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body)['data'];
        var bikes = jsonData
            .map<BikeModel>((json) => BikeModel.fromJson(json))
            .toList();
        return bikes;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<MenuModel> getMenuBikes() async {
    await authService.getUserFromStorage();

    var bikes = new MenuModel(bikesReserved: 0, bikesNotReserved: 0);
    try {
      final response = await http.get(Uri.parse(
          "$BASE_URL_BACKEND/getBikes/" + authService.user!.id.toString()));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        bikes = MenuModel.fromJson(jsonData);
        return bikes;
      } else {
        return bikes;
      }
    } catch (e) {
      return bikes;
    }
  }

  Future<BikeModel> getBikeById(id) async {
    var bikes;
    try {
      final response =
          await http.get(Uri.parse("$BASE_URL_BACKEND/getBikeById/$id"));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body)['data'];
        var bikes = BikeModel.fromJson(jsonData);
        return bikes;
      } else {
        return bikes;
      }
    } catch (e) {
      return bikes;
    }
  }

  Future<String> UpdateBikeReserved(int id) async {
    try {
      final response = await http
          .put(Uri.parse('$BASE_URL_BACKEND/UpdateReserved/' + id.toString()));
      String message = jsonDecode(response.body)['Message'];
      return message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> DeleteBike(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$BASE_URL_BACKEND/DeleteBike/' + id.toString()));
      String message = jsonDecode(response.body)['Message'];
      return message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> updateBike(int id, double latitude, double longitude) async {
    try {
      final Map<String, dynamic> requestBody = {
        'latitude': latitude,
        'longitude': longitude,
      };

      final response = await http.put(
        Uri.parse('$BASE_URL_BACKEND/update/$id'),
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body)['data']; // "Update Success"
      } else if (response.statusCode == 404) {
        return jsonDecode(response.body)['data']; // "Not Found"
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<bool> AddBike(String id, String name, double lat, double long) async {
    try {
      await authService.getUserFromStorage();

      final request = {
        "id": id,
        "name": name,
        "latitude": lat,
        "longitude": long,
        "user_id": authService.user!.id.toString()
      };
      final response = await http.post(Uri.parse('$BASE_URL_BACKEND/AddBike'),
          body: jsonEncode(request),
          headers: {'Content-Type': 'application/json'});
      String message = jsonDecode(response.body)['message'];
      if (message.contains("already exists")) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
