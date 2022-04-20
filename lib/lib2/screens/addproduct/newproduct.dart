import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waterapp/gloabal_variables.dart';
import 'package:waterapp/lib2/progress_indicator.dart';

class NewProduct extends StatefulWidget {
  static const String id = 'newproduct';

  @override
  _NewProductState createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  String imageUrl;
  String _dropDownValue;
  String _dropDownLocationValue, goingBackInPop;

  var titleController = TextEditingController();

  var priceController = TextEditingController();

  var descriptionController = TextEditingController();

  var urlController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  FirebaseAuth auth = FirebaseAuth.instance;

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

  void addProduct() async {
    // code to show custom loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        'Uploading your post',
      ),
    );

    // code to signin connection
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();

    if (user != null) {
      DatabaseReference newProductRef =
          FirebaseDatabase.instance.reference().child('products');
      String newKey = newProductRef.push().key;
      print('new key is: ');
      print(newKey);

      currentUser = user;
      Map newProductMap = {
        'productId': newKey.toString(),
        'creatorId': user.uid,
        'title': titleController.text,
        'price': priceController.text,
        'description': descriptionController.text,
        'imageUrl': imageUrl,
        'category': _dropDownValue,
        'location': _dropDownLocationValue,
      };

      await newProductRef.child(newKey).set(newProductMap);

      Navigator.pop(context);
      showSnackBar('New product has been added successfully');

      setState(() {
        goingBackInPop = 'New Product Added';
        imageUrl = null;
        titleController.clear();
        priceController.clear();
        descriptionController.clear();
        _dropDownLocationValue = null;
        _dropDownValue = null;
      });
/*
      newProductRef.once().then((DataSnapshot snapshot) {
        if (snapshot != null) {
          //Navigator.of(context).pushAndRemoveUntil(context, HomePage() , (route) => false)
          Navigator.pushNamedAndRemoveUntil(
              context, HomePage.id, (route) => false);
        }
      });
      */
    } else {
      print('not addes new product');
    }
    //Navigator.pop(context);
  }

  uploadImage() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        'loading your image...',
      ),
    );

    PickedFile image;
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      //Select Image
      image = await _imagePicker.getImage(source: ImageSource.gallery);
      var file = File(image.path);

      if (image != null) {
        //Upload to Firebase
        var snapshot = await _firebaseStorage
            .ref()
            .child('products/${DateTime.now().toString()}')
            .putFile(file)
            .onComplete;
        var downloadUrl = await snapshot.ref.getDownloadURL();
        Navigator.pop(context);
        print('image link is: ');
        print(downloadUrl);
        setState(() {
          imageUrl = downloadUrl;
        });
      } else {
        print('No Image Path Received');
      }
    } else {
      print('Permission not granted. Try Again with permission access');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFAFAFA),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: SvgPicture.asset("images/back.svg"),
            onPressed: () {
              Navigator.pop(context, goingBackInPop);
              goingBackInPop = '';
              //productss.clear();
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "New Product",
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 25,
                    letterSpacing: 3,
                    color: Colors.black),
              )
            ],
          ),
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          height: 55,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(5))),
                          child: DropdownButton(
                            hint: _dropDownLocationValue == null
                                ? Text('Set location')
                                : Text(
                                    _dropDownLocationValue,
                                    style: TextStyle(color: Colors.black),
                                  ),
                            isExpanded: true,
                            underline: Text(''),
                            iconSize: 30.0,
                            style: TextStyle(color: Colors.black),
                            items: [
                              'Rawalpindi',
                              'Islamabad',
                              'Karachi',
                              'Lahore',
                              'Multan',
                              'Quetta',
                              'Taxila',
                              'All',
                            ].map(
                              (val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(val),
                                );
                              },
                            ).toList(),
                            onChanged: (val) {
                              setState(
                                () {
                                  _dropDownLocationValue = val;
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          height: 55,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(5))),
                          child: DropdownButton(
                            hint: _dropDownValue == null
                                ? Text('Category')
                                : Text(
                                    _dropDownValue,
                                    style: TextStyle(color: Colors.black),
                                  ),
                            isExpanded: true,
                            iconSize: 30.0,
                            underline: Text(
                              '',
                            ),
                            style: TextStyle(color: Colors.black),
                            items: [
                              'Drinking Water',
                              'Water Testing',
                              'Boring and Repairing',
                              'Others'
                            ].map(
                              (val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(val),
                                );
                              },
                            ).toList(),
                            onChanged: (val) {
                              setState(
                                () {
                                  _dropDownValue = val;
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: titleController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Enter title',
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
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
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Set price',
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
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
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Enter description',
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        GestureDetector(
                          onTap: () {
                            uploadImage();
                          },
                          child: Container(
                              margin: EdgeInsets.all(15),
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                                border: Border.all(color: Colors.white),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(2, 2),
                                    spreadRadius: 2,
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                              child: (imageUrl != null)
                                  ? Image.network(imageUrl)
                                  : Image.network(
                                      'https://i.imgur.com/sUFH1Aq.png')),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        /*
                        RaisedButton(
                          child: Text("Upload Image",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15)),
                          onPressed: () {
                            uploadImage();
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.blue)),
                          elevation: 5.0,
                          color: Colors.blue[400],
                          textColor: Colors.white,
                          padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                          splashColor: Colors.grey,
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        */
                        RaisedButton(
                          onPressed: () async {
                            var connRes =
                                await Connectivity().checkConnectivity();

                            if (connRes != ConnectivityResult.mobile &&
                                connRes != ConnectivityResult.wifi) {
                              showSnackBar(
                                  'Please check your connection and try again');
                              return;
                            }

                            if (titleController.text.isEmpty) {
                              showSnackBar('Please enter a title');
                              return;
                            }
                            if (priceController.text.length < 1) {
                              showSnackBar('Please provide a valid price');
                              return;
                            }
                            if (descriptionController.text.length < 10) {
                              showSnackBar(
                                  'Please provide atlest 10 characters of description ');
                              return;
                            }
                            if (imageUrl.isEmpty) {
                              showSnackBar(
                                  'Please choose an image for your product ');
                              return;
                            }
                            if (_dropDownValue.isEmpty) {
                              showSnackBar(
                                  'Please choose a category from dropdown categories');
                              return;
                            }
                            if (_dropDownLocationValue.isEmpty) {
                              showSnackBar(
                                  'Please set a location/region for your product');
                              return;
                            }
                            addProduct();
                          },
                          child: Container(
                            height: 50,
                            child: Center(
                              child: Text(
                                'Upload',
                                style: TextStyle(
                                    fontSize: 18, fontFamily: 'Brand-Bold'),
                              ),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(25),
                          ),
                          color: Color(0xFF3D82AE),
                          textColor: Colors.white,
                        ),
                      ],
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
