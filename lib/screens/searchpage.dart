import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:waterapp/datamodels/address.dart';
import 'package:waterapp/datamodels/prediction.dart';
import 'package:waterapp/dataprovider/appdata.dart';
import 'package:waterapp/gloabal_variables.dart';
import 'package:waterapp/helpers/requestheper.dart';
import 'package:waterapp/screens/brand_colors.dart';
import 'package:waterapp/widgets/brand_divider.dart';
import 'package:waterapp/widgets/prediction_tile.dart';

class SearchPage extends StatefulWidget {
  final int index;

  SearchPage({this.index});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var pickupController = TextEditingController();
  var destController = TextEditingController();
  var focusDestination = FocusNode();
  bool flag = false;

  void focusNode() {
    if (!flag) {
      FocusScope.of(context).requestFocus(focusDestination);
      flag = true;
    }
  }

  List<Prediction> destinationPredictionList = [];

  void searchPlace(String placeName) async {
    if (placeName.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:pk';
      var response = await RequestHelper.getRequest(url);

      if (response == 'failed') {
        return;
      }

      if (response['status'] == 'OK') {
        var predictionJson = response['predictions'];

        var thisList = (predictionJson as List)
            .map((e) => Prediction.fromJson(e))
            .toList();

        setState(() {
          destinationPredictionList = thisList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String address =
        Provider.of<AppData>(context, listen: false).pickupAddress.placeName ??
            '';

    pickupController.text = address;

    focusNode();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: (widget.index == 1) ? 265 : 230,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 5.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                )
              ]),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, bottom: 20, top: 48),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.arrow_back)),
                        Center(
                          child: Text(
                            (widget.index == 1)
                                ? 'Set Destination'
                                : (widget.index == 2)
                                    ? 'Set Home Address'
                                    : 'Set Office Address',
                            style: TextStyle(
                                fontSize: 20, fontFamily: 'Brand-Bold'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'images/pickicon.png',
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                            color: BrandColors.colorLightGrayFair,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: TextField(
                              //readOnly: true,
                              controller: pickupController,
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: 'Pickup location',
                                fillColor: BrandColors.colorLightGrayFair,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 8, bottom: 8),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'images/desticon.png',
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                            color: BrandColors.colorLightGrayFair,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: TextField(
                              onChanged: (value) {
                                searchPlace(value);
                              },
                              focusNode: focusDestination,
                              controller: destController,
                              decoration: InputDecoration(
                                hintText: (widget.index == 2)
                                    ? 'New Home Address'
                                    : (widget.index == 3)
                                        ? 'New Office Address'
                                        : 'Where to?',
                                fillColor: BrandColors.colorLightGrayFair,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 8, bottom: 8),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    (widget.index == 1)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FlatButton(
                                onPressed: () {
                                  Address thisplace = Provider.of<AppData>(
                                          context,
                                          listen: false)
                                      .homeAddress;
                                  Provider.of<AppData>(context, listen: false)
                                      .updatedDestinationAddress(thisplace);
                                  print(thisplace.placeName);
                                  print(thisplace.placeName +
                                      "home wala after button pressed");

                                  Navigator.pop(context, 'getDirection');
                                },
                                //color: Color(0xFF2B1A64),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.blue)),
                                child: Container(
                                  height: 40,
                                  padding: EdgeInsets.all(10),
                                  //color: Colors.grey,
                                  child: Text(
                                    'To Home ?',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              FlatButton(
                                onPressed: () {
                                  Address thisplace = Provider.of<AppData>(
                                          context,
                                          listen: false)
                                      .officeAddress;
                                  Provider.of<AppData>(context, listen: false)
                                      .updatedDestinationAddress(thisplace);
                                  print(thisplace.placeName);
                                  print(thisplace.placeName +
                                      "office wala after button pressed");

                                  Navigator.pop(context, 'getDirection');
                                },
                                //color: Colors.grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.blue)),
                                child: Container(
                                  height: 40,
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'To Office ?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            (destinationPredictionList.length > 0)
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        return PredictionTile(
                            destinationPredictionList[index], widget.index);
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          BrandDivider(),
                      itemCount: destinationPredictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
