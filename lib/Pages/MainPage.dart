import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:mapp/Messages/comHelper.dart';
import '../Config/CustomButtons.dart';
import '../FireBase/HoldersDataBase.dart';
import '../FireBase/ViewHolders.dart';
import '../firebase_options.dart';
import '../main.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;


class Addholder extends StatefulWidget {
  final String UserEmail , pass;
  const Addholder({super.key , required this.UserEmail , required this.pass});

  @override
  State<Addholder> createState() {
    return add(emails: UserEmail , pass:pass);
  }
}

class add extends State<Addholder> with TickerProviderStateMixin {
  final String emails , pass;
  add({required this.emails , required this.pass});
  List<Map<String, dynamic>> holdersList = [];
  List<String> idused = ["0"];
  late final TabController _tabController;
  final TextEditingController _holdername = TextEditingController();
  final TextEditingController _holderid = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formkey = GlobalKey<FormState>();
  String holderidgot = "", holdernamegot = "";
  bool GID = false;
  bool HName = false;
  bool correctdata = false;
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }
  Future<void> deleteDocumentByData(BuildContext context, dynamic value) async {
    try {
      // Reference to Firestore collection
      firestore.CollectionReference collection =
      firestore.FirebaseFirestore.instance.collection('Users');
      // Query to find documents where the specified field matches the provided value
      firestore.QuerySnapshot query =
      await collection.where("Email", isEqualTo: value).get();
      // Check if any documents match the query
      if (query.docs.isNotEmpty) {
        // Loop over the documents and delete them
        for (firestore.QueryDocumentSnapshot doc in query.docs) {
          await doc.reference.delete();
        }
      } else {
        // Show error dialog if no documents match the query
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: Could not find this document')));
      }
    } catch (e) {
      // Show error dialog if an exception occurs
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
Future<void> inizalizefirebase()
async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings =
  const Settings(persistenceEnabled: true);
}
Future<void> delete(BuildContext context)
async {
  deleteDocumentByData(context,emails);
  try {
    User? user = _auth.currentUser;
    await _firestore.collection('Users').doc(user!.uid).delete();
    await user!.delete();
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account deleted successfully')));

} catch (e) {
print(e);
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete account')));
}
}
Future<void> _firebase()
async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emails,
        password: pass
    );
  } on FirebaseAuthException catch (e){}
}
void check()
{
  final screenWidth = MediaQuery.of(context).size.width;
  BuildContext dialogContext = context;
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text(
        'Deleting Option',
        style: TextStyle(fontSize: 25),
      ),
      content: const Text(
        'Are You Sure You want To Delete Your Account?',
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
                onPressed: () async {
                  _firebase();
                  delete(dialogContext);
                  Navigator.pop(context);
                  await FirebaseAuth.instance.signOut();
                  await Firebase.initializeApp(); // Reinitialize Firebase if needed
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SVIG()), // Restart the app
                        (Route<dynamic> route) => false,
                  );
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
  Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to logout?' , style: TextStyle(fontSize: 20)),
          actions: <Widget>[
            TextButton(
              child: Text('No',style: TextStyle(fontSize: 20)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Yes' , style: TextStyle(color:Colors.redAccent,fontSize: 20),),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<bool> _onWillPop() async {

    return false; // Prevents the app from popping the route.
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void viewholders(BuildContext context, List<String> IDs) {
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((_) => GetHolders(
                    email: emails,
                    holders: IDs,
                  ))));
    });
  }

  bool botPressed = false;
  bool _check_if_found(String id) {
    if (botPressed) {
      if (idused.contains(id)) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text(
              'Error!',
              style: TextStyle(fontSize: 30),
            ),
            content: const Text(
              'Failed to add this Holder. The entered Holder already exists.',
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
        return true;
      }
    }
    return false;
  }

  Future _addholder(BuildContext context, String currentID) async {
    WidgetsFlutterBinding.ensureInitialized();
    final form = _formkey.currentState;
    String HolderID = _holderid.text;
    String HolderName = _holdername.text;
    if (_isloading) {
      return;
    }
    setState(() {
      _isloading = true;
    });
    if (form == null || !form.validate()) {
      setState(() {
        _isloading = false;
      });
      alertDialog(context, "Please Enter GlassesID");
      alertDialog(context, "Please Enter HolderName");
    } else {
      if (HolderName.isNotEmpty && HolderID.isNotEmpty) {
        _formkey.currentState!.save();
        try {
          if (!_check_if_found(currentID)) {
            final firestore = FirebaseFirestore.instance;
            DocumentSnapshot snapshot =
            await firestore.collection('ID').doc(currentID).get();
            if (!snapshot.exists) {
              if (idused.contains(currentID)) {
                idused.remove(currentID);
              } else {
                idused.add(currentID);
              }
              Holders hd = Holders(
                  ID: HolderID, Name: HolderName, State: "Offline", Owner: emails);
              await hd.addUser(context);
            } else {
              if (!idused.contains(currentID)) {
                idused.add(currentID);
              }
            }
          }
        }
        catch (e) {} finally {
          setState(() {
            _isloading = false;
          });
        }
      }
    }
  }
  void _logout(BuildContext context) async {
    bool shouldLogout = await showLogoutConfirmationDialog(context);
    if (shouldLogout) {
      await FirebaseAuth.instance.signOut();
      await Firebase.initializeApp(); // Reinitialize Firebase if needed
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SVIG()), // Restart the app
            (Route<dynamic> route) => false,
      );
    }
  }

      @override
      Widget build(BuildContext context) {
        final screenWidth = MediaQuery
            .of(context)
            .size
            .width;
        final screenHeight = MediaQuery
            .of(context)
            .size
            .height;
       return WillPopScope(
            onWillPop: _onWillPop,child:  MaterialApp(home: Scaffold(
          appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 255, 208, 236),
              title:
              Row(children: [
                  TextButton.icon(
                  onPressed: () => _logout(context),
         label: const Text(''),
         icon: const Icon(Icons.login_rounded, size: 50, color: Color.fromARGB(255, 31, 37, 68)),
       ),
                SizedBox(width: screenWidth*0.08),
                const Text("SVIG",
                    style: TextStyle(color: Color.fromARGB(255, 31, 37, 68))),
                const SizedBox(width: 5),
                Image.asset(
                  "assets/images/dice-3.png",
                  width: screenWidth * 0.1,
                  color: const Color.fromARGB(255, 31, 37, 68),
                ),
                SizedBox(width: screenWidth * 0.13),
                TextButton.icon(
                  onPressed: () =>  check(),
                  label: const Text(''),
                  icon:  Icon(Icons.cancel, size: screenWidth * 0.1, color: Colors.redAccent),
                ),
              ])),
          backgroundColor: const Color.fromARGB(240, 31, 37, 68),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/dice-6.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Form(
              key: _formkey,
                child: Container(
                    height: screenHeight,
                    width: screenWidth,
                    child: Column(children: [
                      Card(
                          color: const Color.fromARGB(255, 255, 208, 236)
                              .withOpacity(0.9),
                          margin: EdgeInsetsDirectional.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.08),
                          child: Center(
                              child: Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.05),
                                  Row(children: [
                                    SizedBox(width: screenWidth * 0.32),
                                    Icon(
                                      Icons.supervised_user_circle_rounded,
                                      size: screenWidth * 0.25,
                                      color: Color.fromARGB(255, 41, 50, 123),
                                      shadows: [
                                        BoxShadow(
                                            blurRadius: 5, color: Colors.black)
                                      ],
                                    ),
                                  ]),
                                  SizedBox(height: screenHeight * 0.09),
                                  SizedBox(
                                    width: screenWidth * 0.75,
                                    child: TextFormField(
                                      cursorColor:
                                      const Color.fromARGB(255, 31, 37, 68),
                                      controller: _holderid,
                                      obscureText: false,
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return "Please Enter GlassesID";
                                        }
                                        if (val.length < 14) {
                                          int num = 14 - val.length;
                                          if (num == 1) {
                                            return "Incorrect Glasses ID [$num] number is Left";
                                          } else {
                                            return "Incorrect Glasses ID [$num] numbers are Left";
                                          }
                                        }
                                        GID = true;
                                        return null;
                                      },
                                      maxLength: 14,
                                      onSaved: (val) => _holderid.text = val!,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Color.fromARGB(
                                              255, 31, 37, 68)),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                          borderSide: BorderSide(
                                            style: BorderStyle.solid,
                                            color: Color.fromARGB(
                                                255, 31, 37, 68),
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                            Icons.fingerprint_outlined),
                                        labelText: 'GlassesID',
                                        labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.05),
                                  SizedBox(
                                    width: screenWidth * 0.75,
                                    child: TextFormField(
                                      cursorColor:
                                      const Color.fromARGB(255, 31, 37, 68),
                                      controller: _holdername,
                                      obscureText: false,
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return "Please Enter Holder's Name";
                                        }
                                        HName = true;
                                        return null;
                                      },
                                      onSaved: (val) => _holdername.text = val!,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Color.fromARGB(
                                              255, 31, 37, 68)),
                                      keyboardType: TextInputType.name,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                          borderSide: BorderSide(
                                            style: BorderStyle.solid,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                            Icons.supervised_user_circle),
                                        labelText: 'HolderName',
                                        labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.09),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.08,
                                      ),_isloading
                                          ? const CircularProgressIndicator(
                                        backgroundColor: Colors.redAccent,
                                        color: Colors.blueAccent,
                                      )
                                          :
                                      ArcedSquareButtoncustomICON(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        ButtonColors: const [
                                          Color.fromARGB(255, 71, 38, 157),
                                          Color.fromARGB(255, 255, 142, 202)
                                        ],
                                        // Icon Size
                                        textsize: 20,
                                        // Text Size
                                        textcolor:
                                        const Color.fromARGB(
                                            255, 253, 222, 85),
                                        //Text Color
                                        Bourders: 25,
                                        // Borders
                                        widths: 100,
                                        heights: 100,
                                        // Width / Height
                                        label: "ADD",
                                        onPressed: () =>
                                            _addholder(context, _holderid.text),
                                        ICS: Icon(Icons.add_circle_rounded, size: 40 , color:  Color.fromARGB(255, 253, 222, 85), shadows: [Shadow(color: Colors.black , offset:Offset(-4, 2))],),
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.25,
                                      ),

                                      ArcedSquareButtoncustomICON(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        ButtonColors: const [
                                          Color.fromARGB(255, 71, 38, 157),
                                          Color.fromARGB(255, 223, 37, 166)
                                        ],
                                        textsize: 20,
                                        textcolor:
                                        const Color.fromARGB(
                                            255, 233, 225, 201),
                                        Bourders: 25,
                                        widths: 100,
                                        heights: 100,
                                        label: "View",
                                        onPressed: () =>
                                            viewholders(context, idused),
                                        ICS: Icon(Icons.playlist_add_check_circle_rounded, size: 40 , color:  Color.fromARGB(255, 233, 225, 201), shadows: [Shadow(color: Colors.black , offset:Offset(-4, 2))],),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.05,
                                  ),
                                ],
                              )))
                    ])),
              ),
            ),
          ),
        )));
      }
    }
