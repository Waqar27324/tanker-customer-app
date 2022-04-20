import 'package:waterapp/datamodels/nearbydrivers.dart';

class FireHelper {
  static List<NearbyDriver> nearbyDriverList = [];

  static void removeFromList(String key) {
    int inder = nearbyDriverList.indexWhere((element) => element.key == key);
    nearbyDriverList.removeAt(inder);
  }

  static void updatenearbyLocation(NearbyDriver driver) {
    int inder =
        nearbyDriverList.indexWhere((element) => element.key == driver.key);
    nearbyDriverList[inder].latitude = driver.latitude;
    nearbyDriverList[inder].longitude = driver.longitude;
  }
}
