// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:tamam_business/api/api_client.dart';
import 'package:tamam_business/common/widgets/custom_snackbar_widget.dart';
import 'package:tamam_business/features/address/domain/models/prediction_model.dart';
import 'package:tamam_business/features/address/domain/models/zone_model.dart';
import 'package:tamam_business/features/address/domain/repositories/address_repository_interface.dart';
import 'package:tamam_business/features/auth/domain/models/module_model.dart';
import 'package:tamam_business/util/app_constants.dart';

class AddressRepository implements AddressRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AddressRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<List<ZoneModel>?> getList() async {
    List<ZoneModel>? zoneList;
    Response response = await apiClient.getData(AppConstants.zoneListUri);
    if (response.statusCode == 200) {
      zoneList = [];

      // Handle the case where response.body might be a string or already parsed JSON
      dynamic responseData = response.body;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (e) {
          debugPrint('Failed to decode JSON: $e');
          return null;
        }
      }

      // Handle both single zone object and array of zones
      if (responseData is List) {
        // If it's already an array, process each item
        for (var zone in responseData) {
          zoneList.add(ZoneModel.fromJson(zone));
        }
      } else if (responseData is Map<String, dynamic>) {
        // If it's a single zone object, add it to the list
        zoneList.add(ZoneModel.fromJson(responseData));
      }
    }
    return zoneList;
  }

  @override
  Future<String> getAddressFromGeocode(LatLng latLng) async {
    String address = 'Unknown Location Found';
    Response response = await apiClient.getData(
        '${AppConstants.geocodeUri}?lat=${latLng.latitude}&lng=${latLng.longitude}',
        handleError: false);

    // Handle the case where response.body might be a string or already parsed JSON
    dynamic responseData = response.body;
    if (responseData is String) {
      try {
        responseData = jsonDecode(responseData);
      } catch (e) {
        debugPrint('Failed to decode JSON: $e');
        return address;
      }
    }

    if (response.statusCode == 200 &&
        responseData is Map<String, dynamic> &&
        responseData['status'] == 'OK') {
      if (responseData['results'] is List &&
          responseData['results'].isNotEmpty) {
        address = responseData['results'][0]['formatted_address'].toString();
      }
    } else {
      String errorMessage = 'Unknown error occurred';
      if (responseData is Map<String, dynamic> &&
          responseData['error_message'] != null) {
        errorMessage = responseData['error_message'].toString();
      }
      showCustomSnackBar(errorMessage);
    }
    return address;
  }

  @override
  Future<List<PredictionModel>> searchLocation(String text) async {
    List<PredictionModel> predictionList = [];
    Response response = await apiClient.getData(
        '${AppConstants.searchLocationUri}?search_text=$text',
        handleError: false);
    if (response.statusCode == 200) {
      predictionList = [];

      // Handle the case where response.body might be a string or already parsed JSON
      dynamic responseData = response.body;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (e) {
          debugPrint('Failed to decode JSON: $e');
          return predictionList;
        }
      }

      // Handle the suggestions array safely
      if (responseData is Map<String, dynamic> &&
          responseData['suggestions'] is List) {
        for (var prediction in responseData['suggestions']) {
          predictionList.add(PredictionModel.fromJson(prediction));
        }
      }
    } else {
      // Handle error response body safely
      dynamic errorData = response.body;
      if (errorData is String) {
        try {
          errorData = jsonDecode(errorData);
        } catch (e) {
          showCustomSnackBar(response.bodyString);
          return predictionList;
        }
      }
      showCustomSnackBar(errorData['error_message'] ?? response.bodyString);
    }
    return predictionList;
  }

  @override
  Future<Response?> getPlaceDetails(String? placeID) async {
    Response response = await apiClient
        .getData('${AppConstants.placeDetailsUri}?placeid=$placeID');
    return response;
  }

  @override
  Future<Response> getZone(String lat, String lng) async {
    return await apiClient.getData('${AppConstants.zoneUri}?lat=$lat&lng=$lng');
  }

  @override
  Future<bool> saveUserAddress(String address, List<int>? zoneIDs) async {
    apiClient.updateHeader(
        sharedPreferences.getString(AppConstants.token),
        sharedPreferences.getString(AppConstants.languageCode),
        null,
        sharedPreferences.getString(AppConstants.type));
    return await sharedPreferences.setString(AppConstants.userAddress, address);
  }

  @override
  String? getUserAddress() {
    return sharedPreferences.getString(AppConstants.userAddress);
  }

  @override
  Future<List<ModuleModel>?> getModules(int? zoneId) async {
    List<ModuleModel>? moduleList;
    Response response =
        await apiClient.getData('${AppConstants.modulesUri}?zone_id=$zoneId');
    if (response.statusCode == 200) {
      moduleList = [];

      // Handle the case where response.body might be a string or already parsed JSON
      dynamic responseData = response.body;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (e) {
          debugPrint('Failed to decode JSON: $e');
          return null;
        }
      }

      // Handle both single module object and array of modules
      if (responseData is List) {
        // If it's already an array, process each item
        for (var storeCategory in responseData) {
          moduleList.add(ModuleModel.fromJson(storeCategory));
        }
      } else if (responseData is Map<String, dynamic>) {
        // If it's a single module object, add it to the list
        moduleList.add(ModuleModel.fromJson(responseData));
      }
    }
    return moduleList;
  }

  @override
  Future<bool> checkInZone(String? lat, String? lng, int zoneId) async {
    Response response = await apiClient.getData(
        '${AppConstants.checkZoneUri}?lat=$lat&lng=$lng&zone_id=$zoneId');

    // Handle the case where response.body might be a string or already parsed JSON
    dynamic responseData = response.body;
    if (responseData is String) {
      try {
        responseData = jsonDecode(responseData);
      } catch (e) {
        debugPrint('Failed to decode JSON: $e');
        return false;
      }
    }

    if (response.statusCode == 200) {
      // Handle boolean response safely
      if (responseData is bool) {
        return responseData;
      } else if (responseData is Map<String, dynamic> &&
          responseData['success'] is bool) {
        return responseData['success'];
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }
}
