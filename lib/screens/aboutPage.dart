import 'dart:ui';

import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool checkBoxValueOne = false;
  bool checkBoxValueTwo = false;
  bool checkBoxValueThree = false;

  String dropdownValue = 'Why are you deleting your Account?';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFDBE0F8),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: Row(
                  children: [
                    RawMaterialButton(
                      elevation: 0,
                      fillColor: Colors.white,
                      child: Icon(
                        Icons.chevron_left_outlined,
                        size: 40.0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      constraints: BoxConstraints.tightFor(
                        height: 50,
                        width: 50,
                      ),
                      shape: CircleBorder(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                          ),
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                    Image.asset(
                      "images/logostwo.png",
                      height: 35,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(5.0, 20.0, 20.0, 0.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Column(
                                      //mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "OUR MAIN SERVICES",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xff4A69FF)),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Tanker supply to consumers:",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xff4A69FF)),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Providing water tanker with the live location, distance and time to consumers at their door step is our primary goal and service. The live tracking feature will ensure the consumer that their tanker is arriving.',
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "Water related other services:",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xff4A69FF)),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'We are also providing a platform for other water related services like drinking water sell/purchase, water boring service (repairing or new) for old and new houses and water testing services.',
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "WHERE ARE WE LOCATED AND PROVIDING OUR SERVICES",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xff4A69FF)),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'Currently, We do not have office yet and but after the application is deployed we will be opening our main branches in rawalpindi and islamabad. We are providing these services in rawalpindi, islamabad and karachi. ',
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "CONTACT US ON",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xff4A69FF)),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'Email:',
                                          textAlign: TextAlign.start,
                                        ),
                                        SizedBox(
                                          height: 7,
                                        ),
                                        Text(
                                          'Tankersoul@gmail.com',
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Phone:',
                                          textAlign: TextAlign.start,
                                        ),
                                        SizedBox(
                                          height: 7,
                                        ),
                                        Text(
                                          '051-3322523',
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 40,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
