import 'package:flutter/material.dart';

circularProgress() {
  return Container(
    alignment: AlignmentDirectional.center,
    padding: const EdgeInsets.only(top: 12.0),
    child: const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Color(0xff14DAE2)),
    ),
  );
}

linearProgress() {
  return Container(
    alignment: AlignmentDirectional.center,
    padding: const EdgeInsets.only(top: 12.0),
    child: const LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
        Colors.lightGreenAccent,
      ),
    ),
  );
}
