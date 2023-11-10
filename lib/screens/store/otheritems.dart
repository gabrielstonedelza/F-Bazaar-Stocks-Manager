import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../controller/storeitemscontroller.dart';
import '../../statics/appcolors.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  var items;
  final storage = GetStorage();
  late String uToken = "";

  @override
  void initState() {
    if (storage.read("token") != null) {
      uToken = storage.read("token");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Other Store Items"),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back, color: defaultTextColor2),
          )),
      body: GetBuilder<StoreItemsController>(builder: (controller) {
        return ListView.builder(
            itemCount: controller.otherItems != null
                ? controller.otherItems.length
                : 0,
            itemBuilder: (context, index) {
              items = controller.otherItems[index];
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
