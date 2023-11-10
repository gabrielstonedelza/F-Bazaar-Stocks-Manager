import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stock_manager/controller/profilecontroller.dart';
import '../../controller/storeitemscontroller.dart';
import '../../statics/appcolors.dart';
import '../../widgets/loadingui.dart';
import '../homepage.dart';

class UpdateStoreItem extends StatefulWidget {
  final id;
  final name;
  final store;
  final category;
  final size;
  final old_price;
  final new_price;
  final picture;
  final volume;
  final description;
  const UpdateStoreItem(
      {super.key,
      required this.id,
      required this.name,
      required this.store,
      required this.category,
      required this.size,
      required this.old_price,
      required this.new_price,
      required this.picture,
      required this.volume,
      required this.description});

  @override
  State<UpdateStoreItem> createState() => _UpdateStoreItemState(
      id: this.id,
      name: this.name,
      store: this.store,
      category: this.category,
      size: this.size,
      old_price: this.old_price,
      new_price: this.new_price,
      picture: this.picture,
      volume: this.volume,
      description: this.description);
}

class _UpdateStoreItemState extends State<UpdateStoreItem> {
  final id;
  final name;
  final store;
  final category;
  final size;
  final old_price;
  final new_price;
  final picture;
  final volume;
  final description;
  _UpdateStoreItemState(
      {required this.id,
      required this.name,
      required this.store,
      required this.category,
      required this.size,
      required this.old_price,
      required this.new_price,
      required this.picture,
      required this.volume,
      required this.description});
  final StoreItemsController storeItemsController = Get.find();
  late String uToken = "";
  final storage = GetStorage();
  bool isLoading = true;
  bool isUploading = false;

  final _formKey = GlobalKey<FormState>();
  List categories = [
    "Select category",
    "Water",
    "Drink",
    "Furniture",
    "Electronics",
    "Fashion",
    "Beauty & Saloon",
    "Office",
  ];
  List sizes = ["Select size", "Small", "Medium", "Large", "Extra Large"];

  bool isPosting = false;
  var _currentSelectedCategory = "Select category";
  var _currentSelectedSize = "Select size";
  late final TextEditingController itemNameController;
  late final TextEditingController itemPriceController;
  late final TextEditingController itemOldController;
  late final TextEditingController itemVolumeController;
  late final TextEditingController itemDescriptionController;

  FocusNode itemNameFocusNode = FocusNode();
  FocusNode itemPriceFocusNode = FocusNode();
  FocusNode itemVolumeFocusNode = FocusNode();
  FocusNode itemDescriptionFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    itemNameController = TextEditingController(text: name);
    itemPriceController = TextEditingController(text: new_price);
    itemOldController = TextEditingController(text: old_price);
    itemVolumeController = TextEditingController(text: volume);
    itemDescriptionController = TextEditingController(text: description);
  }

  late String currentSelectedStoreId = "";
  final ProfileController profileController = Get.find();

  void _startPosting() async {
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  Future<void> updateItem() async {
    final requestUrl = "https://f-bazaar.com/store_api/items/$id/update/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
      'name': itemNameController.text,
      'store': store,
      'category': category,
      'size': size,
      'old_price': itemOldController.text,
      'new_price': itemPriceController.text,
      // 'picture': picture,
      "volume": itemVolumeController.text.trim(),
      "description": itemDescriptionController.text.trim(),
      "item_verified": "True",
    });
    if (response.statusCode == 200) {
      Get.snackbar("Hurray 😀", "item has been updated successfully",
          colorText: defaultTextColor1,
          snackPosition: SnackPosition.TOP,
          backgroundColor: newDefault,
          duration: const Duration(seconds: 5));
      setState(() {
        isPosting = false;
      });
      Get.offAll(() => const HomePage());
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      Get.snackbar(
        "Item Error",
        "Something went wrong.",
        duration: const Duration(seconds: 5),
        colorText: defaultTextColor1,
        backgroundColor: warning,
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    itemNameController.dispose();
    itemPriceController.dispose();
    itemOldController.dispose();
    itemVolumeController.dispose();
    itemDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Add item"),
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back, color: defaultTextColor2),
            )),
        body: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: itemNameController,
                        cursorColor: primaryYellow,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle:
                                const TextStyle(color: defaultTextColor2),
                            focusColor: primaryYellow,
                            fillColor: primaryYellow,
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: primaryYellow, width: 2),
                                borderRadius: BorderRadius.circular(12)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12))),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter name";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: itemOldController,
                        cursorColor: primaryYellow,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        decoration: InputDecoration(
                            labelText: "Old Price",
                            labelStyle:
                                const TextStyle(color: defaultTextColor2),
                            focusColor: primaryYellow,
                            fillColor: primaryYellow,
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: primaryYellow, width: 2),
                                borderRadius: BorderRadius.circular(12)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12))),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter price";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: itemPriceController,
                        cursorColor: primaryYellow,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        decoration: InputDecoration(
                            labelText: "New Price",
                            labelStyle:
                                const TextStyle(color: defaultTextColor2),
                            focusColor: primaryYellow,
                            fillColor: primaryYellow,
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: primaryYellow, width: 2),
                                borderRadius: BorderRadius.circular(12)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12))),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter price";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: itemVolumeController,
                        cursorColor: primaryYellow,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        decoration: InputDecoration(
                            labelText: "Volume",
                            labelStyle:
                                const TextStyle(color: defaultTextColor2),
                            focusColor: primaryYellow,
                            fillColor: primaryYellow,
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: primaryYellow, width: 2),
                                borderRadius: BorderRadius.circular(12)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12))),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter volume";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: itemDescriptionController,
                        cursorColor: primaryYellow,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        maxLines: 3,
                        maxLength: 100,
                        decoration: InputDecoration(
                            labelStyle:
                                const TextStyle(color: defaultTextColor2),
                            labelText: "Description",
                            focusColor: primaryYellow,
                            fillColor: primaryYellow,
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: primaryYellow, width: 2),
                                borderRadius: BorderRadius.circular(12)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12))),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter description";
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    isPosting
                        ? const LoadingUi()
                        : RawMaterialButton(
                            onPressed: () {
                              _startPosting();
                              if (!_formKey.currentState!.validate()) {
                                return;
                              } else {
                                updateItem();
                              }
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 8,
                            fillColor: primaryYellow,
                            splashColor: secondaryYellow,
                            child: const Text(
                              "Update",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                          ),

                    //   show uploaded image here
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  void _onDropDownItemSelectedCategory(newValueSelected) {
    setState(() {
      _currentSelectedCategory = newValueSelected;
    });
  }

  void _onDropDownItemSelectedSize(newValueSelected) {
    setState(() {
      _currentSelectedSize = newValueSelected;
    });
  }

  InputDecoration buildInputDecoration(String text) {
    return InputDecoration(
      labelStyle: const TextStyle(color: secondaryYellow),
      labelText: text,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: secondaryYellow, width: 2),
          borderRadius: BorderRadius.circular(12)),
    );
  }
}
