// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:tamam_business/api/api_checker.dart';
import 'package:tamam_business/common/models/error_response.dart';
import 'package:tamam_business/util/app_constants.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static const String noInternetMessage =
      'Connection to API server failed due to internet connection';
  final int timeoutInSeconds = AppConstants.defaultTimeoutSeconds;

  String? token;
  String? type;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);
    type = sharedPreferences.getString(AppConstants.type);
    debugPrint('🎯 [TamamBusiness] ApiClient initialized with base URL: $appBaseUrl');
    debugPrint('Token: $token');
    debugPrint('Type: $type');
    updateHeader(token, sharedPreferences.getString(AppConstants.languageCode),
        null, type);
  }

  void updateHeader(
      String? token, String? languageCode, int? moduleID, String? type) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey:
          languageCode ?? AppConstants.languages[0].languageCode!,
      AppConstants.moduleId: moduleID != null ? moduleID.toString() : '',
      'Authorization': 'Bearer $token',
      'vendorType': type ?? '',
    };
  }

  Future<Response> _executeWithRetry(Future<http.Response> Function() httpCall, String uri) async {
    int attempts = 0;
    const maxAttempts = AppConstants.maxRetries + 1;
    
    while (attempts < maxAttempts) {
      try {
        attempts++;
        debugPrint('====> API Call attempt $attempts/$maxAttempts: $uri');
        
        http.Response response = await httpCall().timeout(Duration(seconds: timeoutInSeconds));
        return handleResponse(response, uri, true);
        
      } catch (e) {
        debugPrint('====> API Error attempt $attempts/$maxAttempts for $uri: ${e.toString()}');
        
        if (attempts >= maxAttempts) {
          // Final attempt failed
          if (e is TimeoutException || e.toString().contains('timeout')) {
            return const Response(statusCode: 408, statusText: 'Request timeout - please check your connection');
          } else if (e is SocketException || e.toString().contains('socket') || e.toString().contains('network')) {
            return const Response(statusCode: 1, statusText: noInternetMessage);
          } else {
            return Response(statusCode: 500, statusText: 'Server error: ${e.toString()}');
          }
        }
        
        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(milliseconds: 1000 * attempts));
      }
    }
    
    return const Response(statusCode: 1, statusText: noInternetMessage);
  }

  Future<Response> getData(String uri,
      {Map<String, dynamic>? query,
      Map<String, String>? headers,
      bool handleError = true}) async {
    debugPrint('====> API Call: $appBaseUrl$uri\nHeader: $_mainHeaders');
    return await _executeWithRetry(
      () => http.get(
        Uri.parse(appBaseUrl + uri),
        headers: headers ?? _mainHeaders,
      ),
      uri,
    );
  }

  Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers, bool handleError = true}) async {
    debugPrint('====> API Call: $appBaseUrl$uri\nHeader: $_mainHeaders');
    debugPrint('====> API Body: $body');
    return await _executeWithRetry(
      () => http.post(
        Uri.parse(appBaseUrl + uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ),
      uri,
    );
  }

  Future<Response> postMultipartData(
      String uri, Map<String, String> body, List<MultipartBody> multipartBody,
      {List<MultipartDocument>? multipartDocument,
      Map<String, String>? headers,
      bool handleError = true}) async {
    try {
      debugPrint('====> API Call: $appBaseUrl$uri\nHeader: $_mainHeaders');
      debugPrint(
          '====> API Body: $body with ${multipartBody.length} and multipart ${multipartDocument?.length}');
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      request.headers.addAll(headers ?? _mainHeaders);
      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          if (foundation.kIsWeb) {
            Uint8List list = await multipart.file!.readAsBytes();
            http.MultipartFile part = http.MultipartFile(
              multipart.key,
              multipart.file!.readAsBytes().asStream(),
              list.length,
              filename: basename(multipart.file!.path),
              contentType: MediaType('image', 'jpg'),
            );
            request.files.add(part);
          } else {
            File file = File(multipart.file!.path);
            request.files.add(http.MultipartFile(
              multipart.key,
              file.readAsBytes().asStream(),
              file.lengthSync(),
              filename: file.path.split('/').last,
            ));
          }
        }
      }

      if (multipartDocument != null && multipartDocument.isNotEmpty) {
        for (MultipartDocument file in multipartDocument) {
          File other = File(file.file!.files.single.path!);
          Uint8List list0 = await other.readAsBytes();
          var part = http.MultipartFile(
              file.key, other.readAsBytes().asStream(), list0.length,
              filename: basename(other.path));
          request.files.add(part);
        }
      }

      request.fields.addAll(body);
      http.Response response =
          await http.Response.fromStream(await request.send());
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      debugPrint('====> API Call: $appBaseUrl$uri\nHeader: $_mainHeaders');
      debugPrint('====> API Body: $body');
      http.Response response = await http
          .put(
            Uri.parse(appBaseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      debugPrint('====> API Call: $appBaseUrl$uri\nHeader: $_mainHeaders');
      http.Response response = await http
          .delete(
            Uri.parse(appBaseUrl + uri),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(
      http.Response response, String uri, bool handleError) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {}
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      if (response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: errorResponse.errors![0].message);
      } else if (response0.body.toString().startsWith('{message')) {
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: response0.body['message']);
      }
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = const Response(statusCode: 0, statusText: noInternetMessage);
    }
    debugPrint(
        '====> API Response: [${response0.statusCode}] $uri\n${response0.body}');
    if (handleError) {
      if (response0.statusCode == 200) {
        return response0;
      } else {
        ApiChecker.checkApi(response0);
        return const Response();
      }
    } else {
      return response0;
    }
  }
}

class MultipartBody {
  String key;
  XFile? file;

  MultipartBody(this.key, this.file);
}

class MultipartDocument {
  String key;
  FilePickerResult? file;
  MultipartDocument(this.key, this.file);
}
