import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/storeitemscontroller.dart';
import '../../statics/appcolors.dart';

class AllMyStores extends StatefulWidget {
  const AllMyStores({super.key});

  @override
  State<AllMyStores> createState() => _AllMyStoresState();
}

class _AllMyStoresState extends State<AllMyStores> {
  final StoreItemsController storeItemsController = Get.find();
  var items;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("My Stores"),
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back, color: defaultTextColor2),
            )),
        body: GetBuilder<StoreItemsController>(builder: (controller) {
          return ListView.builder(
              itemCount: controller.allMyStores != null
                  ? controller.allMyStores.length
                  : 0,
              itemBuilder: (context, index) {
                items = controller.allMyStores[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(items['name']),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("@ ${items['location']}"),
                          const SizedBox(height: 10),
                          Text(items['date_created']
                              .toString()
                              .split("T")
                              .first),
                        ],
                      ),
                    ),
                  ),
                );
              });
        }));
  }
}
