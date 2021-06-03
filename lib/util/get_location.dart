import 'package:geolocator/geolocator.dart';

getCurrentLocation() {
  Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
      .then((Position position) {
    return position;
  }).catchError((e) {
    print(e);
  });
}
