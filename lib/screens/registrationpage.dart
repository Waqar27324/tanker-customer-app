import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waterapp/screens/brand_colors.dart';
import 'package:waterapp/screens/loginpage.dart';
import 'package:waterapp/screens/mainpage.dart';
import 'package:waterapp/widgets/progress_indicator.dart';
import 'package:waterapp/widgets/taxi_button.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Timer timer;

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void register() async {
    // code to show custom loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        'Registering You',
      ),
    );

    final FirebaseUser user = (await auth
            .createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
            .catchError((ex) {
      Navigator.pop(context);
      PlatformException pE = ex;
      showSnackBar(pE.message);
    }))
        .user;
    Navigator.pop(context);
    if (user != null) {
      await user.sendEmailVerification();

      timer = Timer.periodic(Duration(seconds: 5), (timer) {
        checkEmailVerified();
      });
    }
  }

  Future<void> checkEmailVerified() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await user.reload();

    if (user.isEmailVerified) {
      timer.cancel();

      DatabaseReference newuserRef =
          FirebaseDatabase.instance.reference().child('users/${user.uid}');
      print('ye user ki id..');
      print(user.uid);
      Map c = {
        '${user.uid}': true,
      };
      Map userMap = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'isFavourite': c,
      };
      newuserRef.set(userMap);
      print('ye agya aram se pe..');

      Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
    } else {
      showSnackBar(
          'Email is not verified till now please check your email address');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
              image: AssetImage("images/loginfour.jpg"), fit: BoxFit.cover)),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Image(
                    alignment: Alignment.center,
                    width: 150.0,
                    height: 100.0,
                    image: AssetImage('images/logostwo.png'),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Register as a Rider',
                    style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(23.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: fullNameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Enter your name',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Enter your email',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter your contact number',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          //style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Enter your password',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0),
                          ),
                        ),
                        SizedBox(
                          height: 60,
                        ),
                        TaxiButton(
                            title: 'REGISTER',
                            color: BrandColors.colorGreen,
                            onPressed: () async {
                              var connRes =
                                  await Connectivity().checkConnectivity();

                              if (connRes != ConnectivityResult.mobile &&
                                  connRes != ConnectivityResult.wifi) {
                                showSnackBar(
                                    'Please check your connection and try again');
                                return;
                              }

                              if (fullNameController.text.length <= 3) {
                                showSnackBar('Please provide your full name');
                                return;
                              }
                              if (phoneController.text.length < 10) {
                                showSnackBar(
                                    'Please provide a valid phone number');
                                return;
                              }
                              if (!emailController.text.contains('@')) {
                                showSnackBar('Please provide a valid email');
                                return;
                              }
                              if (passwordController.text.length < 8) {
                                showSnackBar(
                                    'Please provide atleast 8 characters password ');
                                return;
                              }

                              register();
                            }),
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, LoginPage.id, (route) => false);
                    },
                    child: Text(
                      'Already have account, login here',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
