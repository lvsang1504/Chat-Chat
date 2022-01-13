import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Widgets/progress_widget.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late SharedPreferences preferences;
  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';
  TextEditingController nickNametextEditingController = TextEditingController();
  TextEditingController aboutMetextEditingController = TextEditingController();
  File? imagefileAvator = null;
  bool isLoading = false;
  final FocusNode nickNameFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();
  @override
  void initState() {
    readDataFromLocal();
    super.initState();
  }

  GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('id');

    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const MyApp(
                  userid: '',
                )),
        (Route<dynamic> route) => false);
  }

  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();
//fetching data from local and storing in variables
    id = preferences.getString('id')!;
    nickname = preferences.getString('nickname') ?? "";
    aboutMe = preferences.getString('aboutMe') ?? "";
    photoUrl = preferences.getString('photoUrl') ?? "";
    nickNametextEditingController = TextEditingController(text: nickname);
    aboutMetextEditingController = TextEditingController(text: aboutMe);
    setState(() {});
  }

  Future getImage() async {
    var pickedfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedfile != null) {
      setState(() {
        imagefileAvator = File(pickedfile.path);
        isLoading = true;
      });
    }
    uploadImageToFirebaseStorage();
  }

  Future uploadImageToFirebaseStorage() async {
    String fileName = id;
    Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask storageUploadTask = storageReference.putFile(imagefileAvator!);
    TaskSnapshot storageTaskSnapshot;
// once uploading is done
    storageUploadTask.then((value) {
      storageTaskSnapshot = value;
      storageTaskSnapshot.ref.getDownloadURL().then((value) {
        setState(() {
          photoUrl = value;
        });
// now updating data to firestore
        FirebaseFirestore.instance.collection('users').doc(id).update({
          "photoUrl": photoUrl,
          "nickname": nickname,
          "aboutMe": aboutMe
        }).then((value) async {
// updating data to local
          await preferences.setString("photoUrl", photoUrl);
          setState(() {
            isLoading = false;
          });
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.SUCCES,
                  animType: AnimType.BOTTOMSLIDE,
                  title: 'Photo Uploaded',
                  desc: 'Your photo has been updated succesfully',
                  btnOkText: 'Okay',
                  btnOkColor: Theme.of(context).primaryColor,
                  btnOkOnPress: () {})
              .show();
          // Fluttertoast.showToast(msg: "Updated successfully", backgroundColor: Theme.of(context).primaryColor
          // );
        });
      }, onError: (errorMsg) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Error in Getting the Download Url",
            backgroundColor: Theme.of(context).primaryColor);
      });
    }, onError: (errorMsg) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: errorMsg.toString(),
          backgroundColor: Theme.of(context).primaryColor);
    });
  }

  void updateData() {
    nickNameFocusNode.requestFocus();
    aboutMeFocusNode.requestFocus();
    setState(() {
      isLoading = false;
    });

// now updating data to firestore
    FirebaseFirestore.instance.collection('users').doc(id).update({
      "photoUrl": photoUrl,
      "nickname": nickname,
      "aboutMe": aboutMe
    }).then((value) async {
// updating data to local
      await preferences.setString("photoUrl", photoUrl);
      await preferences.setString("aboutMe", aboutMe);
      await preferences.setString("nickname", nickname);
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
          msg: "Updated successfully",
          backgroundColor: Theme.of(context).primaryColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xff251F34),
      appBar: AppBar(
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        
      ),
      body: Scaffold(
        backgroundColor: Colors.black87,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 15,
              ),
              // Profile Image
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (imagefileAvator == null)
                          ? (photoUrl != "")
                              ? Material(
                                  // if photoUrl is not null means pic exists : display the  image file
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      width: 200,
                                      height: 200,
                                      padding: const EdgeInsets.all(20),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor: AlwaysStoppedAnimation(
                                            Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    imageUrl: photoUrl,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(125),
                                  clipBehavior: Clip.hardEdge,
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 90,
                                  color: Colors.grey,
                                )
                          : Material(
                              // displaying the updated new avatar
                              child: Image.file(
                                imagefileAvator!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(125),
                              clipBehavior: Clip.hardEdge,
                            ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          size: 100,
                          color: Colors.white54.withOpacity(0.3),
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(0.0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.grey,
                        iconSize: 200,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20),
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isLoading ? circularProgress() : Container(),
                  ),
      
                  //  Update UI
      
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 18,
                      ),
                      Container(
                        margin: const EdgeInsets.all(15),
                        // margin: EdgeInsets.only(left: 10, bottom: 12, top: 10),
                        child: const Text(
                          'Profile Name',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // usernameInfo
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30)),
                    child: TextFormField(
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      controller: nickNametextEditingController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: "E.g Your Name",
                        contentPadding: EdgeInsets.all(5),
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onChanged: (value) {
                        nickname = value;
                      },
                      focusNode: nickNameFocusNode,
                    ),
                    margin: const EdgeInsets.only(left: 30, right: 30),
                  ),
      
                  // UserAboutME Feild
      
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.edit,
                        color: Colors.grey,
                        size: 18,
                      ),
                      Container(
                        margin: const EdgeInsets.all(15),
                        // margin: EdgeInsets.only(left: 10, bottom: 12, top: 30),
                        child: const Text(
                          'About ME',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // UserBio
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      controller: aboutMetextEditingController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: "E.g Hey there ! I am Using DockChat",
                        contentPadding: EdgeInsets.all(5),
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onChanged: (value) {
                        aboutMe = value;
                      },
                      focusNode: aboutMeFocusNode,
                    ),
                    margin: const EdgeInsets.only(left: 30, right: 30),
                  ),
      
                  // Update Button
                  Container(
                    width: 200,
                    height: 70,
                    padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                    margin: const EdgeInsets.only(top: 50, bottom: 2),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 16),
                      ),
                      color: Colors.green,
                      splashColor: Colors.transparent,
                      textColor: Colors.white,
                      onPressed: updateData,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Logout Button
                  Container(
                    width: 200,
                    height: 50,
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        child: const Text(
                          'Logout',
                          style: TextStyle(fontSize: 16),
                        ),
                        color: Colors.red,
                        splashColor: Colors.transparent,
                        textColor: Colors.white,
                        onPressed: () {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.WARNING,
                            animType: AnimType.BOTTOMSLIDE,
                            title: 'You will be logout',
                            desc: 'Do you want to continue.. ?',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {
                              logoutUser();
                            },
                          ).show();
                        }),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
