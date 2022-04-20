import 'package:flutter/cupertino.dart';
import 'package:waterapp/datamodels/Product.dart';
import 'package:waterapp/datamodels/address.dart';

class AppData extends ChangeNotifier {
  Address pickupAddress;
  Address destinationAddress;
  Address homeAddress;
  Address officeAddress;

  List<Productsss> productss = [];

  void addProduct(Productsss product) {
    productss.add(product);

    notifyListeners();
  }

  void clearProducts() {
    productss = [];
    notifyListeners();
  }

  void updatedAddress(Address pickup) {
    pickupAddress = pickup;

    notifyListeners();
  }

  void updatedDestinationAddress(Address destination) {
    destinationAddress = destination;

    notifyListeners();
  }

  void updateHomeAddress(Address home) {
    homeAddress = home;

    notifyListeners();
  }

  void updateOfficeAddress(Address office) {
    officeAddress = office;

    notifyListeners();
  }
}
