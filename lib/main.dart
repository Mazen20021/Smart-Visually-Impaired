import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapp/Pages/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mapp/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  runApp(const SVIG()); //start application
}

//class extends stateless --> for text and other stateless widgets statefull --> buttons and actions
class SVIG extends StatelessWidget {
  //constructor
  const SVIG({super.key});

  @override
  Widget build(BuildContext context) {
    //main widget
    return MaterialApp(
        //home of the app and Scaffold for making app look nicer
        home: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Back2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Card(
              margin: const EdgeInsets.all(20),
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
              child: const ColorConfigs()),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 31, 37, 68),
    ));
  }
}
