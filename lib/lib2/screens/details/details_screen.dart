import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waterapp/datamodels/Product.dart';
import 'package:waterapp/lib2/constants.dart';
import 'package:waterapp/lib2/screens/details/components/body.dart';

class DetailsScreen extends StatelessWidget {
  final Productsss product;
  final bool isMyProducts;

  const DetailsScreen({
    Key key,
    this.isMyProducts,
    this.product,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // each product have a color
      backgroundColor: Color(0xFF3D82AE),
      appBar: buildAppBar(context),
      body: Body(isMyProducts: isMyProducts, product: product),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF3D82AE),
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset(
          "images/back.svg",
          color: Colors.white,
        ),
        onPressed: () {
          if (favChanged == true) {
            Navigator.pop(context, 'changehuwaFav');
            print('Change huwa changed');
          } else if (deleteHuwa == true) {
            deleteHuwa = false;
            Navigator.pop(context, 'changehuwaFav');
            print('Change huwa changed');
          } else {
            Navigator.pop(context);
            print('nhi tha huwa changed');
          }
        },
      ),
    );
  }
}
