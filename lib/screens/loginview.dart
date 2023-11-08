import 'package:flutter/material.dart';
import 'package:stock_manager/screens/registration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../controller/logincontroller.dart';
import '../statics/appcolors.dart';
import '../widgets/loadingui.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isPosting = false;
  void _startPosting() async {
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  final LoginController controller = Get.find();
  late final TextEditingController _passwordController;

  late final TextEditingController _emailController;
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  bool isObscured = true;

  final Uri _url = Uri.parse('https://f-bazaar.com/users/password-reset/');

  Future<void> _launchInBrowser() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  void initState() {
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    controller.getAllStockManagers();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  cursorColor: defaultTextColor2,
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
                  // cursorColor: Colors.black,
                  // style: const TextStyle(color: Colors.black),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter username";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  cursorColor: defaultTextColor2,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isObscured = !isObscured;
                          });
                        },
                        icon: Icon(
                          isObscured ? Icons.visibility : Icons.visibility_off,
                          color: defaultTextColor2,
                        ),
                      ),
                      labelText: "Password",
                      labelStyle: const TextStyle(color: defaultTextColor2),
                      focusColor: defaultTextColor2,
                      fillColor: defaultTextColor2,
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: defaultTextColor2, width: 2),
                          borderRadius: BorderRadius.circular(12)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                  // cursorColor: Colors.black,
                  // style: const TextStyle(color: Colors.black),
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  obscureText: isObscured,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter password";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20),
                InkWell(
                    onTap: () async {
                      await _launchInBrowser();
                    },
                    child: const Text(
                      "Forgot Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                const SizedBox(
                  height: 25,
                ),
                const SizedBox(height: 20),
                isPosting
                    ? const LoadingUi()
                    : RawMaterialButton(
                        fillColor: newButton,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        onPressed: () {
                          _startPosting();
                          FocusScopeNode currentFocus = FocusScope.of(context);

                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          if (!_formKey.currentState!.validate()) {
                            return;
                          } else {
                            controller.loginUser(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                          }
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: defaultTextColor1,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
              child: const Text(
                "Register",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Get.to(() => const Registration());
              },
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    ));
  }
}
