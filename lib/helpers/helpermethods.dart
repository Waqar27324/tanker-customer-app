import 'dart:convert';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:waterapp/datamodels/address.dart';
import 'package:waterapp/datamodels/directiondetail.dart';
import 'package:waterapp/datamodels/user.dart';
import 'package:waterapp/dataprovider/appdata.dart';
import 'package:waterapp/gloabal_variables.dart';
import 'package:waterapp/helpers/requestheper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';

class HelperMethods {
  static Future<String> findCordinateAdress(Position position, context) async {
    String placeAdress = 'nanana';
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      print(
          'yaha aya hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
      return placeAdress;
    }

    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude}, ${position.longitude}&key=$mapKey';
    var response = await RequestHelper.getRequest(url);
    if (response != 'failed') {
      placeAdress = response['results'][0]['formatted_address'];

      Address pickupAddress = new Address();

      pickupAddress.latitude = position.latitude;
      pickupAddress.longitude = position.longitude;
      pickupAddress.placeName = placeAdress;

      // ignore: unnecessary_statements
      Provider.of<AppData>(context, listen: false)
          .updatedAddress(pickupAddress);

      print(
          'here it comes yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy');
    } else {
      print(
          'here it comes nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn');
    }
    return placeAdress;
  }

  static Future<DirectionDetail> getDirectionDetail(
      LatLng startPostion, LatLng endPosition) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPostion.latitude},${startPostion.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey';
    var response = await RequestHelper.getRequest(url);
    if (response == 'failed') {
      return null;
    }

    DirectionDetail directionDetail = DirectionDetail();

    directionDetail.distanceText =
        response['routes'][0]['legs'][0]['distance']['text'];
    directionDetail.distanceValue =
        response['routes'][0]['legs'][0]['distance']['value'];

    directionDetail.durationText =
        response['routes'][0]['legs'][0]['duration']['text'];
    directionDetail.durationValue =
        response['routes'][0]['legs'][0]['duration']['value'];

    directionDetail.encodedPoints =
        response['routes'][0]['overview_polyline']['points'];

    return directionDetail;
  }

  static int estimateFares(DirectionDetail detail) {
    // per km 20,
    // per minute 10,
    // base fare 200;

    double basefare = 300;
    double waterfee = 300;
    double distancefare = (detail.distanceValue / 1000) * 30;
    //double timefare = (detail.durationValue / 60) * 5;

    double totalFare = basefare + waterfee + distancefare; // + timefare;

    return totalFare.truncate();
  }

  static Future<int> getCurrentUserInfo() async {
    currentUser = await FirebaseAuth.instance.currentUser();

    String userId = currentUser.uid;

    DatabaseReference dbRef =
        FirebaseDatabase.instance.reference().child('users/$userId');
    dbRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        currentUserInfo = User.fromSnapshot(snapshot);
        print(currentUserInfo.userName);
      }
    }).whenComplete(() {
      return 5;
    });
  }

  static double generateRandomNumber(int max) {
    var randomNumber = Random();
    int randInt = randomNumber.nextInt(max);
    return randInt.toDouble();
  }

  // for sending trip request to driver side using push notification cloud messaging api package

  static sendNotification(String token, context, String ride_id) async {
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverKey,
    };
    Map notificationMap = {
      'title': 'NEW TRIP REQUEST',
      'body': 'Destination, ${destination.placeName}',
    };
    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_id': ride_id,
    };
    Map bodyMap = {
      'notification': notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to': token,
    };

    var response = await http.post('https://fcm.googleapis.com/fcm/send',
        headers: headerMap, body: jsonEncode(bodyMap));

    print(response.body);
  }

// for notifications (on acception, rejection, cancellation or ending)

  static void scheduleAlarm(String title, String detail) async {
    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(seconds: 2));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      'Channel for Alarm notification',
      icon: 'codex_logo',
      sound: RawResourceAndroidNotificationSound('zero'),
      largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
      importance: Importance.max,
      playSound: true,
      channelShowBadge: true,
      showWhen: true,
      priority: Priority.high,
      ticker: 'test ticker',
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: 'zero.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(0, title, detail,
        scheduledNotificationDateTime, platformChannelSpecifics);
  }
}
