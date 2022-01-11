import 'dart:async';

import 'package:location/location.dart';
class LocationService{
  late UserLocation _currentLocation;
  var location= Location();
  Future<UserLocation> getLocation() async{
    try{
      var userLocation = await location.getLocation();
      _currentLocation= UserLocation(userLocation.latitude!, userLocation.longitude!);
    } on Exception catch(e){
      print("Could Not Get Location : ${e.toString()}");
    }
    return _currentLocation;
  }
  StreamController<UserLocation> _locationController = StreamController<UserLocation>.broadcast();
  Stream<UserLocation> get locationStream => _locationController.stream;
  LocationService() {
    location.requestPermission().then((PermissionStatus granted){
      print("MockLocation ${granted}");

      if(granted==PermissionStatus.granted){
        location.onLocationChanged.listen((locationData) {
          if(locationData!=null){
            _locationController.add(UserLocation(locationData.latitude!, locationData.longitude!));
          }
        });
      }
    });
  }
}
class UserLocation{
  final double latitude;
  final double longitude;
  UserLocation(this.latitude,this.longitude);
}

