/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_signin_example/widget/scanned_device.dart';

import '../main.dart';

class QRScanPage extends StatefulWidget {
  final bool addrem;
  final String x;

  const QRScanPage({this.addrem, this.x});

  @override
  State<StatefulWidget> createState() => _QRScanPageState(this.addrem, this.x);
}

class _QRScanPageState extends State<QRScanPage> {
  final bool addrem;
  final String x;

  _QRScanPageState(this.addrem, this.x);

  String qrCode = 'Unknown';

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade900,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 8),
              Text(
                x + " Device",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              SizedBox(height: 72),
              ElevatedButton(
                  onPressed: () => scanQRCode(), child: Text('Scan QR Code')),
              Spacer(),
              Spacer(),
            ],
          ),
        ),
      );

  showAlertDialog(BuildContext context, String x, String y) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(x),
      content: Text(y),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('Device');

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
  }

  void device_scanned(String qrCode) async {
    bool docExists = await checkIfDocExists(qrCode);
    if (!docExists) {
      showAlertDialog(context, "No Document found",
          "Please try to scan a different QR CODE");
    } else {
      DocumentReference device =
      FirebaseFirestore.instance.collection('Device').doc(qrCode);

      String request = "Requests: None";

      bool remove =
      await device.get().then((document) => document.data()['remove']);
      bool add = await device.get().then((document) => document.data()['add']);

      String tempowner =
      await device.get().then((document) => document.data()['tempOwner']);
      String owner =
      await device.get().then((document) => document.data()['Owner']);
      String lastowner =
      await device.get().then((document) => document.data()['lastOwner']);
      String devicename = await device.get().then((document) =>
      document.data()['DeviceName']);
      int timeused = await device.get().then((document) =>
      document.data()['TimeUsed']);
      if (add) {
        request = "Requests: Request to remove by "+tempowner;
      }
      if (remove) {
        request = "Requests: Request to add by "+owner;
      }
      ScannedDevice(qrCode: qrCode,
          device: device,
          remove: remove,
          add: add,
          tempowner: tempowner,
          owner: owner,
          lastowner: lastowner,
          devicename: devicename,
          timeused: timeused,
          request: request);
    }
  }

  void CharlieChaplin(String qrCode) async {
    DocumentReference device =
        FirebaseFirestore.instance.collection('Device').doc(qrCode);

    print(qrCode);
    final user = FirebaseAuth.instance.currentUser;
    bool docExists = await checkIfDocExists(qrCode);
    if (!docExists) {
      showAlertDialog(context, "No Document found",
          "Please try to scan a different QR CODE");
    } else {
      bool remove =
          await device.get().then((document) => document.data()['remove']);
      bool add = await device.get().then((document) => document.data()['add']);
      String tempowner =
          await device.get().then((document) => document.data()['tempOwner']);
      String owner =
          await device.get().then((document) => document.data()['Owner']);

      if (widget.addrem) {
        if (user.displayName != owner) {
          if (remove) {
            device.update({'Owner': user.displayName});
            device.update({'remove': false});
            device.update({'add': false});
            showAlertDialog(context, "Device Added Successfully ",
                user.displayName + " is now the New Owner");
          } else if ((!remove) && (!add)) {
            device.update({'add': true});
            device.update({'tempOwner': user.displayName});
            showAlertDialog(context, "Awaiting Previous Owner's confirmation",
                user.displayName + " is now the Temporary Owner");
          } else if ((!remove) && (add)) {
            showAlertDialog(
                context, "Error", "You are already the Temporary owner");
          }
        } else {
          showAlertDialog(context, "Error", "You are already the Owner");
        }
      } else {
        if (user.displayName == owner) {
          if (add) {
            device.update({'Owner': tempowner});
            device.update({'remove': false});
            device.update({'add': false});
            showAlertDialog(context, "Device Removed Successfully",
                user.displayName + " is now the Previous Owner");
          } else if ((!remove) && (!add)) {
            device.update({'remove': true});
            device.update({'lastOwner': user.displayName});
            device.update({'tempOwner': "Awaiting New Owner"});
            showAlertDialog(context, "Awaiting New Owner's confirmation",
                user.displayName + " has confirmed Device Removal");
          } else if ((remove) && (!add)) {
            showAlertDialog(context, "Error",
                "Your device is already in queue to change owners ");
          }
        } else {
          showAlertDialog(context, "Error", "You do not Own the Device");
        }
      }
    }
  }

  Future<void> scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#00ff00',
        'Cancel',
        false,
        ScanMode.QR,
      );

      if (!mounted) return;

      setState(() {
        this.qrCode = qrCode;
        CharlieChaplin(qrCode);
      });
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }
}
*/