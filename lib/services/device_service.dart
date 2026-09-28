import 'dart:io';
import 'package:device_info_plus/device_info_plus';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DeviceService {
  static const String _storageKey = 'hn_iptv_hardware_id';

  /// Obtiene o genera el Hardware Device ID único e inmutable del dispositivo
  static Future<Map<String, String>> getDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    String hardwareId = prefs.getString(_storageKey) ?? '';
    String deviceName = 'Dispositivo IPTV';
    String deviceModel = 'Android TV / Mobile';

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
        deviceModel = androidInfo.model;
        
        // Usar androidId o fingerprint como base del Hardware ID
        String rawId = androidInfo.id.isNotEmpty ? androidInfo.id : androidInfo.fingerprint;
        hardwareId = md5.convert(utf8.encode(rawId)).toString();
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
        deviceModel = iosInfo.model;
        hardwareId = iosInfo.identifierForVendor ?? md5.convert(utf8.encode(iosInfo.name)).toString();
      } else if (Platform.isWindows) {
        WindowsDeviceInfo winInfo = await deviceInfo.windowsInfo;
        deviceName = winInfo.computerName;
        deviceModel = 'Windows PC';
        hardwareId = md5.convert(utf8.encode(winInfo.deviceId)).toString();
      }
    } catch (e) {
      if (hardwareId.isEmpty) {
        hardwareId = md5.convert(utf8.encode(DateTime.now().microsecondsSinceEpoch.toString())).toString();
      }
    }

    if (hardwareId.isEmpty) {
      hardwareId = md5.convert(utf8.encode('HN_IPTV_${DateTime.now().millisecondsSinceEpoch}')).toString();
    }

    // Persistir el ID generado
    await prefs.setString(_storageKey, hardwareId);

    return {
      'hardwareId': hardwareId,
      'deviceName': deviceName,
      'deviceModel': deviceModel,
    };
  }
}
