import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mapp/Pages/SignupPage.dart';
import 'package:mapp/Messages/comHelper.dart';
import '../Config/CustomButtons.dart';
import '../FireBase/UsersDataBase.dart';

bool ispressed = false;
final TextEditingController _passwordController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final _formkey = GlobalKey<FormState>();
String email = _emailController.text;
Createusers lg = Createusers();
bool _isLoading = false;
class ColorConfigs extends StatefulWidget {
  const ColorConfigs({super.key});

  @override
  State<ColorConfigs> createState() {
    return _colorconfigState();
  }
}

class _colorconfigState extends State<ColorConfigs> {
  bool cemail = false;
  bool cpass = false;
  bool correctdata = false;
  String missingemail = "Email";
  String missingpass = "Password";
  String email = "", pass = "";
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late ConnectivityResult result;

  void signupbot(BuildContext context) {
    initConnectivity();
    setState(() {
      missingemail = "Email";
      missingpass = "Password";
      Navigator.push(
          context, MaterialPageRoute(builder: ((_) => const SignUp())));
    });
  }
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _emailController.text = "";
    _passwordController.text = "";
    _isLoading = false;
    super.dispose();
  }

  @override
  void intialState() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _isLoading = false;
    super.initState();
  }
  Future<void> initConnectivity() async {
    try {
      result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      return;
    }

    if (!mounted) {
      return;
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _connectionStatus = result;
      if(result == ConnectivityResult.wifi)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Online')),
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No internet connection. Cannot Signup.')));
      }
    });
  }

  bool is_connected() {
    return _connectionStatus != ConnectivityResult.none;
  }
  void _login(BuildContext context) async {
    initConnectivity();
    String email = _emailController.text;
    String password = _passwordController.text;
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    final form = _formkey.currentState;
    if (form == null || !form.validate()) {
      setState(() {
        _isLoading = false;
      });
      alertDialog(context, "Please Enter Email");
      alertDialog(context, "Please Enter Password");
      return; // Return early if validation fails
    }
      try {
        if (email.isNotEmpty && password.isNotEmpty && is_connected()) {
          await lg.loginwithemailandpass(email, password, context);
          _emailController.text = "";
          _passwordController.text = "";
        }
      } catch (e) {
        print('Error logging in: $e');
        // Handle error here, such as displaying an error message to the user
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    email = _emailController.text;
    pass = _passwordController.text;
    return SingleChildScrollView(
        child: Form(
            key: _formkey,
            child: Column(children: [
              const SizedBox(height: 50),
              Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 120),
                      const Text(
                        "SVIG",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromARGB(255, 60, 41, 110),
                            fontSize: 40,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Image.asset(
                        "assets/images/dice-3.png",
                        width: 40,
                        color: const Color.fromARGB(255, 60, 41, 110),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Smart Visually Impaired Glasses",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromARGB(255, 60, 41, 110),
                        fontSize: 20,
                        shadows: [
                          BoxShadow(blurRadius: 6, color: Colors.black)
                        ],
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Container(
                height: screenHeight * 0.5,
                child: SingleChildScrollView(
                    child: Column(children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: _emailController,
                      obscureText: false,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Please Enter Email";
                        }
                        if (!validateEmail(val)) {
                          return "Please Enter Valid Email Format";
                        }
                        cemail = true;
                        return null;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                style: BorderStyle.solid,
                                color: Color.fromARGB(226, 114, 145, 0))),
                        prefixIcon: Icon(Icons.mail),
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: const TextStyle(fontSize: 10),
                      cursorColor: const Color.fromARGB(225, 31, 37, 68),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: _passwordController,
                      autocorrect: true,
                      obscureText: true,
                      style: const TextStyle(fontSize: 10),
                      keyboardType: TextInputType.text,
                      cursorColor: const Color.fromARGB(225, 31, 37, 68),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Please Enter Password";
                        }
                        if (val.length < 6) {
                          return "Password is less than 6 characters";
                        }
                        cpass = true;
                        return null;
                      },
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(
                                  style: BorderStyle.solid,
                                  color: Color.fromARGB(226, 114, 145, 0))),
                          prefixIcon: Icon(Icons.lock),
                          labelText: "Password",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  Column(
                    children: [
                      _isLoading
                          ? const CircularProgressIndicator(
                          color: Color.fromARGB(255, 27, 33, 82),
                          backgroundColor: Colors.red
                      )
                          :
                      ArcedSquareButtoncustom(
                        onPressed: () => _login(context),
                        Bourders: 20,
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        ButtonColors: [
                          const Color.fromARGB(255, 110, 57, 127),
                          const Color.fromARGB(255, 60, 41, 110),
                        ],
                        heights: screenHeight * 0.07,
                        widths: screenWidth * 0.6,
                        label: "Login",
                        textsize: 25,
                        textcolor: Colors.white,
                      ),
                      SizedBox(height: screenHeight * 0.08),
                      Row(
                        children: [
                          SizedBox(width: screenWidth * 0.04),
                          const Text(
                            "don't have account ?",
                            style: TextStyle(
                              color: Color.fromARGB(255, 60, 41, 110),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.08),
                          ArcedSquareButtoncustom(
                            onPressed: () => signupbot(context),
                            Bourders: 20,
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            ButtonColors: [
                              const Color.fromARGB(255, 110, 57, 127),
                              const Color.fromARGB(255, 60, 41, 110),
                            ],
                            heights: screenHeight * 0.05,
                            widths: screenWidth * 0.3,
                            label: "Signup",
                            textsize: 20,
                            textcolor: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.03),
                    ],
                  ),
                ])),
              )
            ])));
  }
}
