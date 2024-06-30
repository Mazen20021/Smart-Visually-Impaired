import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'dart:typed_data';

class VideoPlayerScreen extends StatefulWidget {
  final String id, name;
  const VideoPlayerScreen({super.key, required this.id, required this.name});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState(name: name);
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  String? currentFrame;
  DatabaseReference? framesRef;
  final String name;
  _VideoPlayerScreenState({required this.name});
  @override
  void initState() {
    super.initState();
    framesRef =
        FirebaseDatabase.instance.reference().child('frames/${widget.id}');
    framesRef!.onChildAdded.listen((event) {
      setState(() {
        currentFrame = event.snapshot.value as String;
      });
    });
  }

  Uint8List decodeBase64Image(String base64String) {
    return base64Decode(base64String);
  }

  @override
  void dispose() {
    print("Stream Closed");
    framesRef!.onChildAdded.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 208, 236),
        title: Row(children: [
          Text("Stream From $name",
              style: const TextStyle(color: Color.fromARGB(255, 31, 37, 68))),
          const SizedBox(width: 5),
          const Icon(Icons.streetview, size: 45),
        ]),
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: currentFrame == null
              ? const CircularProgressIndicator(
                  color: Colors.yellowAccent,
                  backgroundColor: Color.fromARGB(255, 68, 79, 175))
              : Image.memory(decodeBase64Image(currentFrame!)),
        ),
      ),
    );
  }
}
