import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../screens/homepage.dart';
import '../screens/loginview.dart';
import '../statics/appcolors.dart';

class RegistrationController extends GetxController {
  bool isPosting = false;
  late List allUsers = [];

  late List allEmails = [];
  late List allUsernames = [];
  late List allPhoneNumbers = [];
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    getAllUsers();
  }

  Future<void> getAllUsers() async {
    try {
      isLoading = true;
      const profileLink = "https://f-bazaar.com/users/users/";
      var link = Uri.parse(profileLink);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allUsers = jsonData;
        for (var i in allUsers) {
          if (!allEmails.contains(i['email'])) {
            allEmails.add(i['email']);
          }
          if (!allUsernames.contains(i['username'])) {
            allUsernames.add(i['username']);
          }
          if (!allPhoneNumbers.contains(i['phone'])) {
            allPhoneNumbers.add(i['phone']);
          }
        }

        update();
      } else {
        if (kDebugMode) {
          print(response.body);
        }
      }
    } catch (e) {
      // Get.snackbar("Sorry","something happened or please check your internet connection",snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> registerUser(
    String name,
    String uname,
    String email,
    String phoneNumber,
    String uPassword,
    String uRePassword,
  ) async {
    const registrationUrl = "https://f-bazaar.com/auth/users/";
    final myLogin = Uri.parse(registrationUrl);
    http.Response response = await http.post(myLogin, headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    }, body: {
      "name": name,
      "username": uname,
      "email": email,
      "phone": phoneNumber,
      "password": uPassword,
      "re_password": uRePassword,
      "user_type": "Stock Manager",
    });

    if (response.statusCode == 201) {
      isPosting = false;
      Get.snackbar("Success", "Your account was created successfully.",
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: primaryYellow,
          duration: const Duration(seconds: 5));
      Get.offAll(() => const LoginView());
    } else {
      Get.snackbar("Error 😢", response.body.toString(),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5));
      return;
    }
  }

  Future<void> updateUser(String uname, String email, String phoneNumber,
      String id, String token) async {
    final updateUrl = "https://f-bazaar.com/users/user/$id/update/";
    final myLogin = Uri.parse(updateUrl);

    http.Response response = await http.put(myLogin, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $token"
    }, body: {
      "username": uname,
      "email": email,
      "phone": phoneNumber,
    });

    if (response.statusCode == 200) {
      isPosting = false;
      Get.snackbar("Success", "Your account was updated successfully.",
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: defaultYellow,
          duration: const Duration(seconds: 5));
      Get.offAll(() => const HomePage());
    } else {
      Get.snackbar("Error 😢", "Something went wrong",
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5));
      return;
    }
  }
}
