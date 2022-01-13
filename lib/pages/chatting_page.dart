import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Widgets/progress_widget.dart';
import 'package:chat_app/widgets/full_image_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final String joinedAt;
  final String userBio;

  const Chat({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    required this.joinedAt,
    required this.userBio,
  }) : super(key: key);

  void lastmessage(DocumentSnapshot doc) {
    if (doc["idFrom"] == receiverId) Text(doc['timestamp']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25.0),
                    ),
                  ),
                  context: context,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black,
                          backgroundImage:
                              CachedNetworkImageProvider(receiverImage),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Chatting with',
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey.shade800
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 45),
                        ),
                        Text(
                          receiverName,
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey.shade800
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 45),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Member Since: ' +
                              DateFormat("dd MMMM , yyyy - hh:mm:aa").format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(joinedAt))),
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey
                                  : Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Status : ' + userBio,
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey
                                  : Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: CachedNetworkImageProvider(receiverImage),
              ),
            ),
          ),
        ],
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black87,
        title: Text(
          receiverName,
          style:
              const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(receiverId: receiverId, receiverImage: receiverImage),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverImage;

  const ChatScreen(
      {Key? key, required this.receiverId, required this.receiverImage})
      : super(key: key);

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late String receiverId;
  late String receiverImage;
  late File imagefile;
  late String imageUrl;
  late String chatID;
  late SharedPreferences sharedPreferences;
  late String id;
  var listMessages;

  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ScrollController listscrollController = ScrollController();
  late bool isDisplaySticker;
  late bool isLoading;

  @override
  void initState() {
    receiverId = widget.receiverId;
    receiverImage = widget.receiverImage;
    isDisplaySticker = false;
    isLoading = false;
    focusNode.addListener(onFocusChange);
    chatID = "";
    readFromLocal();
    super.initState();
  }

  readFromLocal() async {
    sharedPreferences = await SharedPreferences.getInstance();
    id = sharedPreferences.getString("id") ?? "";

    if (id.hashCode <= receiverId.hashCode) {
      chatID = '$id-$receiverId';
    } else {
      chatID = '$receiverId-$id';
    }
    FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"chattingWith": receiverId});
    setState(() {});
  }

  onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isDisplaySticker = false;
      });
    }
  }

  createInput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.black87,
            child: IconButton(
                icon: Icon(
                  Icons.image,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: getImageFromGallery),
          ),
          // suffix emoji iconbutton
          Material(
            color: Colors.black87,
            child: IconButton(
                icon: Icon(Icons.face, color: Theme.of(context).primaryColor),
                onPressed: getSticker),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Material(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(15),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: InputBorder.none,
                    hintText: "  Write a text here ...",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  focusNode: focusNode,
                ),
              ),
            ),
          ),
          // send msg button
          Material(
            color: Colors.black87,
            child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  setState(() {
                    onSendMessage(textEditingController.text, 0);
                  });
                }),
          ),
        ],
      ),
    );
  }

  createListofChat() {
    return Flexible(
      child: chatID == ""
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              ),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(chatID)
                  .collection(chatID)
                  .orderBy("timestamp", descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor),
                    ),
                  );
                } else {
                  listMessages = snapshot.data.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: snapshot.data!.docs.length,
                    reverse: true,
                    controller: listscrollController,
                    itemBuilder: (BuildContext context, int index) {
                      return createItem(index, snapshot.data!.docs[index]);
                    },
                  );
                }
              }),
    );
  }

  Widget createItem(int index, DocumentSnapshot doc) {
    // sender is me : showing on right side
    if (doc["idFrom"] == id) {
      return messageOfMe(doc, index);
    } else {
      // sender is NOT me : showing on left side
      return messageOfUser(index, doc);
    }
  }

  Container messageOfUser(int index, DocumentSnapshot<Object?> doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat("hh:mm dd/MM/yyyy").format(
                  DateTime.fromMillisecondsSinceEpoch(
                      int.parse(doc["timestamp"]))),
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontStyle: FontStyle.italic),
            ),
          ),
          Row(
            children: [
              // messages
              isLastMsgLeft(index)
                  ? Material(
                      // display reciver profileImage
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          width: 35,
                          height: 35,
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).primaryColor),
                          ),
                        ),
                        imageUrl: receiverImage,
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.hardEdge,
                    )
                  : Container(
                      width: 35,
                    ),
              // Dislay the user message
              doc["type"] == 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                              bottomLeft: Radius.circular(15)),
                        ),
                        child: Text(
                          doc['contextMsg'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    )
                  : doc["type"] == 1
                      ? Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullPhoto(url: doc['contextMsg']),
                              ),
                            ),
                            child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    width: 200,
                                    height: 200,
                                    padding: const EdgeInsets.all(70),
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                          Theme.of(context).primaryColor),
                                    ),
                                  ),
                                  imageUrl: doc['contextMsg'],
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Material(
                                          child: Image.asset(
                                            'images/img_not_available.jpeg',
                                            height: 200,
                                            width: 200,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          clipBehavior: Clip.hardEdge),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                clipBehavior: Clip.hardEdge),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(10),
                          child: Image.asset(
                            "images/stickers/${doc['contextMsg']}.gif",
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
            ],
          ),
          // /message timestamp

          // isLastMsgLeft(index)
          //     ? Container(
          //         margin: const EdgeInsets.only(left: 50, top: 5, bottom: 5),
          //         child: Text(
          //           DateFormat("dd MMMM, yyyy- hh:mm:aa").format(
          //               DateTime.fromMillisecondsSinceEpoch(
          //                   int.parse(doc["timestamp"]))),
          //           style: const TextStyle(
          //               color: Colors.grey,
          //               fontSize: 12,
          //               fontStyle: FontStyle.italic),
          //         ))
          //     : Container()
        ],
      ),
    );
  }

  Column messageOfMe(DocumentSnapshot<Object?> doc, int index) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            DateFormat("hh:mm aa dd/MM/yyyy").format(
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(doc["timestamp"]))),
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontStyle: FontStyle.italic),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // doc["type"]
            // 0 = text , 1 = image , 2 = stickers
            // doc["type"]==0 ? Container(text)  :  doc["type"]==1 ? Container(image): Container(stickers),
            doc["type"] == 0
                ? Container(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    constraints: const BoxConstraints(maxWidth: 200),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15))),
                    child: Text(
                      doc['contextMsg'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : doc["type"] == 1
                    ? Container(
                        margin: EdgeInsets.only(
                            bottom: isLastMsgRight(index) ? 20 : 10, right: 10),
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FullPhoto(url: doc['contextMsg']),
                            ),
                          ),
                          child: Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  width: 200,
                                  height: 200,
                                  padding: const EdgeInsets.all(70),
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                        Theme.of(context).primaryColor),
                                  ),
                                ),
                                imageUrl: doc['contextMsg'],
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,

                                // if somehow image can't be retrive or showed then show not available image
                                errorWidget: (context, url, error) => Material(
                                    child: Image.asset(
                                      'images/img_not_available.jpeg',
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    clipBehavior: Clip.hardEdge),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              clipBehavior: Clip.hardEdge),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: Image.asset(
                          "images/stickers/${doc['contextMsg']}.gif",
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
          ],
        ),
        // Container(
        //     padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        //     margin: EdgeInsets.only(
        //         bottom: isLastMsgRight(index) ? 20 : 10, left: 10),
        //     child: Text(
        //       DateFormat("hh:mm dd/MM/yyyy").format(
        //           DateTime.fromMillisecondsSinceEpoch(
        //               int.parse(doc["timestamp"])) ),
        //       style: const TextStyle(
        //           color: Colors.grey,
        //           fontSize: 10,
        //           fontStyle: FontStyle.italic),
        //     )),
      ],
    );
  }

  bool isLastMsgRight(int index) {
    if ((index > 0 &&
            listMessages != null &&
            listMessages[index - 1]['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMsgLeft(int index) {
    if ((index > 0 &&
            listMessages != null &&
            listMessages[index - 1]['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget createStickers() {
    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      decoration: Theme.of(context).brightness == Brightness.light
          ? const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey, width: 0.5),
              ),
            )
          : BoxDecoration(
              color: const Color(0xff50e7ed).withOpacity(.6),
              border: const Border(
                top: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // row1
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    child: Image.asset(
                      "images/stickers/mimi1.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("mimi1", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/mimi2.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("mimi2", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/mimi3.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("mimi3", 2);
                      });
                    }),
              ],
            ),
            const SizedBox(
              height: 5,
            ),

// row2
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    child: Image.asset(
                      "images/stickers/mimi4.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("mimi4", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/mimi5.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("mimi5", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/mimi6.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("mimi6", 2);
                      });
                    }),
              ],
            ),
            const SizedBox(
              height: 5,
            ),

// row3
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    child: Image.asset(
                      "images/stickers/mimi7.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("mimi7", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/mimi8.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("mimi8", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/mimi9.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("mimi9", 2);
                      });
                    }),
              ],
            ),
            const SizedBox(
              height: 10,
            ),

            // row4
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute4.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute4", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute5.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute5", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute6.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute6", 2);
                      });
                    }),
              ],
            ),
            const SizedBox(
              height: 10,
            ),

            // row5
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute1.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute1", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute2.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute2", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute3.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute3", 2);
                      });
                    }),
              ],
            ),
            const SizedBox(
              height: 10,
            ),

            // row6
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute7.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute7", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute8.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute8", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute9.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute9", 2);
                      });
                    }),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            // row7
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute10.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute10", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute11.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute11", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute12.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute12", 2);
                      });
                    }),
              ],
            ),
            const SizedBox(
              height: 10,
            ),

            // row8
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute13.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute13", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute14.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute14", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute15.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute15", 2);
                      });
                    }),
              ],
            ),
            const SizedBox(
              height: 10,
            ),

            // row9
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute16.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute16", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/cute17.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("cute17", 2);
                      });
                    }),
                TextButton(
                    child: Image.asset(
                      "images/stickers/mimi10.gif",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      setState(() {
                        onSendMessage("mimi10", 2);
                      });
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }

  Future<bool> onBackPress() {
    if (isDisplaySticker == true) {
      setState(() {
        isDisplaySticker = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  createLoading() {
    return Container(
      child: isLoading ? circularProgress() : Container(),
    );
  }

  Future getImageFromGallery() async {
    var pickedfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedfile != null) {
      setState(() {
        imagefile = File(pickedfile.path);
        isLoading = true;
      });
    }
    uploadImageToFirebaseStorage();
  }

  Future uploadImageToFirebaseStorage() async {
    //  bestway to code
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference =
        FirebaseStorage.instance.ref().child("Chat Images").child(fileName);
    UploadTask storageUploadTask = storageReference.putFile(imagefile);
    TaskSnapshot storageTaskSnapshot = await storageUploadTask;
    storageTaskSnapshot.ref.getDownloadURL().then((value) {
      setState(() {
        imageUrl = value;
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Error :" + error.toString());
    });
  }

  onSendMessage(String contextMsg, int type) {
//  type =0: its a text message
//  type =1: its a imageFile
//  type =2:its a StickerEmojies

    if (contextMsg != "") {
      textEditingController.clear();
      var docMsgRef = FirebaseFirestore.instance
          .collection("messages")
          .doc(chatID)
          .collection(chatID)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(docMsgRef, {
          "idFrom": id,
          "idTo": receiverId,
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "contextMsg": contextMsg,
          "type": type
        });
      });
      listscrollController.animateTo(0.0,
          duration: const Duration(microseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: "Empty message can't be send !");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Column(
              children: [
                // list of message section
                createListofChat(),

                // show the stickers
                isDisplaySticker ? createStickers() : Container(),

                // user send section
                createInput(),

                createLoading(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
