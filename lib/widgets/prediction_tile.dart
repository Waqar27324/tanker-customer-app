import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:waterapp/datamodels/address.dart';
import 'package:waterapp/datamodels/prediction.dart';
import 'package:waterapp/dataprovider/appdata.dart';
import 'package:waterapp/gloabal_variables.dart';
import 'package:waterapp/helpers/requestheper.dart';
import 'package:waterapp/screens/brand_colors.dart';
import 'package:waterapp/widgets/progress_indicator.dart';

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  final int index;
  PredictionTile(this.prediction, this.index);

  void getPlaceDetails(String placeId, context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(
              'Loading...',
            ));

    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if (response == 'failed') {
      return;
    }
    if (response['status'] == 'OK') {
      Address thisplace = new Address();

      thisplace.placeName = response['result']['name'];
      thisplace.placeId = placeId;
      thisplace.latitude = response['result']['geometry']['location']['lat'];
      thisplace.longitude = response['result']['geometry']['location']['lng'];

      if (index != 1) {
        if (index == 2) {
          Map homeAddMap = {
            'placeId': thisplace.placeId,
            'placeName': thisplace.placeName,
            'latitude': thisplace.latitude,
            'longitude': thisplace.longitude,
          };

          DatabaseReference homeAddressRef = FirebaseDatabase.instance
              .reference()
              .child('users/${currentUser.uid}');

          homeAddressRef.child('homeAddress').set(homeAddMap);

          Provider.of<AppData>(context, listen: false)
              .updateHomeAddress(thisplace);
          print(thisplace.placeName);
          print(thisplace.placeName + "hello");

          Navigator.pop(context);
        } else {
          Map officeAddMap = {
            'placeId': thisplace.placeId.toString(),
            'placeName': thisplace.placeName,
            'latitude': thisplace.latitude.toString(),
            'longitude': thisplace.longitude.toString(),
          };

          DatabaseReference officeAddressRef = FirebaseDatabase.instance
              .reference()
              .child('users/${currentUser.uid}');

          officeAddressRef.child('officeAddress').set(officeAddMap);

          Provider.of<AppData>(context, listen: false)
              .updateOfficeAddress(thisplace);
          print(thisplace.placeName);
          print(thisplace.placeName + "hello");

          Navigator.pop(context);
        }
      } else {
        Provider.of<AppData>(context, listen: false)
            .updatedDestinationAddress(thisplace);
        print(thisplace.placeName);
        print(thisplace.placeName + "hello");

        Navigator.pop(context, 'getDirection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        getPlaceDetails(prediction.placeId, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Icon(
                  OMIcons.locationOn,
                  color: BrandColors.colorDimText,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prediction.mainText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        prediction.secondaryText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16, color: BrandColors.colorDimText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
