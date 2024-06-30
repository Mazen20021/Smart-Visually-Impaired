import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Pages/MainPage.dart';

class Createusers {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  void createuserwithemailandpass(
      String emailAddress, String password, BuildContext context , String UserName) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      User? user = credential.user;
      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).set({
          'Email': emailAddress,
          'Password': password,
          'Name': UserName,
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print("password is weak");
      } else if (e.code == 'email-already-in-use') {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text(
              'Error',
              style: TextStyle(fontSize: 20),
            ),
            content: const Text(
              'This User Exists Already!',
              style: TextStyle(fontSize: 20),
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text(
            'Error',
            style: TextStyle(fontSize: 20),
          ),
          content: Text(
            'Error 404 Dueto ${e}',
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }
 Future<void> loginwithemailandpass(String Email,String Pass,BuildContext context)
  async{
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: Email,
          password: Pass
      );
      Navigator.push(
          context, MaterialPageRoute(builder: ((_) =>  Addholder(UserEmail: Email,pass: Pass))));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text(
              'Email Not Found',
              style: TextStyle(fontSize: 20),
            ),
            content: Text(
              ' This Email Is Not Found Please SignUp Or Try Again With Vaild Email',
              style: TextStyle(fontSize: 20),
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else if (e.code == 'wrong-password') {
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              AlertDialog(
                title: const Text(
                  'Password Not Correct',
                  style: TextStyle(fontSize: 20),
                ),
                content: Text(
                  ' This Password Is Not Found Please Try Again With Vaild Password',
                  style: TextStyle(fontSize: 20),
                ),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
        );
      }
      else{
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                AlertDialog(
                  title: const Text(
                    'Error',
                    style: TextStyle(fontSize: 20),
                  ),
                  content: Text(
                    'This User Is Not Found You may Signup or Try again later!',
                    style: TextStyle(fontSize: 20),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                )
        );
      }
    }
  }
}
