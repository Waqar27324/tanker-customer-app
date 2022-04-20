import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:waterapp/datamodels/Product.dart';
import 'package:waterapp/dataprovider/appdata.dart';
import 'package:waterapp/lib2/progress_indicator.dart';

import '../../../constants.dart';

class ProductTitleWithImage extends StatelessWidget {
  final Productsss product;
  final bool isMyProducts;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

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

  ProductTitleWithImage({Key key, @required this.product, this.isMyProducts})
      : super(key: key);

  Future<void> deleteProduct(BuildContext context) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        'Deleting product...',
      ),
    );

    if (user != null) {
      DatabaseReference productsRef = FirebaseDatabase.instance
          .reference()
          .child('products/${product.productId}');
      productsRef.remove();

      //deleteHuwa == true;

      Provider.of<AppData>(context, listen: false)
          .productss
          .removeWhere((element) => element.productId == product.productId);

      DatabaseReference favRef = FirebaseDatabase.instance
          .reference()
          .child('users/${user.uid}/isFavourite/${product.productId}');
      favRef.once().then((value) {
        if (value != null) favRef.remove();
      });
      //Navigator.of(context);
      Navigator.pop(context);
    } else {
      print('yaha aya ha eklse me');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
        key: scaffoldKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category,
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      product.title,
                      style: Theme.of(context).textTheme.headline4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                    ),
                  ],
                ),
                isMyProducts
                    ? Container(
                        padding: EdgeInsets.all(0),
                        height: 50,
                        width: 50,
                        //color: ,
                        decoration: BoxDecoration(
                          //color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                          onTap: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) => ProgressDialog(
                                'Deleting product...',
                              ),
                            );
                            await deleteProduct(context).then((_) {
                              deleteHuwa = true;

                              Navigator.pop(context);
                              Navigator.pop(context, 'changehuwaFav');

                              print(Provider.of<AppData>(context, listen: false)
                                  .productss
                                  .length);
                            });
                          },
                        ),
                      )
                    : Container(),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: "Price\n"),
                      TextSpan(
                        text: "Rs ${product.price}",
                        style: Theme.of(context).textTheme.headline4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: kDefaultPaddin),
                Expanded(
                  child: Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        height: (MediaQuery.of(context).orientation ==
                                Orientation.portrait)
                            ? 250
                            : 225,
                        width: (MediaQuery.of(context).orientation ==
                                Orientation.portrait)
                            ? 170
                            : 100,
                      ),
                    ),
                  ),
                ),

/*
                Expanded(
                  child: Container(
                    height: 250,
                    width: 170,
                    decoration: BoxDecoration(
                      //shape: BoxShape.circle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: Hero(
                      tag: "demoTag",
                      child: (product.imageUrl != null)
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                            )
                          : Image.network('https://i.imgur.com/sUFH1Aq.png'),
                      // Image.asset(
                      //  product.imageUrl,
                      //  fit: BoxFit.fill,
                      // ),
                    ),
                  ),
                )
                */
              ],
            )
          ],
        ),
      ),
    );
  }
}
