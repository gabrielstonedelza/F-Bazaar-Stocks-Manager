import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_manager/controller/storeitemscontroller.dart';
import 'package:stock_manager/screens/store/updatestore.dart';

import '../../statics/appcolors.dart';

class MyStoreItems extends StatefulWidget {
  const MyStoreItems({super.key});

  @override
  State<MyStoreItems> createState() => _MyStoreItemsState();
}

class _MyStoreItemsState extends State<MyStoreItems> {
  var items;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Your Store Items"),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back, color: defaultTextColor2),
          )),
      body: GetBuilder<StoreItemsController>(builder: (controller) {
        return ListView.builder(
            itemCount: controller.allMyStoreItems != null
                ? controller.allMyStoreItems.length
                : 0,
            itemBuilder: (context, index) {
              items = controller.allMyStoreItems[index];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: items['get_item_pic'] == ""
                                ? Image.asset("assets/images/fbazaar.png",
                                    width: 100, height: 100)
                                : Image.network(items['get_item_pic'],
                                    width: 100, height: 100),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(items['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                const SizedBox(height: 10),
                                Text(items['size'],
                                    style: const TextStyle(
                                        color: muted,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10)),
                                const SizedBox(height: 10),
                                Text("${items['volume']} in a carton",
                                    style: const TextStyle(
                                        color: muted,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10)),
                                const SizedBox(height: 10),
                                Text("₵ ${items['new_price']}",
                                    style: const TextStyle(
                                        color: primaryYellow,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                const SizedBox(height: 10),
                                !items["item_verified"] &&
                                        !items["item_rejected"]
                                    ? const Text("Item verification pending",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))
                                    : items['item_verified']
                                        ? Image.asset("assets/images/check.png",
                                            width: 30, height: 30)
                                        : Image.asset(
                                            "assets/images/reject.png",
                                            width: 30,
                                            height: 30),
                                const Divider(),
                                items['item_verified']
                                    ? TextButton(
                                        onPressed: () {
                                          Get.to(() => UpdateStoreItem(
                                                id: controller
                                                        .allMyStoreItems[index]
                                                    ['id'],
                                                name: controller
                                                        .allMyStoreItems[index]
                                                    ['name'],
                                                store: controller
                                                        .allMyStoreItems[index]
                                                    ['store'],
                                                category: controller
                                                        .allMyStoreItems[index]
                                                    ['category'],
                                                size: controller
                                                        .allMyStoreItems[index]
                                                    ['size'],
                                                old_price: controller
                                                        .allMyStoreItems[index]
                                                    ['old_price'],
                                                new_price: controller
                                                        .allMyStoreItems[index]
                                                    ['new_price'],
                                                picture: controller
                                                        .allMyStoreItems[index]
                                                    ['picture'],
                                                volume: controller
                                                    .allMyStoreItems[index]
                                                        ['volume']
                                                    .toString(),
                                                description: controller
                                                        .allMyStoreItems[index]
                                                    ['description'],
                                              ));
                                        },
                                        child: const Text("Update Item",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      )
                    ],
                  ),
                ),
              );
            });
      }),
    );
  }
}
