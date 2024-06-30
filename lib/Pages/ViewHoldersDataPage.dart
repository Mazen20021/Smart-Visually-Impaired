import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mapp/Pages/MapPage.dart';
import '../Config/Buttons.dart';
import 'package:mapp/Pages/StreamPage.dart';
import 'dart:convert';
import 'dart:typed_data';

class moredata extends StatefulWidget {
  final String Name;
  final String id;

  const moredata({required this.Name, required this.id, super.key});

  @override
  _moredata createState() => _moredata(Name: Name, UserID: id);
}

class _moredata extends State<moredata> {
  final String Name;
  late final String Location;
  late final String Pulse;
  late final String Speed;
  final String UserID;
  final DatabaseReference _databaseReferencePulse =
      FirebaseDatabase.instance.reference();
  final DatabaseReference _databaseReferenceSpeed =
      FirebaseDatabase.instance.reference();
  final DatabaseReference _databaseReferenceLocation =
      FirebaseDatabase.instance.reference();
  final DatabaseReference _databaseReferenceflag =
      FirebaseDatabase.instance.reference();
  String new_pulse = "0";
  String new_speed = "0";
  String new_loc_long = "0";
  String new_loc_alt = "0";
  String new_state = "0";
  bool is_online = false;

  _moredata({
    required this.Name,
    required this.UserID,
  });

  Future<List<String>> fetchFrames() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('frames/webcam');
    DatabaseEvent event = await ref.once();
    List<String> frames = [];
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> values = event.snapshot.value as Map;
      values.forEach((key, value) {
        frames.add(value as String);
      });
    }
    return frames;
  }

  Uint8List decodeBase64Image(String base64String) {
    return base64Decode(base64String);
  }

  void go_to_stream() {
    if (is_online) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((_) => VideoPlayerScreen(id: UserID, name: Name))));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This Glasses Is Offline')),
      );
    }
  }

  @override
  void initState() {
    print("View Holders Closed");
    super.initState();
    _setupListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setupListeners() {
    _databaseReferenceflag.child(UserID).onValue.listen((event) {
      final dataPulse = event.snapshot.child("Status").value;
      setState(() {
        new_state = dataPulse.toString();
      });
      if (new_state == "Online") {
        is_online = true;
      } else {
        is_online = false;
      }
      if (is_online) {
        try {
          _databaseReferencePulse
              .child(UserID)
              .child('heart_rate')
              .onValue
              .listen((event) {
            final dataPulse = event.snapshot.value;
            setState(() {
              new_pulse = dataPulse.toString();
            });
            if (double.parse(new_pulse) < 50) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Warning The Pulse Is Less Than 50 PPM')),
              );
            }
          });

          _databaseReferenceSpeed
              .child(UserID)
              .child('acceleration')
              .onValue
              .listen((event) {
            final dataSpeed = event.snapshot.value;
            setState(() {
              new_speed = dataSpeed.toString();
            });
          });
          _databaseReferenceLocation
              .child(UserID)
              .child('location')
              .onValue
              .listen((event) {
            double latitude =
                double.parse(event.snapshot.child('0').value.toString());
            double longitude =
                double.parse(event.snapshot.child('1').value.toString());
            //String convertedLat = convertToDMS(latitude, "latitude");
            //String convertedLong = convertToDMS(longitude, "longitude");
            setState(() {
              new_loc_long = '$longitude';
              new_loc_alt = '$latitude';
            });
          });
        } catch (e) {
          print('Error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Due to: $e')),
          );
        }
      } else {
        _databaseReferenceLocation
            .child(UserID)
            .child('acceleration')
            .onValue
            .listen((event) {
          setState(() {
            new_speed = "0";
          });
        });
        _databaseReferenceLocation
            .child(UserID)
            .child('heart_rate')
            .onValue
            .listen((event) {
          setState(() {
            new_pulse = "0";
          });
        });
        _databaseReferenceLocation
            .child(UserID)
            .child('location')
            .onValue
            .listen((event) {
          setState(() {
            new_loc_long = "Offline";
            new_loc_alt = "";
          });
        });
      }
    });
  }

  String convertToDMS(double coordinate, String type) {
    String direction = coordinate >= 0
        ? (type == 'latitude' ? 'N' : 'E')
        : (type == 'latitude' ? 'S' : 'W');
    double absCoordinate = coordinate.abs();
    int degrees = absCoordinate.floor();
    double minutesDouble = (absCoordinate - degrees) * 60;
    int minutes = minutesDouble.floor();
    double secondsDouble = (minutesDouble - minutes) * 60;
    double seconds = double.parse(secondsDouble.toStringAsFixed(1));
    return '$degrees°$minutes\'$seconds"$direction';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 208, 236),
          title: Row(
            children: [
              const Text("SVIG",
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
              SizedBox(width: screenWidth * 0.01),
              Image.asset(
                "assets/images/dice-3.png",
                width: 30,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 27, 33, 82),
        body: SingleChildScrollView(
            child: Container(
                width: screenWidth,
                height: screenHeight * 0.9,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/dice-6.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                  color:
                      const Color.fromARGB(255, 245, 245, 124).withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (is_online)
                          _buildItem_withcolor(
                              Icons.account_circle_rounded,
                              "",
                              Name,
                              Colors.black,
                              const Shadow(
                                  color: Colors.black,
                                  offset: Offset(0, 0),
                                  blurRadius: 0))
                        else
                          _buildItem_withcolor(
                              Icons.no_accounts_rounded,
                              "",
                              Name,
                              Colors.black,
                              const Shadow(
                                  color: Colors.black,
                                  offset: Offset(0, 0),
                                  blurRadius: 0)),
                        const SizedBox(height: 20),
                        if (is_online)
                          _buildItem_loc(
                              Icons.location_pin, "", new_loc_long, new_loc_alt)
                        else
                          _buildItem_loc(Icons.not_listed_location_rounded, "",
                              new_loc_long, new_loc_alt),
                        const SizedBox(height: 20),
                        if (double.tryParse(new_pulse)! >= 65 &&
                            double.tryParse(new_pulse)! < 320)
                          _buildItem_withcolor(
                              Icons.favorite_outlined,
                              "",
                              new_pulse,
                              Colors.green,
                              const Shadow(
                                  color: Colors.black,
                                  offset: Offset(-5, 3),
                                  blurRadius: 10))
                        else
                          _buildItem_withcolor(
                              Icons.heart_broken_sharp,
                              "",
                              new_pulse,
                              Colors.red,
                              const Shadow(
                                  color: Colors.black,
                                  offset: Offset(-5, 3),
                                  blurRadius: 10)),
                        const SizedBox(height: 20),
                        _buildItem_withcolor(
                            Icons.speed,
                            "",
                            "${(double.parse(new_speed) * 10).floor() / 10} Km/Hr",
                            Colors.black,
                            const Shadow(
                                color: Colors.black,
                                offset: Offset(0, 0),
                                blurRadius: 0)),
                        const SizedBox(height: 20),
                        if (double.parse(new_pulse.toString()) >= 65 &&
                            double.parse(new_pulse.toString()) < 320)
                          if (is_online)
                            _buildItem_withcolor(
                                Icons.shield,
                                "",
                                "Safe",
                                Colors.green,
                                const Shadow(
                                    color: Colors.black,
                                    offset: Offset(-5, 3),
                                    blurRadius: 10))
                          else
                            _buildItem_withcolor(
                                Icons.not_interested_outlined,
                                "",
                                "Offline",
                                Colors.red,
                                const Shadow(
                                    color: Colors.black,
                                    offset: Offset(-5, 3),
                                    blurRadius: 10))
                        else if (is_online)
                          _buildItem_withcolor(
                              Icons.dangerous,
                              "",
                              "Danger",
                              Colors.red,
                              const Shadow(
                                  color: Colors.black,
                                  offset: Offset(-5, 3),
                                  blurRadius: 10))
                        else
                          _buildItem_withcolor(
                              Icons.not_interested_outlined,
                              "",
                              "Offline",
                              Colors.red,
                              const Shadow(
                                  color: Colors.black,
                                  offset: Offset(-5, 3),
                                  blurRadius: 10)),
                        SizedBox(height: screenHeight * 0.01),
                        Center(
                          child: ArcedSquareButton(
                            icon: Icons.video_library_rounded,
                            Bourders: 20,
                            heights: screenHeight * 0.1,
                            widths: screenWidth * 0.3,
                            IconSize: 60,
                            Iconcolor: Colors.amberAccent,
                            label: "Watch",
                            textcolor: Colors.black,
                            textsize: 25,
                            onPressed: () => go_to_stream(),
                            ButtonColors: const [
                              Color.fromARGB(255, 138, 98, 165),
                              Color.fromARGB(255, 121, 20, 80),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ))));
  }

  void _openGoogleMaps(String long, String alt) async {
    if (is_online) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((_) => Maps(
                    long: double.parse(long),
                    alt: double.parse(alt),
                    Name: Name,
                  ))));
    }
  }

  Widget _buildItem_loc(IconData icon, String title, String long, String alt) {
    return GestureDetector(
      onTap: () {
        _openGoogleMaps(long, alt);
      },
      child: Container(
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 138, 98, 165),
              Color.fromARGB(255, 80, 20, 121)
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          leading: Icon(
            icon,
            color: Colors.red,
            size: 50,
            shadows: const [
              Shadow(color: Color.fromARGB(80, 0, 0, 0), offset: Offset(-3, 5))
            ],
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            long + " " + alt,
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.redAccent,
            shadows: [
              Shadow(color: Color.fromARGB(80, 0, 0, 0), offset: Offset(2, 3))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem_withcolor(
      IconData icon, String title, String value, Color color, Shadow sh) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
      child: Row(
        children: [
          Icon(
            icon,
            size: 40,
            color: color,
            shadows: [sh],
          ),
          SizedBox(width: screenWidth * 0.001),
          Text(
            "$title ",
            style: const TextStyle(fontSize: 25),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 25),
          ),
          SizedBox(width: screenWidth * 0.03),
          if (title == "Location")
            TextButton.icon(
              onPressed: () => (),
              icon: const Icon(
                Icons.track_changes_outlined,
                size: 40,
                color: Colors.redAccent,
              ),
              label: const Text(""),
            ),
        ],
      ),
    );
  }
}
