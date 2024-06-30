import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../Pages/ViewHoldersDataPage.dart';

class GetHolders extends StatefulWidget {
  final String email;
  final List<String> holders;

  GetHolders({required this.email, required this.holders});

  @override
  GetHoldersState createState() => GetHoldersState(UserEmail: email);
}

class GetHoldersState extends State<GetHolders> {
  final String UserEmail;
  GetHoldersState({required this.UserEmail});

  bool isloading = false;
  late String long , alt;
  final DatabaseReference _databaseReferenceflag = FirebaseDatabase.instance.reference();
  String new_state = "0";
  bool is_online = false;
  List<String> IDS = List<String>.empty(growable: true);
  String user_ids = "0";

  @override
  void initState() {
    super.initState();
    for (int i =0 ; i<widget.holders.length;i++)
    {
      user_ids = widget.holders[i];
      if(!IDS.contains(user_ids))
      {
        setState(() {
          IDS.add(user_ids);

        });
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 208, 236),
        title: Row(
          children: [
            const Text("SVIG",
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            const SizedBox(width: 5),
            Image.asset(
              "assets/images/dice-3.png",
              width: 30,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 27, 33, 82),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/dice-6.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: viewholders(widget.email),
      ),
    );
  }

  Future<void> deleteDocumentByData(BuildContext context, dynamic value) async {
    try {
      widget.holders.remove(value);
      IDS.remove(value);
      // Reference to Firestore collection
      firestore.CollectionReference collection =
          firestore.FirebaseFirestore.instance.collection('Glasses');
      // Query to find documents where the specified field matches the provided value
      firestore.QuerySnapshot query =
          await collection.where("ID", isEqualTo: value).get();
      // Check if any documents match the query
      if (query.docs.isNotEmpty) {
        // Loop over the documents and delete them
        for (firestore.QueryDocumentSnapshot doc in query.docs) {
          await doc.reference.delete();
        }
      } else {
        // Show error dialog if no documents match the query
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text(
              'Error',
              style: TextStyle(fontSize: 25),
            ),
            content: Text(
              'Could not find document with ID: $value',
              style: TextStyle(fontSize: 18),
            ),
            actions: [
              TextButton(
                child: const Text('OK', style: TextStyle(fontSize: 20)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Show error dialog if an exception occurs
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text(
            'Error',
            style: TextStyle(fontSize: 25),
          ),
          content: Text(
            'Could not Delete Due to $e',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              child: const Text('OK', style: TextStyle(fontSize: 20)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void deleteholder(BuildContext context, String ID) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    BuildContext dialogContext = context;
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Delete Option',
          style: TextStyle(fontSize: 25),
        ),
        content: const Text(
          'Are You Sure You want To Delete This Holder?',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          Row(
            children: [
              TextButton(
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 20, color: Colors.redAccent),
                  ),
                  onPressed: () {
                    deleteDocumentByData(dialogContext, ID);
                    Navigator.pop(context);
                  }),
              SizedBox(width: screenWidth * 0.15),
              TextButton(
                child: const Text('Cancel', style: TextStyle(fontSize: 20)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          )
        ],
      ),
    );
  }

  void viewmoredata(BuildContext context, String Name , String ID) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((_) => moredata(
                Name: Name,
                id: ID,
              ))));
  }


  Widget viewholders(String email) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Use a Query to search for documents where 'Owner' field is equal to the provided email
    firestore.Query query = firestore.FirebaseFirestore.instance
        .collection('Glasses')
        .where('Owner', isEqualTo: this.UserEmail);
    print("The Email IS "+UserEmail);
    return StreamBuilder<firestore.QuerySnapshot>(
      stream: query.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<firestore.QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
              child: Text("Something went wrong. Please try again later."));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          // If the connection state is waiting, show the circular progress indicator
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.yellowAccent,
            backgroundColor: Color.fromARGB(255, 27, 33, 82),
          ));
        }
        // Check if there are no documents available
        if (snapshot.data!.docs.isEmpty) {
          return Center(
              child: Card(
                  elevation: 10,
                  margin: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
                  color:
                      const Color.fromARGB(255, 245, 245, 124).withOpacity(0.9),
                  child: const Text(
                    "No data available. Add new glasses and try again!",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  )));
        }
        // If data is available, hide the circular progress indicator and display the ListView
        return ListView(
          padding: const EdgeInsets.all(10),
          children: snapshot.data!.docs.map((firestore.DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return Card(
              color: const Color.fromARGB(255, 245, 245, 124).withOpacity(0.9),
              elevation: 10,
              margin: EdgeInsets.symmetric(vertical: screenWidth * 0.05),
              child: ListTile(
                title: Text(
                  "Glasses ID: ${data['ID']}\nHolder Name: ${data['Holder']}",
                  style: const TextStyle(
                      fontSize: 20, color: Color.fromARGB(255, 27, 33, 82)),
                ),
                subtitle: Row(children: [
                  SizedBox(width: screenWidth * 0.5),
                  TextButton.icon(
                      onPressed: () => deleteholder(context, data["ID"]),
                      icon: const Icon(
                        Icons.remove_circle,
                        color: Colors.redAccent,
                        size: 25,
                      ),
                      label: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      )),
                ]),
                onTap: () => viewmoredata(context, data["Holder"] , data["ID"]),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
