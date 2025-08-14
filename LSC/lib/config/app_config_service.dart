import 'package:shared_preferences/shared_preferences.dart';

class AppConfigService {
  static const String _layerKey = 'server_layer';
  static const String _parentIpKey = 'parent_ip';
  static const String _licenseKey = 'license_key';
  static const String _isConfiguredKey = 'is_configured';
  
  SharedPreferences? _prefs;

  static final AppConfigService _instance = AppConfigService._internal();
  factory AppConfigService() => _instance;
  AppConfigService._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool isConfigured() => _prefs?.getBool(_isConfiguredKey) ?? false;
  int getLayer() => _prefs?.getInt(_layerKey) ?? -1;
  String? getParentIp() => _prefs?.getString(_parentIpKey);
  String? getLicenseKey() => _prefs?.getString(_licenseKey);
  bool isLayer0() => getLayer() == 0;

  Future<void> saveConfiguration({
    required int layer,
    String? parentIp,
    required String licenseKey,
  }) async {
    await _prefs?.setInt(_layerKey, layer);
    if (parentIp != null) {
      await _prefs?.setString(_parentIpKey, parentIp);
    } else {
      await _prefs?.remove(_parentIpKey);
    }
    await _prefs?.setString(_licenseKey, licenseKey);
    await _prefs?.setBool(_isConfiguredKey, true);
  }
}