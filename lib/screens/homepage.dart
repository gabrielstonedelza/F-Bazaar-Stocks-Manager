import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stock_manager/screens/store/mystoreitems.dart';
import 'package:stock_manager/screens/store/mystores.dart';
import 'package:stock_manager/screens/store/otheritems.dart';
import 'package:stock_manager/screens/store/upload_to_store.dart';
import 'package:stock_manager/statics/appcolors.dart';

import '../controller/localnotification_controller.dart';
import '../controller/logincontroller.dart';
import '../controller/notificationcontroller.dart';
import '../controller/profilecontroller.dart';
import '../controller/storeitemscontroller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LoginController loginController = Get.find();
  final StoreItemsController storeItemsController = Get.find();
  final ProfileController profileController = Get.find();
  final NotificationController notificationController = Get.find();
  final storage = GetStorage();
  late String uToken = "";
  late Timer _timer;

  @override
  void initState() {
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    scheduleTimers();
    super.initState();
  }

  void scheduleTimers() {
    storeItemsController.getAllStores(uToken);
    storeItemsController.getAllOtherStoreItems(uToken);
    storeItemsController.getAllMyStoreItems(uToken);
    profileController.getMyProfile(uToken);

    notificationController.getAllTriggeredNotifications(uToken);
    notificationController.getAllUnReadNotifications(uToken);
    notificationController.getAllNotifications(uToken);
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      storeItemsController.getAllStores(uToken);
      storeItemsController.getAllOtherStoreItems(uToken);
      storeItemsController.getAllMyStoreItems(uToken);
      profileController.getMyProfile(uToken);
      notificationController.getAllTriggeredNotifications(uToken);
      notificationController.getAllUnReadNotifications(uToken);
      notificationController.getAllNotifications(uToken);
      for (var i in notificationController.triggered) {
        LocalNotificationController().showNotifications(
          title: i['notification_title'],
          body: i['notification_message'],
        );
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      for (var e in notificationController.triggered) {
        notificationController.unTriggerNotifications(e["id"], uToken);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              loginController.logoutUser(uToken);
            },
            icon: const Icon(Icons.login_outlined, color: defaultTextColor2),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => const UploadItemToStore());
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: SizedBox(
                      height: 150,
                      width: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/cloud-computing.png",
                                width: 50, height: 50),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Upload to",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const Text("Store",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  Get.to(() => const MyStoreItems());
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: SizedBox(
                      height: 150,
                      width: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/store.png",
                                width: 50, height: 50),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Your Store",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const Text("Items",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => const Products());
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: SizedBox(
                      height: 150,
                      width: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/store.png",
                                width: 50, height: 50),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Other Store",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const Text("Items",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                  height: 150,
                  width: 150,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image.asset("assets/images/store.png",
                        //     width: 50, height: 50),
                        // const Padding(
                        //   padding: EdgeInsets.all(8.0),
                        //   child: Text("Your",
                        //       style:
                        //       TextStyle(fontWeight: FontWeight.bold)),
                        // ),
                        // const Text("Stores",
                        //     style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
