import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grafpix/icons.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:waterapp/datamodels/address.dart';
import 'package:waterapp/datamodels/directiondetail.dart';
import 'package:waterapp/datamodels/nearbydrivers.dart';
import 'package:waterapp/dataprovider/appdata.dart';
import 'package:waterapp/helpers/firehelper.dart';
import 'package:waterapp/helpers/helpermethods.dart';
import 'package:waterapp/helpers/mapkithelper.dart';
import 'package:waterapp/lib2/home_screens.dart';
import 'package:waterapp/rideVariables.dart';
import 'package:waterapp/screens/aboutPage.dart';
import 'package:waterapp/screens/brand_colors.dart';
import 'package:waterapp/screens/loginpage.dart';
import 'package:waterapp/screens/profilePage.dart';
import 'package:waterapp/screens/searchpage.dart';
import 'package:waterapp/screens/termsConditions.dart';
import 'package:waterapp/widgets/CollectPaymentDialog.dart';
import 'package:waterapp/widgets/brand_divider.dart';
import 'dart:io';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:waterapp/widgets/no_driver_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:waterapp/widgets/progress_indicator.dart';
import 'package:waterapp/widgets/rate_review.dart';
import 'package:waterapp/widgets/taxi_button.dart';

import '../gloabal_variables.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);
  static const String id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  double mapBottomPadding = 0;

  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;

  double rideDetailsheetHeight = 0; // (Platform.isIOS) ? 235 : 260;
  double requestingSheetHeight = 0; // (Platform.isIOS) ? 195 : 220;
  double tripSheetHeight = 0; // (Platform.isIOS) ? 300 : 275;

  var geolocator = Geolocator();
  Position currentPosition;

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};

  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  DirectionDetail tripDirectionDetails;

  bool drawerCanOpen = true;

  DatabaseReference rideRef;

  bool nearbyDriverKeyisLoaded = false;

  BitmapDescriptor nearbyIcon;

  List<NearbyDriver> availableDrivers;

  String appState = 'NORMAL';

  StreamSubscription<Event> rideSubscription;

  bool isRequestingLocationDetail = false;

  BitmapDescriptor movingMarkerIcon;

  bool firstTime = true;
  bool firstTimeToDestination = true;

// For first time getting current position and setting it on map and the ON the geofire for nearby drivers

  void setupPositionLocator() async {
    Position position = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cP = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cP));

    startGeofireListner();

    String address = await HelperMethods.findCordinateAdress(position, context);
    /*  print(address);
    print('hello');
    print(position.latitude);
    print(position.longitude);
  */
  }

// For showing ride detail sheet and hiding search sheet like when get backed from SEARCHPAGE so then called
// And then getting Direction detailes

  void showDetail() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickupLatlng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatlng = LatLng(destination.latitude, destination.longitude);

    // await getDirection(pickupLatlng, destinationLatlng);

    setState(() {
      searchSheetHeight = 0;
      rideDetailsheetHeight = (Platform.isAndroid) ? 235 : 260;
      mapBottomPadding = (Platform.isAndroid) ? 240 : 230;
      drawerCanOpen = false;
    });
  }

// For showing the request bottom sheet when customer pressed on request a driver button and then CreateRideRequest func
// called for creating new ride on database...

  void showRequestSheet() async {
    setState(() {
      rideDetailsheetHeight = 0;
      requestingSheetHeight = (Platform.isAndroid) ? 195 : 220;
      mapBottomPadding = (Platform.isAndroid) ? 200 : 190;

      drawerCanOpen = true;
    });
    createRideRequest();
  }

// Showing trip started bottom sheet and hiding the requestSheet...

  showTripSheet() {
    setState(() {
      requestingSheetHeight = 0;
      tripSheetHeight = (Platform.isAndroid) ? 285 : 300;
      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;

      drawerCanOpen = true;
    });
  }

// Creating Drivers tanker icon marker and showing them on map when it calls from build method...

  void createMarker() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration,
              (Platform.isAndroid)
                  ? 'images/delivery_tanker_onmap.png'
                  : 'images/car_ios.png')
          .then((icon) {
        nearbyIcon = icon;
      });
    }
  }

  void createMovingMarker() {
    if (movingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration,
              (Platform.isAndroid)
                  ? 'images/delivery_tanker_onmap.png'
                  : 'images/car_ios.png')
          .then((icon) {
        movingMarkerIcon = icon;
      });
    }
  }

  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
    currentUser = null;
    Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
  }

// for pofile page editing

  void openProfilePage() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(),
        ));
  }

// for initial fetching data

  Future<int> fetchPriviousData() async {
    FirebaseUser userAuth = await FirebaseAuth.instance.currentUser();

    if (currentUser != null) {
      StorageReference profileRef =
          FirebaseStorage.instance.ref().child('profiles/${currentUser.uid}');

      String url = (await profileRef.getDownloadURL()).toString();

      setState(() {
        imageurl = url;
        imgeUrl = url;
      });

      DatabaseReference usersAddresses = FirebaseDatabase.instance
          .reference()
          .child('users/${currentUser.uid}');

      usersAddresses
          .child('officeAddress')
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot != null) {
          Address officeAdd = new Address();

          officeAdd.placeId = snapshot.value['placeId'];
          officeAdd.placeName = snapshot.value['placeName'];
          officeAdd.latitude = double.parse(snapshot.value['latitude']);
          officeAdd.longitude = double.parse(snapshot.value['longitude']);

          Provider.of<AppData>(context, listen: false)
              .updateOfficeAddress(officeAdd);
        }
      });
      usersAddresses.child('homeAddress').once().then((DataSnapshot snapshot) {
        if (snapshot != null) {
          Address homeAdd = new Address();

          homeAdd.placeId = snapshot.value['placeId'];
          homeAdd.placeName = snapshot.value['placeName'];
          homeAdd.latitude =
              double.parse(snapshot.value['latitude'].toString());
          homeAdd.longitude =
              double.parse(snapshot.value['longitude'].toString());

          Provider.of<AppData>(context, listen: false)
              .updateHomeAddress(homeAdd);
          print(homeAdd.placeName);
          print(homeAdd.placeName +
              "main wala after fetching wala after button pressed");
        }
      }).whenComplete(() {
        return 10;
      });
    }
  }

  void forInitCalls() async {
    var result = await HelperMethods.getCurrentUserInfo();

    setState(() {});
  }

  void forOtherData() async {
    var result = await fetchPriviousData();

    setState(() {});
  }
// init method used for First time HelperMethods.GetCurrentUserInfo method...

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    forInitCalls();
    //HelperMethods.getCurrentUserInfo();
    forOtherData();
  }

  @override
  Widget build(BuildContext context) {
    createMarker();

    return Scaffold(
      key: scaffoldKey,
      drawer: //  drawer
          Container(
        width: (MediaQuery.of(context).orientation == Orientation.portrait)
            ? 250
            : 400,
        color: Colors.white,

        // Drawer code...

        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Container(
                color: Colors.white,
                height: 160,
                child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //Image.asset('images/profiile.png'),
                          Container(
                              width: 100.0,
                              height: 100.0,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                  image: (imageurl != null)
                                      ? NetworkImage(imageurl)
                                      : ExactAssetImage('images/profiile.png'),
                                  fit: BoxFit.cover,
                                ),
                              )),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                (currentUserInfo != null)
                                    ? currentUserInfo.userName
                                    : 'Waqar',
                                overflow: TextOverflow.fade,
                                maxLines: 2,
                                softWrap: false,
                                style: TextStyle(
                                    fontSize: 20, fontFamily: 'Brand-Bold'),
                              ),
                              FlatButton(
                                  onPressed: openProfilePage,
                                  child: Expanded(
                                    child: Text(
                                      'Edit Profile',
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                  ))
                            ],
                          )
                        ],
                      ),
                    )),
              ),
              BrandDivider(),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(OMIcons.cardGiftcard),
                title: Text(
                  'Free Trips',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  customLaunch('tel:$driverPhoneNumber');
                },
              ),
              BrandDivider(),
              ListTile(
                leading: Icon(OMIcons.creditCard),
                title: Text(
                  'Payments',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              BrandDivider(),
              /*
              ListTile(
                leading: Icon(OMIcons.history),
                title: Text(
                  'Trips History',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              */
              BrandDivider(),
              ListTile(
                leading: Icon(OMIcons.history),
                title: Text(
                  'Sell/Purchae App',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              BrandDivider(),
              ListTile(
                leading: Icon(OMIcons.contactSupport),
                title: Expanded(
                  child: Text(
                    'Terms and conditions',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TermsConditions(),
                      ));
                },
              ),
              BrandDivider(),
              ListTile(
                leading: Icon(OMIcons.info),
                title: Expanded(
                  child: Text(
                    'About',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutPage(),
                      ));
                },
              ),
              BrandDivider(),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: logoutUser,
              ),
            ],
          ),
        ),
      ),

      // body

      body: Stack(
        children: [
          // Google Map and in the end SetupPositionLocator func called for forst time current location showing on map

          GoogleMap(
            //padding: EdgeInsets.only(bottom: mapBottomPadding),
            padding: EdgeInsets.only(bottom: mapBottomPadding, top: 32),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: googlePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: _polylines,
            markers: _markers,
            circles: _circles,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setState(() {
                mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
              });

              setupPositionLocator();
            },
          ),
//////////////////////// drawer menu button

          Positioned(
              left: 20,
              top: 44,
              child: GestureDetector(
                onTap: () {
                  if (drawerCanOpen) {
                    scaffoldKey.currentState.openDrawer();
                  } else {
                    resetApp();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,
                            spreadRadius: 0.5,
                            offset: Offset(
                              0.7,
                              0.7,
                            ))
                      ]),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(
                      (drawerCanOpen) ? Icons.menu : Icons.arrow_back,
                      color: Colors.black87,
                    ),
                  ),
                ),
              )),

          //////////////////// search sheet container

          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: AnimatedSize(
                  vsync: this,
                  duration: Duration(milliseconds: 150),
                  curve: Curves.easeIn,
                  child: Container(
                    height: searchSheetHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15.0,
                            spreadRadius: 15.0,
                            offset: Offset(
                              0.7,
                              0.7,
                            ))
                      ],
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Nice to see you',
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              'Where are you going?',
                              style: TextStyle(
                                  fontFamily: 'Brand-Bold', fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () async {
                                var response = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SearchPage(index: 1),
                                    ));
                                if (response == 'getDirection') {
                                  print(
                                      'yaha ayega wapsi meeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');
                                  print(Provider.of<AppData>(context,
                                          listen: false)
                                      .destinationAddress
                                      .placeName);
                                  showDetail();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5.0,
                                        spreadRadius: 0.5,
                                        offset: Offset(0.7, 0.7),
                                      ),
                                    ]),
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search,
                                        color: Colors.blueAccent,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('Search Destination'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 22,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.home,
                                  color: BrandColors.colorDimText,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                GestureDetector(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Add Home'),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        'Your residencial address',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: BrandColors.colorDimText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SearchPage(index: 2),
                                        ));
                                  },
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            BrandDivider(),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.work,
                                  color: BrandColors.colorDimText,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                GestureDetector(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Add Work'),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        'Your office address',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: BrandColors.colorDimText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SearchPage(index: 3),
                                        ));
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )),

          // ride sheet and charges sheet

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: Container(
                  height: rideDetailsheetHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 15.0,
                          offset: Offset(
                            0.7,
                            0.7,
                          ))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        Container(
                          color: BrandColors.colorAccent1,
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Image.asset(
                                  'images/logosfour.png',
                                  height: 70,
                                  width: 70,
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tanker',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Brand-Bold'),
                                    ),
                                    Text(
                                      (tripDirectionDetails != null)
                                          ? tripDirectionDetails.distanceText
                                          : '1000 litre ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: BrandColors.colorTextLight),
                                    ),
                                  ],
                                ),
                                Expanded(child: Container()),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (tripDirectionDetails != null)
                                          ? '\$${HelperMethods.estimateFares(tripDirectionDetails)}'
                                          : 'Rs. 600',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Brand-Bold'),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '(+ Fuel charges)',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: BrandColors.colorTextLight),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                PixIcon.fa_money_bill_wave,
                                size: 18,
                                color: BrandColors.colorTextLight,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Text('Cash'),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: BrandColors.colorTextLight,
                              ),
                              SizedBox(
                                width: 80,
                              ),
                              Expanded(child: Container()),
                              Text(
                                'Rs. 20/Km',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: BrandColors.colorTextLight),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: TaxiButton(
                            title: 'Request Tanker',
                            color: BrandColors.colorGreen,
                            onPressed: () {
                              setState(() {
                                appState = 'REQUESTING';
                              });
                              showRequestSheet();

                              availableDrivers = FireHelper.nearbyDriverList;

                              findDriver();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          ///requesting for driver

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: requestingSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        spreadRadius: 15.0,
                        offset: Offset(
                          0.7,
                          0.7,
                        ))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextLiquidFill(
                          text: 'Requeting a Ride...',
                          waveColor: BrandColors.colorTextSemiLight,
                          boxBackgroundColor: Colors.white,
                          textStyle: TextStyle(
                            fontSize: 22.0,
                            fontFamily: 'Brand-Bold',
                            color: BrandColors.colorText,
                          ),
                          boxHeight: 40.0,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          cancelRequest();
                          resetApp();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  width: 1.0,
                                  color: BrandColors.colorLightGrayFair)),
                          child: Icon(
                            Icons.close,
                            size: 25,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          // trip detailes sheet when trip starts

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: SingleChildScrollView(
                child: Container(
                  height: tripSheetHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 15.0,
                          offset: Offset(
                            0.7,
                            0.7,
                          ))
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tripStatusDisplay,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Brand-Bold', fontSize: 18),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        BrandDivider(),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          driverCarDetails,
                          style: TextStyle(color: BrandColors.colorTextLight),
                        ),
                        Text(
                          driverFullName,
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        BrandDivider(),
                        SizedBox(
                          height: 17,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                customLaunch('tel:$driverPhoneNumber');
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular((25))),
                                      border: Border.all(
                                          width: 1.0,
                                          color: BrandColors.colorTextLight),
                                    ),
                                    child: Icon(Icons.call),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Call'),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular((25))),
                                      border: Border.all(
                                          width: 1.0,
                                          color: BrandColors.colorTextLight),
                                    ),
                                    child: Icon(Icons.list),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Details'),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await rideRef.child('status').set('cancelled');

                                rideRef.onDisconnect();

                                //ye extra ha neche wala

                                //rideRef.remove();

                                //rideRef = null;
                                rideSubscription.cancel();
                                rideSubscription = null;
                                HelperMethods.scheduleAlarm('Tanker Soul',
                                    'Your order trip has been Cancelled');
                                resetApp();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular((25))),
                                      border: Border.all(
                                          width: 1.0,
                                          color: BrandColors.colorTextLight),
                                    ),
                                    child: Icon(OMIcons.clear),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Cancel'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

// resetting the app by clicking back button
  resetApp() {
    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _markers.clear();
      _circles.clear();
      rideDetailsheetHeight = 0;

      tripSheetHeight = 0;

      requestingSheetHeight = 0;
      searchSheetHeight = (Platform.isIOS) ? 300 : 275;
      mapBottomPadding = (Platform.isIOS) ? 270 : 280;
      drawerCanOpen = true;

      status = '';
      driverFullName = '';
      driverPhoneNumber = '';
      driverCarDetails = '';
      tripStatusDisplay = 'Driver is Arriving';

      firstTime = true;
      firstTimeToDestination = true;
    });
    setupPositionLocator();
  }

// geofire for nearby drivers location

  void startGeofireListner() {
    Geofire.initialize('driversAvailable');

    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 15)
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];

            FireHelper.nearbyDriverList.add(nearbyDriver);

            if (nearbyDriverKeyisLoaded) {
              updateDriversonMap();
            }

            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDriversonMap();

            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];

            FireHelper.updatenearbyLocation(nearbyDriver);
            updateDriversonMap();

            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            updateDriversonMap();
            nearbyDriverKeyisLoaded = true;

            break;
        }
      }
    });
  }

  // updating drivers on map ... showing markers on drivers location

  void updateDriversonMap() {
    setState(() {
      _markers.clear();
    });
    Set<Marker> tempMarker = Set<Marker>();

    for (NearbyDriver driver in FireHelper.nearbyDriverList) {
      LatLng driverPosition = LatLng(driver.latitude, driver.longitude);

      Marker thisMarker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverPosition,
        icon: nearbyIcon,
        rotation: HelperMethods.generateRandomNumber(360),
      );
      tempMarker.add(thisMarker);
    }
    setState(() {
      _markers = tempMarker;
    });
  }

// For drawing new trip polylines,markers etc on map

  Future<void> getDirection(var pickupLatlng, var destinationLatlng) async {
    // var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    // var destination =
    //    Provider.of<AppData>(context, listen: false).destinationAddress;
    //  var pickupLatlng = LatLng(pickup.latitude, pickup.longitude);
    //  var destinationLatlng = LatLng(destination.latitude, destination.longitude);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog('Loading...'),
    );

    var thisDetail =
        await HelperMethods.getDirectionDetail(pickupLatlng, destinationLatlng);

    setState(() {
      tripDirectionDetails = thisDetail;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetail.encodedPoints);

    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 273),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polylines.add(polyline);
    });

    // make polyline to fit into map

    LatLngBounds bounds;

    if (pickupLatlng.latitude > destinationLatlng.latitude &&
        pickupLatlng.longitude > destinationLatlng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatlng, northeast: pickupLatlng);
    } else if (pickupLatlng.longitude > destinationLatlng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatlng.latitude, destinationLatlng.longitude),
          northeast:
              LatLng(destinationLatlng.latitude, pickupLatlng.longitude));
    } else if (pickupLatlng.latitude > destinationLatlng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatlng.latitude, pickupLatlng.longitude),
          northeast:
              LatLng(pickupLatlng.latitude, destinationLatlng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatlng, northeast: destinationLatlng);
    }

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickupLatlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      // infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Location'),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      // infoWindow: InfoWindow(title: pickup.placeName, snippet: 'Destination'),
    );
    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickupLatlng,
      fillColor: BrandColors.colorGreen,
    );
    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatlng,
      fillColor: BrandColors.colorAccentPurple,
    );
    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

// Creating new ride on database and applying onvalueChange stream on that

  void createRideRequest() {
    rideRef = FirebaseDatabase.instance.reference().child('rideRequest').push();

    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    Map pickupMap = {
      'latitude': pickup.latitude.toString(),
      'longitude': pickup.longitude.toString(),
    };

    Map destinationMap = {
      'latitude': destination.latitude.toString(),
      'longitude': destination.longitude.toString(),
    };

    Map rideMap = {
      'created_at': DateTime.now().toString(),
      'rider_name': currentUserInfo.userName,
      'rider_phone': currentUserInfo.phone,
      'pickup_address': pickup.placeName,
      'destination_address': destination.placeName,
      'location': pickupMap,
      'destination': destinationMap,
      'payment_method': 'cash',
      'driver_id': 'waiting',
    };

    rideRef.set(rideMap);

    rideSubscription = rideRef.onValue.listen((event) async {
      // check for null snapshot

      if (event.snapshot.value == null) {
        return;
      }

      // getting Driver and Tanker details for displaying to customer when ride starts below 3 iF's

      if (event.snapshot.value['car_details'] != null) {
        setState(() {
          driverCarDetails = event.snapshot.value['car_details'].toString();
        });
      }
      if (event.snapshot.value['driver_name'] != null) {
        setState(() {
          driverFullName = event.snapshot.value['driver_name'].toString();
        });
      }
      if (event.snapshot.value['driver_phone'] != null) {
        setState(() {
          driverPhoneNumber = event.snapshot.value['driver_phone'].toString();
        });
      }

      // for drivers location getting

      if (event.snapshot.value['driver_location'] != null) {
        double driverLat = double.parse(
            event.snapshot.value['driver_location']['latitude'].toString());
        double driverLng = double.parse(
            event.snapshot.value['driver_location']['longitude'].toString());

        LatLng driverLocation = LatLng(driverLat, driverLng);

        //if (status == 'accepted') {
        //showPolylinesTowardPickup(driverLocation);
        //updateToPickup(driverLocation);
        //}
        if (event.snapshot.value['status'] != null) {
          setState(() {
            status = event.snapshot.value['status'].toString();
          });
          //ye upar wala setstate wapis khatam krna ha ok
          //status = event.snapshot.value['status'].toString();
        }

        if (status == 'accepted') {
          HelperMethods.scheduleAlarm(
              'Tanker Soul', 'Your order trip has been started');
          showTripSheet();
          Geofire.stopListener();
          removeGeofireMarkers();
        }

        if (status == 'ontrip') {
          showPolylinesTowardDestination(driverLocation);
          updateToDestination(driverLocation);
          //setState(() {});
        }
        //else if (status == 'arrived') {
        //setState(() {
        //tripStatusDisplay = 'Driver has Arrived';
        //});
        //}
      }

      // below 2 if's are for checing and then showing trip sheet on home screen...

      // When trip ends then show cash dialog box

      if (status == 'ended') {
        if (event.snapshot.value['fares'] != null) {
          int fares = int.parse(event.snapshot.value['fares'].toString());
          var response = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => CollectPayment(
                    paymentMethod: 'cash',
                    fares: fares,
                  ));

          if (response == 'close') {
            var resp = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => RateReview());
            if (resp != null) {
              print('yaha response aya ha as a map feedback or ratings ka');
              print(resp);
              print('${ratingsList[0]}');
              print('${ratingsList[1]}');
              Map map = {
                'rating': (ratingsList[0] != null) ? ratingsList[0] : '',
                'feedback': (ratingsList[1] != null) ? ratingsList[1] : '',
              };
              rideRef.child('rateAndReview').set(map);
            }
            HelperMethods.scheduleAlarm(
                'Tanker Soul', 'Your order trip has been ended successfully');

            rideRef.onDisconnect();
            rideRef = null;
            rideSubscription.cancel();
            rideSubscription = null;
            resetApp();
          }
        }
      }

      // When trip is cancelled by driver then show a popup with message + end everything

      if (status == 'cancelled') {
        HelperMethods.scheduleAlarm(
            'Tanker Soul', 'Your order trip has been cancelled by driver');
        ShowcancellationDialog();
        rideRef.onDisconnect();
        rideRef = null;
        rideSubscription.cancel();
        rideSubscription = null;
        resetApp();
      }
    });
  }

  // removing geofire markers when trip started means other driver etc markers

  void removeGeofireMarkers() {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value.contains('driver'));
    });
  }

// Getting the arrival time duration of driver to pickup location...

  void updateToPickup(LatLng driverLocation) async {
    if (!isRequestingLocationDetail) {
      isRequestingLocationDetail = true;

      var positionLatLng =
          LatLng(currentPosition.latitude, currentPosition.longitude);

      var thisDetail = await HelperMethods.getDirectionDetail(
          driverLocation, positionLatLng);

      if (thisDetail == null) {
        return;
      }

      setState(() {
        tripStatusDisplay = 'Driver is Arriving - ${thisDetail.durationText}';
      });

      // yaha pe driver ke new markes mean ke updated walay map pe show kranay hain...jub jub location update hogi...
      //   <-----start----->

      LatLng oldPosition = LatLng(0, 0);

      LatLng pos = LatLng(driverLocation.latitude, driverLocation.longitude);

      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude,
          oldPosition.longitude, pos.latitude, pos.longitude);

      Marker movingMarker = Marker(
        markerId: MarkerId('moving'),
        position: pos,
        icon: movingMarkerIcon,
        rotation: rotation,
        infoWindow: InfoWindow(title: 'Current Location'),
      );

      setState(() {
        CameraPosition cP = new CameraPosition(target: pos, zoom: 17);
        mapController.animateCamera(CameraUpdate.newCameraPosition(cP));

        _markers.removeWhere((marker) => marker.markerId.value == 'moving');
        _markers.add(movingMarker);
      });

      oldPosition = pos;

// yaha tak ha ye agar baad may change karna para to krenge... <-----end----->

      isRequestingLocationDetail = false;
    }
  }

  // Getting the arrival time duration of driver to destination location...

  void updateToDestination(LatLng driverLocation) async {
    if (!isRequestingLocationDetail) {
      isRequestingLocationDetail = true;

      var destination =
          Provider.of<AppData>(context, listen: false).destinationAddress;

      var destinationLatLng =
          LatLng(destination.latitude, destination.longitude);

      var thisDetail = await HelperMethods.getDirectionDetail(
          driverLocation, destinationLatLng);

      if (thisDetail == null) {
        return;
      }

      setState(() {
        tripStatusDisplay =
            'Driving to Destination - ${thisDetail.durationText}';
      });

      // yaha pe driver ke new markers mean ke updated walay map pe show kranay hain...jub jub location update hogi...
      //   <-----start----->

      LatLng oldPosition = LatLng(0, 0);

      LatLng pos = LatLng(driverLocation.latitude, driverLocation.longitude);

      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude,
          oldPosition.longitude, pos.latitude, pos.longitude);

      Marker movingMarker = Marker(
        markerId: MarkerId('moving'),
        position: pos,
        icon: movingMarkerIcon,
        rotation: rotation,
        infoWindow: InfoWindow(title: 'Current Location'),
      );

      setState(() {
        CameraPosition cP = new CameraPosition(target: pos, zoom: 17);
        mapController.animateCamera(CameraUpdate.newCameraPosition(cP));

        _markers.removeWhere((marker) => marker.markerId.value == 'moving');
        _markers.add(movingMarker);
      });

      oldPosition = pos;

// yaha tak ha ye agar baad may change karna para to krenge... <-----end----->

      isRequestingLocationDetail = false;
    }
  }

  // For cancelling the trip and setting the state to 'NORMAL'

  void cancelRequest() {
    rideRef.remove();

    setState(() {
      appState = 'NORMAL';
    });
  }

  // below 2 methods are for No driver available case and No driver found dialog box.

  void noDriverFound() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => NoDriverDialog(),
    );
  }

  void findDriver() {
    if (availableDrivers.length == 0) {
      resetApp();
      cancelRequest();
      noDriverFound();
      return;
    }
    var driver = availableDrivers[0];
    notifyDrivers(driver);

    availableDrivers.removeAt(0);

    print('Yaha ha driver ki key:  ${driver.key}');
  }

// sending the http request ti drivers app with token and ride-id

  void notifyDrivers(NearbyDriver driver) {
    DatabaseReference driverTripRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${driver.key}/newtrips');
    driverTripRef.set(rideRef.key);

    DatabaseReference tokenRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${driver.key}/token');

    tokenRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        String token = snapshot.value.toString();
        // clling the helper method to finally send notification of new trip to driver
        HelperMethods.sendNotification(token, context, rideRef.key);
      } else {
        return;
      }

      const oneSecTick = Duration(seconds: 1);

      var timer = Timer.periodic(oneSecTick, (timer) {
        // checking if rider/customer have clicked cancel button while requesting driver

        if (appState != 'REQUESTING') {
          driverTripRef.set('cancelled');
          driverTripRef.onDisconnect();
          timer.cancel();
          driverRequestTimeout = 45;
        }

        driverRequestTimeout--;

        // a value event listner for newtrips entry in driver table when driver accept the trip

        driverTripRef.onValue.listen((event) {
          //confirming acceptance of confirm button
          if (event.snapshot.value == 'accepted') {
            driverTripRef.onDisconnect();
            driverRequestTimeout = 45;
            timer.cancel();
          }
        });

        // inform driver that the ride has been timed out
        if (driverRequestTimeout == 0) {
          driverTripRef.set('timeout');
          driverTripRef.onDisconnect();
          driverRequestTimeout = 45;
          timer.cancel();

          // selecting new closest driver...

          findDriver();
        }
      });
    });
  }

// For redrawing the polylines toward the pickup address

  void showPolylinesTowardDestination(LatLng driverLatLng) async {
    if (firstTime == true) {
      firstTime = false;
      createMovingMarker();
      var destination =
          Provider.of<AppData>(context, listen: false).destinationAddress;

      var destinationLatLng =
          LatLng(destination.latitude, destination.longitude);

      await getDirection(driverLatLng, destinationLatLng);
    }
  }

// for url launcher lib call and msgs

  void customLaunch(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      print('Can not Launch the Command right now');
    }
  }

  /* void showPolylinesTowardDestination() async {
    if (firstTimeToDestination == true) {
      firstTimeToDestination = false;
      var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
      var destination =
          Provider.of<AppData>(context, listen: false).destinationAddress;

      var pickupLatlng = LatLng(pickup.latitude, pickup.longitude);
      var destinationLatlng =
          LatLng(destination.latitude, destination.longitude);

      await getDirection(pickupLatlng, destinationLatlng);
    }
  }
  */
}

class ShowcancellationDialog extends StatefulWidget {
  @override
  _ShowcancellationDialogState createState() => _ShowcancellationDialogState();
}

class _ShowcancellationDialogState extends State<ShowcancellationDialog> {
  String _dropDownValue;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
            ),
            Text('Your Trip has been cancelled by the tanker driver.'),
            SizedBox(
              height: 20,
            ),
            Text('Please create a new trip request and find another driver.'),
            SizedBox(
              height: 20,
            ),
            BrandDivider(),
            SizedBox(
              height: 16,
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              width: 230,
              child: TaxiButton(
                title: 'CONFIRM',
                color: BrandColors.colorGreen,
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
