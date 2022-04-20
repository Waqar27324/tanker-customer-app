import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waterapp/datamodels/Product.dart';

import '../../../constants.dart';

class AddToCart extends StatelessWidget {
  const AddToCart({
    Key key,
    @required this.product,
  }) : super(key: key);

  final Productsss product;

  void customLaunch(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      print('Can not Launch the Command right now');
    }
  }

  void launchURL() async {
    const url = 'tel:+923025005480';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: kDefaultPaddin),
            height: 50,
            width: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Color(0xFF3D82AE),
              ),
            ),
            child: IconButton(
              icon:
                  //SvgPicture.asset(
                  //  "assets/icons/add_to_cart.svg",
                  //  color: product.color,
                  //)
                  Icon(Icons.message),
              onPressed: () {
                customLaunch('sms:03025005480');
              },
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 50,
              child: RaisedButton(
                  onPressed: () {
                    customLaunch('tel:+923025005480');
                    //customLaunch('https://www.google.com');
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  color: Color(0xFF3D82AE),
                  child: Text(
                    "Call Now".toUpperCase(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )

                  /*
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                color: Color(0xFF3D82AE),
                onPressed: () {
                  customLunch('tel:+923025005480');
                },
                child: Text(
                  "Call Now".toUpperCase(),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              */
                  ),
            ),
          )
        ],
      ),
    );
  }
}
