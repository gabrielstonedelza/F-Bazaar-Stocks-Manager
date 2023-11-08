import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'homepage.dart';
import 'loginview.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (storage.read("token") != null) {
      uToken = storage.read("token");
      setState(() {
        hasToken = true;
      });
    } else {
      setState(() {
        hasToken = false;
      });
    }
    if (hasToken) {
      Timer(
          const Duration(seconds: 3), () => Get.offAll(() => const HomePage()));
    } else {
      Timer(const Duration(seconds: 3),
          () => Get.offAll(() => const LoginView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                  image: AssetImage("assets/images/delivery_man.jpg"),
                  fit: BoxFit.contain)),
        ));
  }
}
