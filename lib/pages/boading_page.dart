import 'package:chat_app/Pages/login_page.dart';
import 'package:fancy_on_boarding/fancy_on_boarding.dart';
import 'package:flutter/material.dart';

final pagelist = [
  PageModel(
    color: const Color(0xff292D38),
    heroImagePath: "images/board1.png",
    iconImagePath: "images/phone.png",
    title: const Text(
      "Holla !",
      style: TextStyle(
        fontWeight: FontWeight.w800,
        color: Colors.white,
        fontSize: 34.0,
      ),
    ),
    body: const Text("Welcome to DockChat \n \n Swipe next ➡",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        )),
  ),
  PageModel(
    color: const Color(0xff14DAE2),
    heroImagePath: "images/boad2.png",
    iconImagePath: "images/like-filled.png",
    title: const Text(
      "Easy to Use!",
      style: TextStyle(
        fontWeight: FontWeight.w800,
        color: Colors.white,
        fontSize: 34.0,
      ),
    ),
    body: const Text(
      "MaterialDesign with lots of Features\n \n Swipe next ➡",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
      ),
    ),
  ),
  PageModel(
    color:  Color(0xff292D38),
    heroImagePath: "images/Group_chat.png",
    iconImagePath: "images/connect.png",
    title: const Text(
      "Connect Now",
      style: TextStyle(
        fontWeight: FontWeight.w800,
        color: Colors.white,
        fontSize: 34.0,
      ),
    ),
    body: const Text(
      "over 2 million users around world\n \n lets start ➡",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
      ),
    ),
  ),
];

class BoardingScreen extends StatelessWidget {
  const BoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FancyOnBoarding(
        doneButtonText: "Start",
        skipButtonText: "Skip",
        pageList: pagelist,
        onDoneButtonPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        ),
        onSkipButtonPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        ),
      ),
    );
  }
}
