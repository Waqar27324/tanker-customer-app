import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waterapp/datamodels/Product.dart';
import 'package:waterapp/lib2/constants.dart';

import 'cart_counter.dart';

class CounterWithFavBtn extends StatefulWidget {
  final Productsss product;
  const CounterWithFavBtn({Key key, this.product}) : super(key: key);

  @override
  _CounterWithFavBtnState createState() => _CounterWithFavBtnState();
}

class _CounterWithFavBtnState extends State<CounterWithFavBtn> {
  Future<void> fetchFavouriteInfo() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    DatabaseReference favRef = FirebaseDatabase.instance
        .reference()
        .child('users/${user.uid}/isFavourite/${widget.product.productId}');

    favRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value == null) {
        setState(() {
          isFavourits = false;
        });
      } else {
        setState(() {
          isFavourits = true;
        });
      }
    });
  }

  dummyFetch() async {
    await fetchFavouriteInfo();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dummyFetch();
    //fetchFavouriteInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        CartCounter(),
        Container(
          //padding: EdgeInsets.all(8),
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: //(isFavourits) ? Color(0xFFFF6464) :
                Colors.white,
            shape: BoxShape.circle,
          ),
          child: GestureDetector(
            onTap: () async {
              isFavourits = !isFavourits;
              FirebaseUser user = await FirebaseAuth.instance.currentUser();
              print('yaha pe firebase ka user get huwa ha ${user.uid}');
              DatabaseReference productsRef = FirebaseDatabase.instance
                  .reference()
                  .child('users/${user.uid}');
              DatabaseReference favRef = FirebaseDatabase.instance
                  .reference()
                  .child(
                      'users/${user.uid}/isFavourite/${widget.product.productId}');
              favRef.once().then((DataSnapshot snapshot) {
                if (snapshot.value == null) {
                  Map<dynamic, dynamic> map = {
                    '${widget.product.productId}': true,
                  };
                  favChanged = true;
                  setState(() {
                    isFavourits = true;
                  });

                  print('if check huwa ');
                  productsRef
                      .child('isFavourite/${widget.product.productId}')
                      .set(true);
                } else {
                  favChanged = true;
                  productsRef
                      .child('isFavourite/${widget.product.productId}')
                      .remove();
                  setState(() {
                    isFavourits = false;
                  });

                  /*
                  print('agar 2nd time aya to ');
                  productsRef
                      .child('isFavourite/${product.productId}')
                      .once()
                      .then((DataSnapshot snap) {
                    if (snap.value == true) {
                      final bool s = false;
                      productsRef
                          .child('isFavourite/${product.productId}')
                          .set(s);
                      print('false ho gya ');
                    } else {
                      final bool s = true;
                      productsRef
                          .child('isFavourite/${product.productId}')
                          .set(s);
                      print('true ho gya ho gya ');
                    }
                  });

                  */
                }
              });
            },
            child: //(isFavourits) ?
                /*Container(
                    height: 80,
                    width: 80,
                    //color: (isFavourits) ? Color(0xFFFF6464) : Colors.white,
                    child: SvgPicture.asset(
                      "assets/icons/heart.svg",
                      color: Color(0xFFFF6464),
                      height: 80,
                      width: 80,
                    ),
                  )
                  */
                (isFavourits)
                    ? Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFFF6464),
                        size: 30,
                      )
                    : Icon(
                        Icons.favorite_rounded,
                        color: Colors.grey,
                        size: 30,
                      ),
          ),
        )
      ],
    );
  }
}
