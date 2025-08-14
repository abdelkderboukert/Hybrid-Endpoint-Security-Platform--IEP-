import 'package:dio/dio.dart';
import 'package:resilient_sync_app/config/app_config_service.dart';
import 'package:resilient_sync_app/database/models/sync_action.dart';

class ApiClientService {
  late final Dio _dio;
  final String _cloudBaseUrl = "https://your-django-api.com/api"; 

  ApiClientService() {
    _dio = Dio();
    // Get the license key from the saved configuration
    final licenseKey = AppConfigService().getLicenseKey();

    // Set up default headers for all requests to the cloud
    _dio.options.headers['Content-Type'] = 'application/json';

    // *** THIS IS THE KEY PART ***
    // Use the license key for Bearer token authentication with the cloud.
    if (licenseKey != null) {
      _dio.options.headers['Authorization'] = 'Bearer $licenseKey';
    }
  }
  
  // The "Bypass" function
  Future<bool> sendToCloud(SyncAction action) async {
    try {
      final response = await _dio.post(
        '$_cloudBaseUrl/sync', // A generic endpoint on your Django server
        data: {
          'actionType': action.actionType,
          'payload': action.payload,
          'localId': action.localId,
        },
      );
      // The cloud should return 200 or 201 on success
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Failed to send data to cloud: $e");
      return false;
    }
  }

  // Part of the "Sync Down" logic
  Future<Map<String, dynamic>?> fetchUpdatesFromCloud() async {
    try {
      final response = await _dio.get('$_cloudBaseUrl/updates'); // Endpoint to get all new data
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Failed to fetch updates from cloud: $e");
      return null;
    }
  }
}