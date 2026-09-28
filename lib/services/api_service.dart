import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'device_service.dart';

class ApiService {
  // Dirección IP / Dominio del backend en Honduras
  static const String baseUrl = 'http://10.0.2.2:4000'; // Usa localhost:4000 en Windows/Browser o 10.0.2.2 para emulador Android

  /// Autenticación de usuario con envío automático del Hardware Device ID
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final deviceInfo = await DeviceService.getDeviceInfo();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'hardwareId': deviceInfo['hardwareId'],
          'deviceName': deviceInfo['deviceName'],
          'deviceModel': deviceInfo['deviceModel'],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final user = UserModel.fromJson(
          data['client'],
          deviceInfo['hardwareId']!,
          deviceInfo['deviceName']!,
        );

        return {'success': true, 'user': user, 'raw': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error de autenticación.',
          'code': data['code']
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'No se pudo conectar con el servidor de IPTV Honduras.'};
    }
  }

  /// Solicitar Demo Gratuita de 5 Horas en 1-Clic con protección Anti-Abuso
  static Future<Map<String, dynamic>> request5HourDemo() async {
    final deviceInfo = await DeviceService.getDeviceInfo();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/demos/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'hardwareId': deviceInfo['hardwareId'],
          'deviceName': deviceInfo['deviceName'],
          'deviceModel': deviceInfo['deviceModel'],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Auto-login con las credenciales demo generadas
        final demoDetails = data['demoDetails'];
        return await login(demoDetails['username'], demoDetails['password']);
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Este dispositivo ya utilizó su demo gratuita.',
          'code': data['code']
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error al procesar la demo. Revisa tu conexión a Internet.'};
    }
  }
}
