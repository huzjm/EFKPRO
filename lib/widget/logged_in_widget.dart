import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_signin_example/provider/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'qr_scan_page.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_signin_example/widget/scanned_device.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocation/geolocation.dart';

class LoggedInWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoggedInWidgetState();
}

class _LoggedInWidgetState extends State<LoggedInWidget> {
  String qrCode = 'Unknown';
  final user = FirebaseAuth.instance.currentUser;
  GeoPoint location;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.blueGrey.shade900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Logged In As',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          CircleAvatar(
            maxRadius: 25,
            backgroundImage: NetworkImage(user.photoURL),
          ),
          SizedBox(height: 8),
          Text(
            'Name: ' + user.displayName,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Email: ' + user.email,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          ElevatedButton(
              onPressed: () => scanQRCode(), child: Text('Scan QR Code')),
          /*ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        QRScanPage(addrem: false, x: "Remove"),
                  )),
              child: Text('Remove Device')),
          ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        QRScanPage(addrem: true, x: "Add"),
                  )),
              child: Text('Add Device')),
           */
          ElevatedButton(
            onPressed: () {
              final provider =
              Provider.of<GoogleSignInProvider>(context, listen: false);
              provider.logout();
            },
            child: Text('Logout'),
          )
        ],
      ),
    );
  }

  void latlang() async {
    LocationResult result = await Geolocation.lastKnownLocation();

// best option for most cases
    Geolocation.currentLocation(accuracy: LocationAccuracy.best)
        .listen((result) {
      if (result.isSuccessful) {
        print(result.location.latitude);
        print(result.location.longitude);
        if (!mounted) return;
        setState(() {
          location =
              GeoPoint(result.location.latitude, result.location.longitude);
        });

        // todo with result
      }
    });
  }
Future<bool> staffcheck(DocumentReference abc) async{
  String last =
      await abc.get().then((document) => document.data()['Name']);
  if(last == null){
    return false;
  }
  else
    return true;

}

  void device_scanned(String qrCode) async {
    var currentdoc;
    bool staffExists=false;
    FirebaseFirestore.instance.collection('Staff').where(
        'Name', isEqualTo: user.displayName).get().then((snapshots)async {currentdoc=snapshots.docs;
        staffExists= await staffcheck(snapshots.docs[0].reference);
        }
    );
    latlang();
    print(staffExists.toString());
    bool docExists = await checkIfDocExists(qrCode);
    DocumentReference device =
    FirebaseFirestore.instance.collection('Device').doc(qrCode);
    Timestamp ts =
    await device.get().then((document) => document.data()['Date']);
    DateTime dt = ts.toDate();
    String request = "Requests: None";
    bool remove =
    await device.get().then((document) => document.data()['remove']);
    bool add = await device.get().then((document) =>
    document.data()['add']);
    GeoPoint lastlocation =
    await device.get().then((document) => document.data()['Location']);
    GeoPoint locate = location;

    String tempowner = await device.get().then((document) =>
    document.data()['tempOwner']);
    var tempownerdoc;
    FirebaseFirestore.instance.collection('Staff').where(
        'Name', isEqualTo: tempowner).get().then((d3) => tempownerdoc = d3.docs);
    String owner =
    await device.get().then((document) => document.data()['Owner']);
    var ownerdoc;
    FirebaseFirestore.instance.collection('Staff').where(
        'Name', isEqualTo: owner).get().then((d2) => ownerdoc = d2.docs);
    String lastowner =
    await device.get().then((document) => document.data()['lastOwner']);
    String devicename =
    await device.get().then((document) => document.data()['DeviceName']);
    int timeused =
    await device.get().then((document) => document.data()['TimeUsed']);
    int total = await device
        .get()
        .then((document) => document.data()['TotalTimeUsed']);
    if (add) {
      request = "Requests: Request to remove by " + tempowner;
    }
    if (remove) {
      request = "Requests: Request to add by " + owner;
    }
    if (!staffExists) {
      showAlertDialog(context, 'Staff member not found',
          'You are not authorized to access this function');
    }
    else {
      if (!docExists) {
        showAlertDialog(context, "No Document found",
            "Please try to scan a different QR CODE");
      } else {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) =>
              ScannedDevice(
                qrCode: qrCode,
                devicename: devicename,
                device: device,
                request: request,
                lastowner: lastowner,
                timeused: timeused,
                remove: remove,
                add: add,
                tempowner: tempowner,
                owner: owner,
                location: locate,
                time: dt,
                lastlocation: lastlocation,
                total: total,
                currentdoc: currentdoc,
                ownerdoc: ownerdoc,
                tempownerdoc: tempownerdoc,
              ),
        ));
        device.update({'Location': location});
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
        device_scanned(qrCode);
      });
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }

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


}
