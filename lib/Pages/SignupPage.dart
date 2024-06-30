import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mapp/Messages/comHelper.dart';
import 'package:mapp/FireBase/UsersDataBase.dart';
import '../Config/CustomButtons.dart';
import '../main.dart';
import 'MainPage.dart';

List<String> idused = List<String>.empty(growable: true);
final TextEditingController _passwordController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _username = TextEditingController();
final TextEditingController _confpass = TextEditingController();
final _formkey = GlobalKey<FormState>();
String user = "", email = "", pass = "", confpass = "";
bool found = false;
bool _isLoading = false;
Createusers lg = Createusers();

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() {
    return _signup();
  }
}

class _signup extends State<SignUp> {
  Createusers CU = Createusers();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late ConnectivityResult result;

  @override
  void dispose() {
    _username.text = "";
    _confpass.text = "";
    _emailController.text = "";
    _passwordController.text = "";
    _connectivitySubscription.cancel();
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

  Future<void> _Signup(BuildContext context) async {
    initConnectivity();
    String name = _username.text;
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
      alertDialog(context, "Please Enter UserName");
      alertDialog(context, "Please Enter Email");
      alertDialog(context, "Please Enter UserPassword");
      alertDialog(context, "Please Enter Confirmation Password");
      return;
    }
        try{
        if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty && is_connected()) {
          _formkey.currentState!.save();
            CU.createuserwithemailandpass(email, password, context , _username.text);
          Navigator.push(
              context, MaterialPageRoute(builder: ((_) =>  Addholder(UserEmail: email,pass: _passwordController.text))));
            _username.text = "";
            _emailController.text = "";
           _passwordController.text = "";
           _confpass.text = "";
          }
        }catch(e) {print('Error Signing in: $e');}
        finally{setState(() {_isLoading = false;});}
      }
void _Login(BuildContext context)
{
  initConnectivity();
  Navigator.push(
      context, MaterialPageRoute(builder: ((_) =>  const SVIG())));
}
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    user = _username.text;
    email = _emailController.text;
    pass = _passwordController.text;
    confpass = _confpass.text;
    return Scaffold(
      backgroundColor: const Color.fromARGB(206, 31, 37, 68),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Back3.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Center(
                child: Container(
                  width: screenWidth * 0.98,
                  height: screenHeight * 0.81,
                  child: Card(
                    margin: const EdgeInsets.all(20),
                    color: const Color.fromARGB(255, 255, 255, 255)
                        .withOpacity(0.9),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Image.asset(
                              "assets/images/dice-4.png",
                              width: screenWidth * 0.35,
                              color: Color.fromARGB(255, 60, 41, 110),
                            ),
                            //medium Part
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.75,
                                  child: TextFormField(
                                    controller: _username,
                                    obscureText: false,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Please Enter UserName";
                                      }
                                      return null;
                                    },
                                    onSaved: (val) => _username.text = val!,
                                    style: const TextStyle(fontSize: 10),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                        borderSide: BorderSide(
                                            style: BorderStyle.solid,
                                            color: Colors.transparent),
                                      ),
                                      prefixIcon: Icon(Icons.person),
                                      labelText: 'UserName',
                                      labelStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: screenWidth * 0.75,
                                  child: TextFormField(
                                    controller: _emailController,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Please Enter Email";
                                      }
                                      if (!validateEmail(val)) {
                                        return "Please Enter Valid Email Format";
                                      }
                                      return null;
                                    },
                                    onSaved: (val) =>
                                        _emailController.text = val!,
                                    autocorrect: true,
                                    obscureText: false,
                                    style: const TextStyle(fontSize: 10),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                        borderSide: BorderSide(
                                            style: BorderStyle.solid,
                                            color: Color.fromARGB(
                                                255, 144, 145, 72)),
                                      ),
                                      prefixIcon: Icon(Icons.email),
                                      labelText: 'Email',
                                      labelStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: screenWidth * 0.75,
                                  child: TextFormField(
                                    controller: _passwordController,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Please Enter Password";
                                      }
                                      if (val.length < 6) {
                                        return "Error Your Password Is Too Weak";
                                      }
                                      return null;
                                    },
                                    onSaved: (val) =>
                                        _passwordController.text = val!,
                                    autocorrect: true,
                                    obscureText: true,
                                    style: const TextStyle(fontSize: 10),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                      ),
                                      prefixIcon: Icon(Icons.lock),
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: screenWidth * 0.75,
                                  child: TextFormField(
                                    controller: _confpass,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Please Enter ConfirmPassword";
                                      }
                                      if (_confpass.text !=
                                          _passwordController.text) {
                                        return "Password Doesn't Match";
                                      }
                                      return null;
                                    },
                                    onSaved: (val) =>
                                        _passwordController.text = val!,
                                    autocorrect: true,
                                    obscureText: true,
                                    style: const TextStyle(fontSize: 10),
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12)),
                                            borderSide: BorderSide(
                                                style: BorderStyle.solid,
                                                color: Color.fromARGB(
                                                    255, 31, 37, 68))),
                                        prefixIcon: Icon(Icons.lock),
                                        labelText: 'ConfirmPassword',
                                        labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                ),
                                const SizedBox(height: 35),
                                _isLoading
                                    ? const CircularProgressIndicator(
                                    color: Color.fromARGB(255, 27, 33, 82),
                                    backgroundColor: Colors.red
                                ):ArcedSquareButtoncustom(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  textcolor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  heights: screenHeight * 0.08,
                                  widths: screenWidth * 0.6,
                                  textsize: 25,
                                  label: "Signup",
                                  Bourders: 25,
                                  onPressed: () => _Signup(context),
                                  ButtonColors: [
                                    const Color.fromARGB(255, 110, 57, 127),
                                    const Color.fromARGB(255, 60, 41, 110),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                ArcedSquareButtoncustom(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  textcolor:
                                  const Color.fromARGB(255, 255, 255, 255),
                                  heights: screenHeight * 0.05,
                                  widths: screenWidth * 0.4,
                                  textsize: 10,
                                  label: "Already Has An Account ?",
                                  Bourders: 25,
                                  onPressed: () => _Login(context),
                                  ButtonColors: [
                                    const Color.fromARGB(255, 110, 57, 127),
                                    const Color.fromARGB(255, 60, 41, 110),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
