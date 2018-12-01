import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drawappFirebase/app.dart';
import 'package:flutter/material.dart';

void main() async {
  await Firestore.instance.settings(
    timestampsInSnapshotsEnabled: true,
  );

  runApp(DrawApp());
}
