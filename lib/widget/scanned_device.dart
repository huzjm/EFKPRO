import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocation/geolocation.dart';
import 'build_map.dart';
import '../main.dart';

class ScannedDevice extends StatefulWidget {
  final String qrCode;
  String devicename;
  bool remove;
  bool add;
  String owner;
  String tempowner;
  String lastowner;
  int total;
  int timeused;
  String request;
   GeoPoint location;
  final DocumentReference device;
   DateTime time;
   GeoPoint lastlocation;
   var currentdoc;
   var ownerdoc;
   var tempownerdoc;

  ScannedDevice(
      {this.qrCode,this.devicename,this.remove,this.add,this.owner,this.tempowner,this.lastowner,this.timeused,this.request,this.device,this.location,this.time,this.lastlocation,this.total,this.currentdoc,this.ownerdoc,this.tempownerdoc});

  @override
  State<StatefulWidget> createState() => _ScannedDeviceState(
      this.qrCode,this.devicename,this.remove,this.add,this.owner,this.tempowner,this.lastowner,this.timeused,this.request,this.device,this.location,this.time,this.lastlocation,this.total,this.currentdoc,this.ownerdoc,this.tempownerdoc);
}

class _ScannedDeviceState extends State<ScannedDevice> {
  final String qrCode;
  String devicename;
  bool remove;
  bool add;
  String owner;
  String tempowner;
  String lastowner;
  int timeused;
  int total;
  String request;
  final DocumentReference device;
   GeoPoint location;
   DateTime time;
   GeoPoint lastlocation;
   var currentdoc;
   var ownerdoc;
   var tempownerdoc;

  _ScannedDeviceState(
      this.qrCode,this.devicename,this.remove,this.add,this.owner,this.tempowner,this.lastowner,this.timeused,this.request,this.device,this.location,this.time,this.lastlocation,this.total,this.currentdoc,this.ownerdoc,this.tempownerdoc,
      );

  @override
  final user = FirebaseAuth.instance.currentUser;
  Timestamp ts = Timestamp.fromDate(DateTime.now());



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


              Spacer(),
              Text(
                "Device Name: "+devicename,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Owner: "+owner ,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Previous Owner: "+lastowner ,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Text(
                request,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Text(
                "Time Used by the Current Owner: "+timeused.toString()+  " hours",
                style: TextStyle(
                  fontSize:14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Time Used in Total: "+total.toString()+  " hours",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Text(
                "Last Updated: "+time.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,children:[Spacer(),Spacer(),
                Spacer(),ElevatedButton(onPressed: adddevice, child: Text('Add Device')),
              Spacer(),

              ElevatedButton(
                  onPressed: removedevice, child: Text('Remove Device')),Spacer(),Spacer(),Spacer(),]),
              ElevatedButton(
                  onPressed: clearrequest, child: Text('Clear Requests')),


              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[Spacer(),Spacer(),ElevatedButton(
                  onPressed: incrementtime, child: Text('Increment Time Use')),Spacer(),

              ElevatedButton(onPressed: decrementtime, child: Text('Decrement Time Use')),Spacer(),Spacer(),]),
              ElevatedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    buildMap(latitude:lastlocation.latitude,longitude:lastlocation.longitude),
              )), child: Text('Last Known Location')),
              Spacer(),
              Spacer(),
              Spacer(),
            ],
          ),

        ),
      );
 void incrementtime() async{

   if (user.displayName == owner) {
     device.update({'TimeUsed': timeused+1});
     device.update({'TotalTimeUsed':total+1});
     if (!mounted) return;
      setState(() {
        this.timeused=timeused+1;
        this.total=total+1;
      });

   } else {
     showAlertDialog(context, "Error",
         "You do not own the device and do not have the permission to increment time usage");
   }
 }
  void decrementtime() async{

    if (user.displayName == owner) {
      device.update({'TimeUsed': timeused-1});
      device.update({'TotalTimeUsed':total-1});
      if (!mounted) return;
      setState(() {
        this.timeused=timeused-1;
        this.total=total-1;
      });

    } else {
      showAlertDialog(context, "Error",
          "You do not own the device and do not have the permission to decrement time usage");
    }
  }

  void adddevice() async {

    if (user.displayName != owner) {
      if (remove) {
        device.update({'Date':Timestamp.fromDate(DateTime.now())});
        device.update({'lastOwner':owner});
        device.update({'tempOwner':null});
        device.update({'Location':location});
        device.update({'Owner': user.displayName});
        device.update({'remove': false});
        device.update({'add': false});
        device.update({'TimeUsed':0});
        currentdoc[0].reference.update({"Devices":FieldValue.arrayUnion([qrCode])});
        ownerdoc[0].reference.update({"Devices":FieldValue.arrayRemove([qrCode])});


        if (!mounted) return;
        setState(() {
          lastowner=owner;
          tempowner=null;
          owner = user.displayName;
          request="Requests: None";
          timeused=0;
          remove = false;
          add=false;
          time = DateTime.now();
          lastlocation=location;
        });

        showAlertDialog(context, "Device Added Successfully ",
            user.displayName + " is now the new owner");
      } else if ((!remove) && (!add)) {
        device.update({'add': true});
        device.update({'tempOwner': user.displayName});
        if (!mounted) return;
        setState(() {
          add = true;
          tempowner = user.displayName;
          request = "Requests: Request to remove by "+tempowner;

        });

        showAlertDialog(context, "Awaiting Previous Owner's Confirmation",
            user.displayName + " is now the temporary owner");
      } else if ((!remove) && (add)) {

        showAlertDialog(context, "Add Request Updated",
            "The new temporary owner is  " + user.displayName);
        device.update({'tempOwner': user.displayName});
        if (!mounted) return;
        setState(() {
          tempowner=user.displayName;
          request = "Requests: Request to remove by "+tempowner;

        });
      }
    } else {
      showAlertDialog(context, "Error", "You are already the owner");
    }
  }

  void removedevice() async {

    if (user.displayName == owner) {
      if (add) {
        device.update({'Date':ts});
        device.update({'Location':location});
        device.update({'Owner': tempowner});
        device.update({'remove': false});
        device.update({'add': false});
        device.update({'TimeUsed':0});
        device.update({'lastOwner':user.displayName});
        device.update({'tempOwner':null});
        currentdoc[0].reference.update({"Devices":FieldValue.arrayUnion([qrCode])});
        tempownerdoc[0].reference.update({"Devices":FieldValue.arrayUnion([qrCode])});

        if (!mounted) return;
        setState(() {
          lastowner=user.displayName;
          owner=tempowner;
          tempowner=null;
          timeused=0;
          request="Requests: None";
          remove = false;
          add=false;
          time = DateTime.now();
          lastlocation=location;

        });

        showAlertDialog(context, "Device Removed Successfully",
            user.displayName + " is now the previous owner");
      } else if ((!remove) && (!add)) {
        device.update({'remove': true});


        if (!mounted) return;
        setState(() {

          remove=true;

          request = "Requests: Request to add new owner by "+user.displayName;

        });
        showAlertDialog(context, "Awaiting New Owner's Confirmation",
            user.displayName + " has confirmed device removal");
      } else if ((remove) && (!add)) {
        showAlertDialog(context, "Error",
            "Your device is already in queue to change owners ");
      }
    } else {
      showAlertDialog(context, "Error", "You do not own the device");
    }
  }

  void clearrequest() async {

    if (user.displayName == owner) {
      this.device.update({'remove': false});
      this.device.update({'add': false});

      if (!mounted) return;
      setState(() {
      remove=false;
      add=false;
       request="Requests: None";

      });
    } else {
      showAlertDialog(context, "Error",
          "You do not own the device and do not have the permission to clear requests");
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
}
