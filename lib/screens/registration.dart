import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pinput/pinput.dart';
import 'package:stock_manager/controller/storeitemscontroller.dart';

import '../../statics/appcolors.dart';

import '../controller/registercontroller.dart';
import '../sendsms.dart';
import '../widgets/loadingui.dart';
import 'loginview.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final RegistrationController controller = Get.find();
  final StoreItemsController storeItemsController = Get.find();
  late final TextEditingController _usernameController;
  late final TextEditingController nameController;
  late final TextEditingController storeController;
  late final TextEditingController locationController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _rePasswordController;
  late final TextEditingController _phoneNumberController;
  final _formKey = GlobalKey<FormState>();
  bool isObscured = true;
  bool isPosting = false;
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode storeFocusNode = FocusNode();
  final FocusNode locationFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _rePasswordFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();

  void _startPosting() async {
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  bool phoneNumberVerified = false;
  late int oTP = 0;
  final SendSmsController sendSms = SendSmsController();
  final formKey = GlobalKey<FormState>();
  static const maxSeconds = 60;
  int seconds = maxSeconds;
  Timer? timer;
  bool isCompleted = false;
  bool isResent = false;
  bool emailError = false;
  bool usernameError = false;
  bool phoneNumberError = false;
  bool agreedToBeSupplied = false;

  Future<void> sendOtp() async {
    final deUrl =
        "https://f-bazaar.com/users/send_otp/$oTP/${_emailController.text.trim()}/${_usernameController.text.trim()}/";
    var link = Uri.parse(deUrl);
    http.Response response = await http.post(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    });
    if (response.statusCode == 200) {
    } else {
      if (kDebugMode) {
        print(response.body);
      }
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        stopTimer(reset: false);
        setState(() {
          isCompleted = true;
        });
      }
    });
  }

  void resetTimer() {
    setState(() {
      seconds = maxSeconds;
    });
  }

  void stopTimer({bool reset = true}) {
    if (reset) {
      resetTimer();
    }
    timer?.cancel();
  }

  generate5digit() {
    var rng = Random();
    var rand = rng.nextInt(9000) + 1000;
    oTP = rand.toInt();
  }

  void showPhoneNumberInput() {
    showMaterialModalBottomSheet(
      backgroundColor: Colors.black,
      isDismissible: true,
      context: context,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Card(
          color: Colors.black,
          elevation: 12,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10), topLeft: Radius.circular(10))),
          child: SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 18.0, bottom: 18),
                  child: Center(
                      child: Text(
                          "Enter the OTP sent to your phone and email,please check your spam too.",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: defaultTextColor1))),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Center(
                    child: Form(
                      key: formKey,
                      child: Pinput(
                        defaultPinTheme: defaultPinTheme,
                        androidSmsAutofillMethod:
                            AndroidSmsAutofillMethod.smsRetrieverApi,
                        validator: (pin) {
                          if (pin?.length == 4 && pin == oTP.toString()) {
                            setState(() {
                              phoneNumberVerified = true;
                            });
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              phoneNumberVerified = false;
                            });
                            Get.snackbar(
                                "Code Error", "you entered an invalid code",
                                colorText: defaultTextColor1,
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5));
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Didn't receive code?",
                            style: TextStyle(color: defaultTextColor1)),
                        const SizedBox(
                          width: 20,
                        ),
                        TextButton(
                          onPressed: () {
                            sendOtp();
                            String num = _phoneNumberController.text
                                .trim()
                                .replaceFirst("0", '+233');
                            sendSms.sendMySms(num, "FBazaar", "Your code $oTP");
                            Get.snackbar("Check Phone and email",
                                "code was sent again,don't forget to check your spam too.",
                                backgroundColor: defaultYellow,
                                colorText: defaultTextColor1,
                                duration: const Duration(seconds: 5));
                            startTimer();
                            resetTimer();
                            setState(() {
                              isResent = true;
                              isCompleted = false;
                            });
                          },
                          child: const Text("Resend Code",
                              style: TextStyle(color: secondaryYellow)),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController();
    storeController = TextEditingController();
    locationController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _rePasswordController = TextEditingController();
    _phoneNumberController = TextEditingController();
    generate5digit();
    startTimer();
  }

  @override
  void dispose() {
    storeController.dispose();
    locationController.dispose();
    nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 18.0, bottom: 18),
                    child: Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextFormField(
                      controller: nameController,
                      focusNode: nameFocusNode,
                      decoration: InputDecoration(
                          labelText: "Full Name",
                          labelStyle: const TextStyle(color: defaultTextColor2),
                          focusColor: defaultTextColor2,
                          fillColor: defaultTextColor2,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: defaultTextColor2, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      cursorColor: defaultTextColor2,
                      style: const TextStyle(color: defaultTextColor2),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter name";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextFormField(
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,
                      decoration: InputDecoration(
                          labelText: "Username",
                          labelStyle: const TextStyle(color: defaultTextColor2),
                          focusColor: defaultTextColor2,
                          fillColor: defaultTextColor2,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: defaultTextColor2, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      cursorColor: defaultTextColor2,
                      style: const TextStyle(color: defaultTextColor2),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter username";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: const TextStyle(color: defaultTextColor2),
                          focusColor: defaultTextColor2,
                          fillColor: defaultTextColor2,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: defaultTextColor2, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      cursorColor: defaultTextColor2,
                      style: const TextStyle(color: defaultTextColor2),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter email";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextFormField(
                      controller: storeController,
                      focusNode: storeFocusNode,
                      decoration: InputDecoration(
                          labelText: "Store Name",
                          labelStyle: const TextStyle(color: defaultTextColor2),
                          focusColor: defaultTextColor2,
                          fillColor: defaultTextColor2,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: defaultTextColor2, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      cursorColor: defaultTextColor2,
                      style: const TextStyle(color: defaultTextColor2),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter store name";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextFormField(
                      controller: locationController,
                      focusNode: locationFocusNode,
                      decoration: InputDecoration(
                          labelText: "Location",
                          labelStyle: const TextStyle(color: defaultTextColor2),
                          focusColor: defaultTextColor2,
                          fillColor: defaultTextColor2,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: defaultTextColor2, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      cursorColor: defaultTextColor2,
                      style: const TextStyle(color: defaultTextColor2),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter location";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextFormField(
                      controller: _phoneNumberController,
                      focusNode: _phoneNumberFocusNode,
                      onChanged: (value) {
                        if (value.length == 10 &&
                            controller.allPhoneNumbers.contains(value)) {
                          Get.snackbar("Sorry",
                              "a user with this phone number already exists.",
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5));
                        } else if (value.length == 10 &&
                            !controller.allPhoneNumbers.contains(value)) {
                          String num = _phoneNumberController.text
                              .trim()
                              .replaceFirst("0", '+233');
                          sendSms.sendMySms(num, "FBazaar", "Your code $oTP");
                          sendOtp();
                          showPhoneNumberInput();
                        }
                      },
                      decoration: InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: const TextStyle(color: defaultTextColor2),
                          focusColor: defaultTextColor2,
                          fillColor: defaultTextColor2,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: defaultTextColor2, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      cursorColor: defaultTextColor2,
                      style: const TextStyle(color: defaultTextColor2),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter phone number";
                        }
                        if (value.length < 10) {
                          return "Enter a valid phone number";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  phoneNumberVerified
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isObscured = !isObscured;
                                        });
                                      },
                                      icon: Icon(
                                        isObscured
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: defaultTextColor2,
                                      ),
                                    ),
                                    focusColor: defaultTextColor2,
                                    fillColor: defaultTextColor2,
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: defaultTextColor2, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    hintText: "Password",
                                    hintStyle: const TextStyle(
                                        color: defaultTextColor2)),
                                cursorColor: defaultTextColor2,
                                style:
                                    const TextStyle(color: defaultTextColor2),
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.next,
                                obscureText: isObscured,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter password";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: TextFormField(
                                controller: _rePasswordController,
                                focusNode: _rePasswordFocusNode,
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isObscured = !isObscured;
                                        });
                                      },
                                      icon: Icon(
                                        isObscured
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: defaultTextColor2,
                                      ),
                                    ),
                                    focusColor: defaultTextColor2,
                                    fillColor: defaultTextColor2,
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: defaultTextColor2, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    hintText: "Retype Password",
                                    hintStyle: const TextStyle(
                                        color: defaultTextColor2)),
                                cursorColor: defaultTextColor2,
                                style:
                                    const TextStyle(color: defaultTextColor2),
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                obscureText: isObscured,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "confirm password";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  isPosting
                      ? const LoadingUi()
                      : phoneNumberVerified
                          ? RawMaterialButton(
                              onPressed: () {
                                _startPosting();
                                if (_formKey.currentState!.validate()) {
                                  if (controller.allUsernames
                                      .contains(_usernameController.text)) {
                                    Get.snackbar("Username Error",
                                        "A user with the same username already exists",
                                        colorText: defaultTextColor1,
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red);
                                    return;
                                  } else if (controller.allEmails
                                      .contains(_emailController.text)) {
                                    Get.snackbar("Email Error",
                                        "A user with the same email already exists",
                                        colorText: defaultTextColor1,
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red);
                                    return;
                                  } else if (storeItemsController.allStoresNames
                                      .contains(storeController.text)) {
                                    Get.snackbar("Store Error",
                                        "A store with the same name already exists",
                                        colorText: defaultTextColor1,
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red);
                                    return;
                                  } else {
                                    controller.registerUser(
                                        nameController.text.trim(),
                                        _usernameController.text.trim(),
                                        _emailController.text.trim(),
                                        _phoneNumberController.text.trim(),
                                        _passwordController.text.trim(),
                                        _rePasswordController.text.trim(),
                                        storeController.text.trim(),
                                        locationController.text.trim());
                                  }
                                }
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 8,
                              fillColor: newButton,
                              splashColor: primaryYellow,
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: defaultTextColor1),
                              ),
                            )
                          : Container(),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: defaultTextColor2),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: defaultTextColor1),
                        ),
                        onPressed: () {
                          Get.to(() => const LoginView());
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Center(
                      child: Text(
                          "Please note,your phone number will be verified before you can continue."))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );
}
