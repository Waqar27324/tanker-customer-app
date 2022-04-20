import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

const kTextColor = Color(0xFF535353);
const kTextLightColor = Color(0xFFACACAC);

const kDefaultPaddin = 20.0;

FirebaseUser currentUsers;

bool favChanged = false;

bool deleteHuwa = false;

String poppedData = '';

String newLocation = '';

String backFromLocation = '';

String afterAddingNewProduct = '';

bool isFavourits = false;
