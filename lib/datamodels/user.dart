import 'package:firebase_database/firebase_database.dart';

class User {
  String userName;
  String email;
  String phone;
  String id;

  User({this.userName, this.email, this.phone, this.id});

  User.fromSnapshot(DataSnapshot snapshot) {
    userName = snapshot.value['fullname'];
    id = snapshot.key;
    email = snapshot.value['email'];
    phone = snapshot.value['phone'];
  }
}
