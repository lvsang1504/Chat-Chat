import 'package:chat_app/Pages/boading_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  String id = prefs.getString('id') ?? "";
  print(id);
  runApp(MyApp(
    userid: id,
  ));
}

// void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String userid;

  const MyApp({Key? key, required this.userid}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatChat',
      home: userid == ""
          ? const BoardingScreen()
          : HomeScreen(currentUserID: userid),
      debugShowCheckedModeBanner: false,
    );
  }
}
