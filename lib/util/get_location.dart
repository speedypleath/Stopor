import 'package:geolocator/geolocator.dart';

getCurrentLocation() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);
  return position;
}
