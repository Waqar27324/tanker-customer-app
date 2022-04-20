import 'package:flutter/material.dart';
import 'package:waterapp/datamodels/Product.dart';

import '../../../constants.dart';

class ItemCard extends StatelessWidget {
  final index;
  final Productsss product;
  final Function press;
  const ItemCard({
    Key key,
    this.index,
    this.product,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(kDefaultPaddin),
              height:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? 180
                      : 150,
              width:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? 180
                      : 350,
              //color: Color(0xFF3D82AE),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Color(0xFF3D82AE),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: (product.imageUrl != null)
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        height: 120,
                        width: 120,
                      )
                    : Image.network(
                        'https://i.imgur.com/sUFH1Aq.png',
                        fit: BoxFit.cover,
                        height: 100,
                        width: 100,
                      ),
              ),
            ),
          ),
          /*
            Container(
              padding: EdgeInsets.all(kDefaultPaddin),
              // For  demo we use fixed height  and width
              // Now we dont need them
              height: 180,
              width: 160,
              decoration: BoxDecoration(
                color: Color(0xFF3D82AE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Hero(
                tag: "demoTag${index}",
                child: (product.imageUrl != null)
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        'https://i.imgur.com/sUFH1Aq.png',
                        fit: BoxFit.cover,
                      ),
                //Image.asset(product.image),
              ),
            ),
          ),
          */
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin / 4),
            child: Text(
              // products is out demo list
              product.title,
              style: TextStyle(color: kTextLightColor),
            ),
          ),
          Text(
            "\Rs ${product.price}",
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
