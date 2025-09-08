// Package imports:
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Project imports:
import 'package:tamam_business/features/address/domain/models/prediction_model.dart';
import 'package:tamam_business/features/address/domain/models/zone_model.dart';
import 'package:tamam_business/features/address/domain/models/zone_response_model.dart';
import 'package:tamam_business/features/address/domain/repositories/address_repository_interface.dart';
import 'package:tamam_business/features/address/domain/services/address_service_interface.dart';
import 'package:tamam_business/features/auth/domain/models/module_model.dart';

class AddressService implements AddressServiceInterface {
  final AddressRepositoryInterface addressRepositoryInterface;
  AddressService({required this.addressRepositoryInterface});

  @override
  Future<List<ZoneModel>?> getZoneList() async {
    return await addressRepositoryInterface.getList();
  }

  @override
  Future<String> getAddressFromGeocode(LatLng latLng) async {
    return await addressRepositoryInterface.getAddressFromGeocode(latLng);
  }

  @override
  Future<List<PredictionModel>> searchLocation(String text) async {
    return await addressRepositoryInterface.searchLocation(text);
  }

  @override
  Future<Response?> getPlaceDetails(String? placeID) async {
    return await addressRepositoryInterface.getPlaceDetails(placeID);
  }

  @override
  Future<Response> getZone(String lat, String lng) async {
    return await addressRepositoryInterface.getZone(lat, lng);
  }

  @override
  Future<bool> saveUserAddress(String address, List<int>? zoneIDs) async {
    return await addressRepositoryInterface.saveUserAddress(address, zoneIDs);
  }

  @override
  String? getUserAddress() {
    return addressRepositoryInterface.getUserAddress();
  }

  @override
  Future<List<ModuleModel>?> getModules(int? zoneId) async {
    return await addressRepositoryInterface.getModules(zoneId);
  }

  @override
  Future<bool> checkInZone(String? lat, String? lng, int zoneId) async {
    return await addressRepositoryInterface.checkInZone(lat, lng, zoneId);
  }

  @override
  LatLng? setRestaurantLocation(ZoneResponseModel response, LatLng location) {
    LatLng? restaurantLocation;
    if(response.isSuccess && response.zoneIds.isNotEmpty) {
      restaurantLocation = location;
    }else {
      restaurantLocation = null;
    }
    return restaurantLocation;
  }

  @override
  List<int>? setZoneIds(ZoneResponseModel response) {
    List<int>? zoneIds;
    if(response.isSuccess && response.zoneIds.isNotEmpty) {
      zoneIds = response.zoneIds;
    }else {
      zoneIds = null;
    }
    return zoneIds;
  }

  @override
  int? setSelectedZoneIndex(ZoneResponseModel response, List<int>? zoneIds, int? selectedZoneIndex, List<ZoneModel>? zoneList) {
    int? zoneIndex = selectedZoneIndex;
    if(response.isSuccess && response.zoneIds.isNotEmpty) {
      for(int index = 0; index < zoneList!.length; index++) {
        if(zoneIds!.contains(zoneList[index].id)) {
          zoneIndex = index;
          break;
        }
      }
    }
    return zoneIndex;
  }

  @override
  Future<Position> getPosition(LatLng? defaultLatLng, LatLng configLatLng) async {
    Position myPosition;
    try {
      // Check location permissions first
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        // Check if location services are enabled
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          Position newLocalData = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
          );
          myPosition = newLocalData;
        } else {
          // Location services are disabled, use default position
          myPosition = Position(
            latitude: defaultLatLng != null ? defaultLatLng.latitude : configLatLng.latitude,
            longitude: defaultLatLng != null ? defaultLatLng.longitude : configLatLng.longitude,
            timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1,
          );
        }
      } else {
        // Permission denied, use default position
        myPosition = Position(
          latitude: defaultLatLng != null ? defaultLatLng.latitude : configLatLng.latitude,
          longitude: defaultLatLng != null ? defaultLatLng.longitude : configLatLng.longitude,
          timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1,
        );
      }
    } catch(e) {
      // Any error, use default position
      myPosition = Position(
        latitude: defaultLatLng != null ? defaultLatLng.latitude : configLatLng.latitude,
        longitude: defaultLatLng != null ? defaultLatLng.longitude : configLatLng.longitude,
        timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1,
      );
    }
    return myPosition;
  }

  @override
  void handleMapAnimation(GoogleMapController? mapController, Position myPosition) {
    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(myPosition.latitude, myPosition.longitude), zoom: 17),
      ));
    }
  }

}
