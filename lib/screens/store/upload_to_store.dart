import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart' as myGet;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stock_manager/controller/profilecontroller.dart';
import '../../controller/storeitemscontroller.dart';
import '../../statics/appcolors.dart';
import '../../widgets/loadingui.dart';
import '../homepage.dart';
import 'dart:io';

class UploadItemToStore extends StatefulWidget {
  const UploadItemToStore({super.key});

  @override
  State<UploadItemToStore> createState() => _UploadItemToStoreState();
}

class _UploadItemToStoreState extends State<UploadItemToStore> {
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
    itemNameController = TextEditingController();
    itemPriceController = TextEditingController();
    itemVolumeController = TextEditingController();
    itemDescriptionController = TextEditingController();
  }

  File? image;
  Future getFromGallery(String amountReceived) async {
    try {
      final myImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (myImage == null) return;
      final imageTemporary = File(myImage.path);
      setState(() {
        image = imageTemporary;
      });
      if (image != null) {
        // uploadAmountReceivedWithReceipt(image!, amountReceived);
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Error");
      }
    }
  }

  final picker = ImagePicker();
  File? imageFile;
  void showSource() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Card(
        elevation: 12,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10))),
        child: SizedBox(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                  child: Text("Select Source",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _imgFromGallery();
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/gallery.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Gallery",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _imgFromCamera();
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/camera.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Camera",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _imgFromCamera() async {
    await picker
        .pickImage(source: ImageSource.camera, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path));
      }
    });
  }

  _imgFromGallery() async {
    await picker
        .pickImage(source: ImageSource.gallery, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path));
      }
    });
  }

  _cropImage(File imgFile) async {
    final croppedFile = await ImageCropper().cropImage(
        sourcePath: imgFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: "Image Cropper",
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: "Image Cropper",
          )
        ]);
    if (croppedFile != null) {
      imageCache.clear();
      setState(() {
        imageFile = File(croppedFile.path);
        // uploadAmountReceivedWithReceipt(imageFile!);
      });
      // reload();
    }
  }

  late String currentSelectedStoreId = "";
  final ProfileController profileController = Get.find();

  var dio = Dio();
  bool isUpLoading = false;
  void _startPosting() async {
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  void _uploadAndSaveItem(File file) async {
    try {
      isUpLoading = true;
      String fileName = file.path.split('/').last;
      var formData1 = FormData.fromMap({
        'name': itemNameController.text,
        'store': profileController.storeName,
        'category': _currentSelectedCategory,
        'size': _currentSelectedSize,
        'new_price': itemPriceController.text,
        'picture': await MultipartFile.fromFile(file.path, filename: fileName),
        "volume": itemVolumeController.text.trim(),
        "description": itemDescriptionController.text.trim(),
      });
      var response = await dio.post(
        'https://f-bazaar.com/store_api/add_item/',
        data: formData1,
        options: Options(headers: {
          "Authorization": "Token $uToken",
          "HttpHeaders.acceptHeader": "accept: application/json",
        }, contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode != 201) {
        Get.snackbar("Sorry", "something went wrong. Please try again",
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red);
      } else {
        Get.snackbar("Hurray 😀",
            "Your item was added successfully.Note:It will be verified before making its way to the store.",
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: primaryYellow,
            duration: const Duration(seconds: 5));
        setState(() {
          isPosting = false;
        });
        Get.offAll(() => const HomePage());
      }
    } on DioException catch (e) {
      Get.snackbar("Sorry", e.toString(),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: primaryYellow);
    } finally {
      isUpLoading = false;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    itemNameController.dispose();
    itemPriceController.dispose();
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
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey, width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: DropdownButton(
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: categories.map((dropDownStringItem) {
                              return DropdownMenuItem(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            onChanged: (newValueSelected) {
                              _onDropDownItemSelectedCategory(newValueSelected);
                            },
                            value: _currentSelectedCategory,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey, width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: DropdownButton(
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: sizes.map((dropDownStringItem) {
                              return DropdownMenuItem(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            onChanged: (newValueSelected) {
                              _onDropDownItemSelectedSize(newValueSelected);
                            },
                            value: _currentSelectedSize,
                          ),
                        ),
                      ),
                    ),
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
                        controller: itemPriceController,
                        cursorColor: primaryYellow,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        decoration: InputDecoration(
                            labelText: "Price",
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
                    GestureDetector(
                      onTap: () async {
                        itemNameController.text == ""
                            ? Get.snackbar("Name Error", "enter item name",
                                colorText: defaultTextColor1,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 5),
                                backgroundColor: warning)
                            : showSource();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/upload.png",
                              width: 40, height: 40),
                          const Text("Upload item pic",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20))
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    imageFile != null
                        ? SizedBox(
                            width: 400,
                            height: 160,
                            child: Image.file(imageFile!),
                          )
                        : Container(),
                    isPosting
                        ? const LoadingUi()
                        : imageFile != null
                            ? RawMaterialButton(
                                onPressed: () {
                                  _startPosting();
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  } else {
                                    _uploadAndSaveItem(imageFile!);
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 8,
                                fillColor: primaryYellow,
                                splashColor: secondaryYellow,
                                child: const Text(
                                  "Upload",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white),
                                ),
                              )
                            : Container(),
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
