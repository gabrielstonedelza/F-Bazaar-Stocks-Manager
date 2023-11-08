import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ProfileController extends GetxController {
  bool isLoading = true;
  late String fullName = "";
  late String email = "";
  late String username = "";
  late String profilePicture = "";
  late String phoneNumber = "";
  late String userId = "";

  Future<void> getMyProfile(String token) async {
    const profileLink = "https://f-bazaar.com/profile/profile/";
    var link = Uri.parse(profileLink);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $token"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      userId = jsonData['user'].toString();
      fullName = jsonData['get_users_fullname'];
      email = jsonData['get_email'];
      username = jsonData['get_username'];
      profilePicture = jsonData['get_profile_pic'];
      phoneNumber = jsonData['get_phone'];
      update();
    } else {
      if (kDebugMode) {
        print(response.body);
      }
    }
  }
}
