import 'package:flutter/material.dart';
import 'package:waterapp/datamodels/Product.dart';
import 'package:waterapp/lib2/constants.dart';
import 'package:waterapp/lib2/screens/details/details_screen.dart';
import 'item_card.dart';

class Body extends StatefulWidget {
  final String title;
  List<Productsss> titleProducts;
  Body({this.title, this.titleProducts});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  //List<Productsss> titleProducts = [];

  void fetchTitleProductsData(
      //String title
      ) //async
  {
    // print('yaha pehle aya');
    //Provider.of<AppData>(context, listen: false).clearTitleProducts();
/*
    if (title == 'My Products') {
      titleProducts.clear();
      print('yaha pe title check huwa ha my Products ke liye if may   $title');
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      print('yaha pe firebase ka user get huwa ha ${user.uid}');
      setState(() {
        Provider.of<AppData>(context, listen: false)
            .productss
            .forEach((element) {
          if (element.creatorId == user.uid.toString())
            titleProducts.add(element);
        });
      });
      final int val =
          Provider.of<AppData>(context, listen: false).productss.length;
      print('yaha pe List for my Products ki length check huwi   $val');
    } else {
      titleProducts.clear();
      final int val =
          Provider.of<AppData>(context, listen: false).productss.length;
      setState(() {
        Provider.of<AppData>(context, listen: false)
            .productss
            .forEach((element) {
          if (element.category == widget.title) titleProducts.add(element);
        });
      });

      print('incase agar my products list nhi ha to   $val');
    }
    */
  }

  /* void fetchProductsData() async {
    if (currentUser != null) {
      DatabaseReference productsRef =
          FirebaseDatabase.instance.reference().child('products');
      // productss.clear();
      productsRef.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> snap = snapshot.value;
        snap.forEach((key, value) {
          final newProduct = Productsss(
              creatorId: value['creatorId'],
              title: value['title'],
              //title: snapshot.key[0].value['title'],
              price: int.parse(value['price']),
              description: value['description'],
              imageUrl: value['imageUrl'],
              category: value['category']);

     
            AppData appData = new AppData();
            appData.addProduct(newProduct);
          
          //print(newProduct);
        });
        //print(productss.length);
      });
    }
  }
*/
  /*
        final newProduct = Productsss(
            creatorId: snapshot.key,
            //title: snapshot.key.,
            //title: snapshot.key[0].value['title'],
            price: snapshot.value['price'],
            description: snapshot.value['description'],
            imageUrl: snapshot.value['imageUrl'],
            category: snapshot.value['category']);
        AppData appData = new AppData();
        appData.addProduct(newProduct);
  */
  //print(snapshot.value[]);
  //productss.add(newProduct);
  //creatorId = snapshot.value['creatorId'];
  // });

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //productss.clear();

    fetchTitleProductsData(
        //widget.title
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        //Categories(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
            child: GridView.builder(
                itemCount: widget.titleProducts.length,

                //itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: kDefaultPaddin,
                  crossAxisSpacing: kDefaultPaddin,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) => ItemCard(
                      index: index,
                      product: widget.titleProducts[index],
                      press: () async {
                        if (widget.title == 'Favourites') {
                          poppedData = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsScreen(
                                  isMyProducts: (widget.title == 'My Products')
                                      ? true
                                      : false,
                                  product: widget.titleProducts[index],
                                ),
                              ));
                          if (poppedData == 'changehuwaFav' &&
                              favChanged == true) {
                            Navigator.pop(context);
                            favChanged = false;
                            poppedData = '';
                            print('successfully done to home');
                            print(poppedData);
                            print(favChanged);
                          }
                        } else if (widget.title == 'My Products') {
                          poppedData = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsScreen(
                                  isMyProducts: (widget.title == 'My Products')
                                      ? true
                                      : false,
                                  product: widget.titleProducts[index],
                                ),
                              ));
                          if (poppedData == 'changehuwaFav' &&
                              deleteHuwa == true) {
                            setState(() {
                              deleteHuwa = false;
                            });
                            Navigator.pop(context);
                            print('successfully done to home after deletion');
                          }
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsScreen(
                                  isMyProducts: (widget.title == 'My Products')
                                      ? true
                                      : false,
                                  product: widget.titleProducts[index],
                                ),
                              ));
                        }
                        /*
                        poppedData = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                isMyProducts: (widget.title == 'My Products')
                                    ? true
                                    : false,
                                product: widget.titleProducts[index],
                              ),
                            ));
                        if (poppedData == 'changehuwaFav') {
                          Navigator.pop(context);
                          print('successfully done to home');
                        }
                        */
                      },
                    )

/*
itemBuilder: (context, index){
  
  if(Provider.of<AppData>(context,
                                listen: false)
                            .productss[index]
                            .category ==
                        widget.title){
                          return ItemCard(
                        index: index,
                        product: Provider.of<AppData>(context, listen: false)
                            .productss[index],
                        press: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                product:
                                    Provider.of<AppData>(context, listen: false)
                                        .productss[index],
                              ),
                          )),
                      );
                        }
}

*/

                ),
          ),
        ),
      ],
    );
  }
}
