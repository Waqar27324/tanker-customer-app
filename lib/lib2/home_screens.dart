import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waterapp/datamodels/Product.dart';
import 'package:waterapp/dataprovider/appdata.dart';
import 'package:waterapp/gloabal_variables.dart';
import 'package:waterapp/lib2/constants.dart';
import 'package:waterapp/lib2/progress_indicator.dart';
import 'package:waterapp/lib2/screens/addproduct/newproduct.dart';
import 'package:waterapp/lib2/screens/addproduct/no_item_found.dart';
import 'package:waterapp/lib2/screens/addproduct/set_location.dart';
import 'package:waterapp/screens/loginpage.dart';
import 'package:waterapp/screens/profilePage.dart';

import 'screens/home/home_screen.dart';

class HomePage extends StatefulWidget {
  static const String id = 'homepage';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //CrudMethods crudMethods = new CrudMethods();
  //Stream blogsStream;
  final int myProductIndex = 4;
  List<Productsss> titleProducts = [];
  List<String> myFavProducts = [];

  bool isEnable = false;

  var searchController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  FocusScopeNode currentFocus;

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

  //final int incrementCategories = 0;
  final int totalCategories = 6;
  List<String> categoriesList = [
    'Drinking Water',
    'Water Testing',
    'Boring and Repairing',
    'Others',
    'Others',
    'Others'
  ];

  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
    currentUser = null;
    Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
  }

  Widget BlogsList(int index) {
    return
        // yaha se all children hain
        GestureDetector(
      onTap: () async {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        if (index == 0) {
          await titleCategoryProducts('Drinking Water').whenComplete(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        index: index,
                        titleProducts: titleProducts,
                      )),
            );
          });
        }

        if (index == 1) {
          await titleCategoryProducts('Water Testing').whenComplete(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        index: index,
                        titleProducts: titleProducts,
                      )),
            );
          });
        }

        if (index == 2) {
          await titleCategoryProducts('Boring and Repairing').whenComplete(() {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    index: index,
                    titleProducts: titleProducts,
                  ),
                ));
          });
        }

        if (index == 3) {
          await titleCategoryProducts('Others').whenComplete(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        index: index,
                        titleProducts: titleProducts,
                      )),
            );
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 4),
        height: 150,
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(7, 6, 7, 0),
        child: Stack(
          children: <Widget>[
            /*
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              
              child: CachedNetworkImage(
                imageUrl:
                    'http://www.baltana.com/files/wallpapers-19/Seashore-Gradient-4K-Wallpaper-7381.jpg',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            */
            Container(
              height: 170,
              decoration: BoxDecoration(
                  color: Color(0xFF3D82AE),
                  borderRadius: BorderRadius.circular(6)),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    categoriesList[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 25,
                        letterSpacing: 3,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> fetchProductsData() async {
    //if (currentUser != null) {

    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print('yaha pe firebase ka user get huwa ha ${user.uid}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        'Loading products...',
      ),
    );

    DatabaseReference productsRef =
        FirebaseDatabase.instance.reference().child('products');

    if (backFromLocation.isNotEmpty && backFromLocation != 'All') {
      setState(() {
        productsRef.once().then((DataSnapshot snapshot) {
          Provider.of<AppData>(context, listen: false).clearProducts();
          Map<dynamic, dynamic> snap = snapshot.value;
          Navigator.pop(context);
          snap.forEach((key, value) {
            if (value['location'].toString() == backFromLocation) {
              final newProduct = Productsss(
                  productId: value['productId'],
                  creatorId: value['creatorId'],
                  title: value['title'],
                  price: int.parse(value['price']),
                  description: value['description'],
                  imageUrl: value['imageUrl'],
                  category: value['category'],
                  location: value['location']);

              Provider.of<AppData>(context, listen: false)
                  .addProduct(newProduct);
            }
          });
        });
        newLocation = '';
      });
    } else {
      setState(() {
        productsRef.once().then((DataSnapshot snapshot) {
          Provider.of<AppData>(context, listen: false).clearProducts();
          Map<dynamic, dynamic> snap = snapshot.value;
          Navigator.pop(context);
          snap.forEach((key, value) {
            final newProduct = Productsss(
                productId: value['productId'],
                creatorId: value['creatorId'],
                title: value['title'],
                price: int.parse(value['price']),
                description: value['description'],
                imageUrl: value['imageUrl'],
                category: value['category'],
                location: value['location']);

            print(
                'yaha aya ke nahi...----------------  ${Provider.of<AppData>(context, listen: false).productss.length}');

            Provider.of<AppData>(context, listen: false).addProduct(newProduct);
          });
        });
      });
      print(
          'yaha aya but ab pta chalega ke kitny hain--------  ${Provider.of<AppData>(context, listen: false).productss.length}');
    }
  }

  Future<void> titleCategoryProducts(String title) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    titleProducts.clear();

    if (title == 'My Products') {
      setState(() {
        Provider.of<AppData>(context, listen: false)
            .productss
            .forEach((element) {
          if (element.creatorId == user.uid.toString())
            titleProducts.add(element);
        });
      });
    } else if (title == 'Favourites') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(
          'Loading products...',
        ),
      );
      //titleProducts.clear();
      print('yaha pe title check huwa ha my Products ke liye if may   $title');

      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      print('yaha pe firebase ka user get huwa ha ${user.uid}');
      DatabaseReference productsRef = FirebaseDatabase.instance
          .reference()
          .child('users/${user.uid}/isFavourite');

      productsRef.once().then((DataSnapshot snapshot) async {
        print('total snapshot items of fav products');
        print(snapshot.value);
        Navigator.pop(context);

        myFavProducts.clear();
        Map<dynamic, dynamic> fav = snapshot.value;
        fav.forEach((key, value) {
          myFavProducts.add(key.toString());
        });
        await fetchOnlyFavProducts().whenComplete(() {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                      index: 6,
                      titleProducts: titleProducts,
                    )),
          );
        });
      });

/*
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

      */
    } else {
      //titleProducts.clear();
      final int val =
          Provider.of<AppData>(context, listen: false).productss.length;
      setState(() {
        Provider.of<AppData>(context, listen: false)
            .productss
            .forEach((element) {
          if (element.category == title) titleProducts.add(element);
        });
      });

      print('incase agar my products list nhi ha to   $val');
    }
  }

  Future<int> fetchOnlyFavProducts() async {
    setState(() {
      titleProducts.clear();
      myFavProducts.forEach((favElement) {
        Provider.of<AppData>(context, listen: false)
            .productss
            .forEach((element) {
          if (element.productId == favElement) titleProducts.add(element);
        });
      });
      //Navigator.pop(context);
    });
    return 5;
  }

  Future<int> fetchSearchedProducts() async {
    setState(() {
      titleProducts.clear();
      //myFavProducts.forEach((favElement) {
      Provider.of<AppData>(context, listen: false).productss.forEach((element) {
        if (element.title
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
          titleProducts.add(element);
      });
      //});
      //Navigator.pop(context);
    });
    return 7;
  }

  void searchQuery() async {
    await fetchSearchedProducts().whenComplete(() {
      if (titleProducts.length < 1 || titleProducts.length == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NoItemFound()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    index: 7,
                    titleProducts: titleProducts,
                  )),
        );
      }
    });
  }

  void ondrawerChanged(bool) {
    currentFocus = FocusScope.of(context);
    currentFocus.unfocus();
  }

  void focusClosing() {
    currentFocus = FocusScope.of(context);
    //currentFocus.unfocus();
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void focusWhenNeeded() {
    currentFocus = FocusScope.of(context);
    //currentFocus.hasFocus;
  }

  void openProfilePage() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(),
        ));
  }

  @override
  void initState() {
    super.initState();
    // Provider.of<AppData>(context, listen: false).productss.clear();
    fetchProductsData();
  }

  @override
  Widget build(BuildContext context) {
    //productss.clear();
    //Provider.of<AppData>(context, listen: false).productss.clear();
    //focusClosing();

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            // color: Colors.black,
            icon: SvgPicture.asset(
              "images/back.svg",
            ),
            onPressed: () {
              Navigator.pop(context);
              //productss.clear();
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Water Services",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 3,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black),
          /*
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_location),
              onPressed: () {},
            ),
 SizedBox(width: kDefaultPaddin / 2)
          ],
          */
        ),
        /*
DropdownButton(
              hint: Icon(Icons.add_location),
              isExpanded: true,
              iconSize: 50.0,
              style: TextStyle(color: Colors.black),
              items: [
                'Rawalpindi',
                'Islamabad',
                'Karachi',
                'Lahore',
                'Multan',
                'Quetta',
                'Taxila',
              ].map(
                (val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                },
              ).toList(),
              onChanged: (val) {
                setState(
                  () {
                    //_dropDownValue = val;
                  },
                );
              },
            ),

            */

        //SizedBox(width: kDefaultPaddin / 2)
        //],
        //),
        endDrawer: GestureDetector(
          onTap: () {
            focusClosing();
          },
          child: Container(
            width: (MediaQuery.of(context).orientation == Orientation.portrait)
                ? 250
                : 400,
            color: Color(0xFF3D82AE),

            // Drawer code...

            child: Drawer(
              child: ListView(
                padding: EdgeInsets.all(0),
                children: [
                  Container(
                    color: Color(0xFF3D82AE),
                    height: 160,
                    child: DrawerHeader(
                        decoration: BoxDecoration(
                          color: Color(0xFF3D82AE),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: 100.0,
                                height: 100.0,
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                    image: (imageurl != null)
                                        ? NetworkImage(imageurl)
                                        : ExactAssetImage(
                                            'images/profiile.png'),
                                    fit: BoxFit.cover,
                                  ),
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    (currentUserInfo != null)
                                        ? currentUserInfo.userName
                                        : 'Waqar',
                                    style: TextStyle(
                                        fontSize: 20, fontFamily: 'Brand-Bold'),
                                  ),
                                  FlatButton(
                                      onPressed: openProfilePage,
                                      child: Expanded(
                                        child: Text(
                                          'Edit Profile',
                                          overflow: TextOverflow.fade,
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                      ))
                                ],
                              ),
                            )
                          ],
                        )),
                  ),
                  //BrandDivider(),
                  SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      'My Products',
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () async {
                      await titleCategoryProducts('My Products')
                          .whenComplete(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                    index: 5,
                                    titleProducts: titleProducts,
                                  )),
                        );
                      });
                      focusClosing();
                    },
                  ),
                  //BrandDivider(),
                  ListTile(
                    leading: Icon(Icons.favorite),
                    title: Text(
                      'Favourites',
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () async {
                      titleCategoryProducts('Favourites');
                      focusClosing();
                      /*
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeScreen(
                                  index: myProductIndex,
                                  titleProducts: titleProducts,
                                )),
                      );
                      */
                    },
                  ),
                  //BrandDivider(),
                  ListTile(
                    leading: Icon(Icons.add_location),
                    title: Text(
                      'Set Location',
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () async {
                      backFromLocation = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SetLocation()),
                      );

                      if (backFromLocation.isNotEmpty ||
                          newLocation.isNotEmpty) {
                        //print(backFromLocation + newLocation);
                        await fetchProductsData();
                      }
                      focusClosing();
                    },
                  ),
                  //BrandDivider(),
                  ListTile(
                    leading: Icon(Icons.contact_support),
                    title: Text(
                      'Option 4',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  //BrandDivider(),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text(
                      'Option 5',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  //BrandDivider(),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text(
                      'Logout',
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: logoutUser,
                  ),
                ],
              ),
            ),
          ),
        ),
        onDrawerChanged: ondrawerChanged,
        onEndDrawerChanged: ondrawerChanged,
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: //blogsStream != null ?
                Column(children: [
              Container(
                margin: const EdgeInsets.fromLTRB(15, 5, 15, 2),
                //padding: const EdgeInsets.all(3.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Color(0xFF3D82AE))),
                height: 50,
                padding: EdgeInsets.only(right: 8, left: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isEnable = true;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          //focusNode: currentFocus,
                          //focusNode: currentFocus.hasPrimaryFocus ?? currentFocus,
                          enabled: isEnable,
                          autofocus: true,
                          controller: searchController,
                          decoration: InputDecoration(
                            labelText: 'Please enter search title',
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 20.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async {
                            var connRes =
                                await Connectivity().checkConnectivity();

                            if (connRes != ConnectivityResult.mobile &&
                                connRes != ConnectivityResult.wifi) {
                              showSnackBar(
                                  'Please check your connection and try again');
                              return;
                            }
                            if (searchController.text.length < 3 ||
                                searchController.text.isEmpty) {
                              showSnackBar('Please provide valid search title');
                              return;
                            }
                            searchQuery();
                            isEnable = false;
                            searchController.text = '';
                          }),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              BlogsList(0),
              BlogsList(1),
              BlogsList(2),
              BlogsList(3),
              BlogsList(4),
              BlogsList(5),
            ]),
          ),
        ),
        floatingActionButton: new FloatingActionButton(
            elevation: 0.0,
            child: new Icon(Icons.add),
            backgroundColor: new Color(0xFFE8913A),
            onPressed: () async {
              afterAddingNewProduct = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewProduct()),
              );
              // currentFocus = FocusScope.of(context);

              if (afterAddingNewProduct == 'New Product Added') {
                await fetchProductsData();
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              } else {
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              }
            }));
  }
}
