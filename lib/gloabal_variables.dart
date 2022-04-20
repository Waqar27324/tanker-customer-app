import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'datamodels/user.dart';

String mapKey = 'AIzaSyDpDpWKg5LdS3ylXRMM2gqx18_ZhpXYa9Q';
final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

FirebaseUser currentUser;

User currentUserInfo;

String imageurl;

String serverKey =
    'key=AAAAMDuuflo:APA91bFvX0_OPuX5cOveLo-ov8lbLN0vQtf_TucrlfAWIfzw3Dy1TII4zexm69i3-rCYlFZX2f_NTI6HXKEo4W4F2PeXaJCzsmXUu-ij_HKJdM6EaM5XsMy5jZsm7SrKthr-lg16NwRf';

List<Object> ratingsList = [];

var imgeUrl;
