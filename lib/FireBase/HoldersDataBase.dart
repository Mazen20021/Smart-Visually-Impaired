import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Holders {
  final String ID;
  final String Name;
  final String State;
  final String Owner;

  Holders({
    required this.ID,
    required this.Name,
    required this.State,
    required this.Owner,
  });

  Future<void> addUser(BuildContext context) async {
    try {
      // Access the Firestore collection reference
      CollectionReference glasses =
      FirebaseFirestore.instance.collection('Glasses');

      // Add a new document to the collection
      await glasses.add({
        'ID': ID,
        'Holder': Name,
        'Owner': Owner,
        'Statues': State,
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text(
            'Success',
            style: TextStyle(fontSize: 20),
          ),
          content: const Text(
            'Holder Added!',
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
    } catch (error) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text(
            'Error',
            style: TextStyle(fontSize: 20),
          ),
          content: const Text(
            'Failed to add holder. Please try again later.',
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
      print('Error adding holder: $error');
    }
  }
}
