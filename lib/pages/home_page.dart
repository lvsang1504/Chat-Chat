import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Pages/account_settings_page.dart';
import 'package:chat_app/Pages/chatting_page.dart';
import 'package:chat_app/Widgets/progress_widget.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:timeago/timeago.dart" as timeago;

class HomeScreen extends StatefulWidget {
  final String currentUserID;

  const HomeScreen({Key? key, required this.currentUserID}) : super(key: key);
  @override
  State createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late String currentuserId;
  @override
  void initState() {
    currentuserId = widget.currentUserID;
    super.initState();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _textEditingController = TextEditingController();

  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const MyApp(
                  userid: '',
                )),
        (Route<dynamic> route) => false);
  }

  homePageHeader() {
    return AppBar(
      backgroundColor: Colors.black87,
      title: const Text("Chat Chat"),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: IconButton(
            icon: const Icon(
              Icons.account_box,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: homePageHeader(),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').get(),
        builder: (context, AsyncSnapshot datasnapshot) {
          if (!datasnapshot.hasData) {
            return circularProgress();
          } else {
            List<UserResult> searchResultList = [];
            datasnapshot.data!.docs.forEach((document) {
              UserChat eachuser = UserChat.fromDocument(document);
              UserResult userResult = UserResult(
                eachuser: eachuser,
              );

              if (currentuserId != document['id']) {
                searchResultList.add(userResult);
              }
            });
            return ListView(
              children: searchResultList,
            );
          }
        },
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  final UserChat eachuser;

  const UserResult({Key? key, required this.eachuser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Colors.white12,
        ),
        child: Card(
          color: Colors.white12,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Chat(
                              receiverId: eachuser.id,
                              receiverImage: eachuser.photoUrl,
                              receiverName: eachuser.nickname,
                              joinedAt: eachuser.createdAt,
                              userBio: eachuser.aboutMe,
                            ))),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage:
                        CachedNetworkImageProvider(eachuser.photoUrl),
                  ),
                  title: Text(
                    eachuser.nickname,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                  subtitle: Text(
                    timeago.format(DateTime.fromMillisecondsSinceEpoch(
                        int.parse(eachuser.createdAt))),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                  // subtitle: Text(
                  //   DateFormat("dd MMMM , yyyy").format(
                  // DateTime.fromMillisecondsSinceEpoch(
                  //     int.parse(eachuser.createdAt))),
                  // style: const TextStyle(
                  //     fontWeight: FontWeight.w600, color: Colors.grey),
                  // ),
                ),
              )
            ],
          ),
        ));
  }
}
