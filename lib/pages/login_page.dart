import 'dart:async';
import 'package:chat_app/Pages/home_page.dart';
import 'package:chat_app/Widgets/progress_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // SharedPreferences preferences;

  bool isLoggedIn = false;
  bool isLoading = false;
  late User currentUser;

  Future<void> controlSignIn() async {
    setState(() {
      isLoading = true;
    });
    var preferences = await SharedPreferences.getInstance();
    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuthentication =
        await googleUser!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken);

    User? myFirebaseUser =
        (await _firebaseAuth.signInWithCredential(credential)).user;

    // SignIn Success

    // ignore: unnecessary_null_comparison
    if (myFirebaseUser != null) {
//      Checking if already SignIn Up

      final QuerySnapshot resultQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: myFirebaseUser.uid)
          .get();
      final List<DocumentSnapshot> documentSnapshot = resultQuery.docs;

//      Retrive the list of snapshotQuery from firestone

      // SAVE DATA: User is new and need to store the information in fireStore
      if (documentSnapshot.isEmpty) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(myFirebaseUser.uid)
            .set({
          "nickname": myFirebaseUser.displayName,
          "photoUrl": myFirebaseUser.photoURL,
          "id": myFirebaseUser.uid,
          "aboutMe": "Hey there ! I am Using DockChat",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "chattingWith": null,
        });

//        Writing data to Local
        currentUser = myFirebaseUser;
        await preferences.setString('id', currentUser.uid);
        await preferences.setString('nickname', currentUser.displayName!);
        await preferences.setString('photoUrl', currentUser.photoURL!);
      }
//      User Already Exist
      else {
        //        Writing data to Local
        currentUser = myFirebaseUser;
        await preferences.setString('id', documentSnapshot[0]['id']);
        await preferences.setString(
            'nickname', documentSnapshot[0]['nickname']);
        await preferences.setString(
            'photoUrl', documentSnapshot[0]['photoUrl']);
        await preferences.setString('aboutMe', documentSnapshot[0]['aboutMe']);
      }
      Fluttertoast.showToast(
          msg: 'Welcome, SignIn Success',
          backgroundColor: Theme.of(context).primaryColor);
      setState(() {
        isLoading = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              currentUserID: myFirebaseUser.uid,
            ),
          ),
        );
      });
    }
    //    SignIn Failed
    else {
      Fluttertoast.showToast(
          msg: 'Try Again !, SignIn Failed',
          backgroundColor: Theme.of(context).primaryColor);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff292D38),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        //Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'DockChat',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              Center(
                child: Hero(
                  tag: "login",
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              Text(
                'Welcome to DockChat',
                style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 22),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: const Color(0xff293238),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 30),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Please sign in to continue.',
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                      fontSize: 13),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: controlSignIn,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 65,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/google_signin_button.png'),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2),
                child: isLoading ? circularProgress() : Container(),
              ),
            ],
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: DevloperInfo(),
          )
        ],
      ),
    );
  }
}

class DevloperInfo extends StatelessWidget {
  const DevloperInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          'Version 1.0',
          style: TextStyle(color: Colors.grey, letterSpacing: 1.2),
          textAlign: TextAlign.center,
        ),
        Text(
          'Developed by © Swaraj',
          style: TextStyle(color: Colors.grey, letterSpacing: 1.2),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
