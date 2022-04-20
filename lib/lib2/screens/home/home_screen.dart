//import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waterapp/datamodels/Product.dart';
import 'package:waterapp/lib2/screens/home/components/body.dart';

class HomeScreen extends StatefulWidget {
  final int index;
  final List<Productsss> titleProducts;
  HomeScreen({this.index, this.titleProducts});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String title = '';

  //List<Productsss> titleProducts = [];

  String getTitle(int titleIndex) {
    if (titleIndex == 0) {
      return 'Drinking Water';
    }
    if (titleIndex == 1) {
      return 'Water Testing';
    }
    if (titleIndex == 2) {
      return 'Boring and Repairing';
    }
    if (titleIndex == 3) {
      return 'Others';
    }
    if (titleIndex == 4) {
      return 'Others';
    }
    if (titleIndex == 5) {
      return 'My Products';
    }
    if (titleIndex == 6) {
      return 'Favourites';
    }
    if (titleIndex == 7) {
      return 'Search Product';
    } else {
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    title = getTitle(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    //title = getTitle(widget.index);

    return Scaffold(
      appBar: buildAppBar(context),
      body: Body(title: title, titleProducts: widget.titleProducts),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset("images/back.svg"),
        onPressed: () {
          Navigator.pop(context);
          //productss.clear();
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              (widget.index == 7) ? '' : title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                letterSpacing: 3,
                color: Colors.black87,
              ),
            ),
          )
        ],
      ),
    );
  }
}
