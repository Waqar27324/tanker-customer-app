import 'package:flutter/material.dart';
import 'package:waterapp/datamodels/Product.dart';
import 'package:waterapp/lib2/constants.dart';

import 'add_to_cart.dart';
import 'counter_with_fav_btn.dart';
import 'description.dart';
import 'product_title_with_image.dart';

class Body extends StatelessWidget {
  final Productsss product;
  final bool isMyProducts;

  const Body({Key key, this.isMyProducts, this.product}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // It provide us total height and width

    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: (MediaQuery.of(context).orientation == Orientation.portrait)
                ? size.height
                : 600,
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: size.height * 0.3),
                  padding: EdgeInsets.only(
                    top: size.height * 0.12,
                    left: kDefaultPaddin,
                    right: kDefaultPaddin,
                  ),
                  // height: 500,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Expanded(
                    child: Column(
                      children: <Widget>[
                        // ColorAndSize(product: product),
                        SizedBox(
                            height: (MediaQuery.of(context).orientation ==
                                    Orientation.portrait)
                                ? kDefaultPaddin / 2
                                : 130),
                        Description(product: product),
                        SizedBox(height: kDefaultPaddin / 2),
                        CounterWithFavBtn(
                          product: product,
                        ),
                        SizedBox(height: kDefaultPaddin / 2),
                        AddToCart(product: product)
                      ],
                    ),
                  ),
                ),
                ProductTitleWithImage(
                  product: product,
                  isMyProducts: isMyProducts,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
