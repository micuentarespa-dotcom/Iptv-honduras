import 'package:flutter/material';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isDemoLoading = false;
  String _hardwareIdPreview = 'Cargando ID Dispositivo...';

  @override
  void initState() {
    super.initState();
    _loadDevicePreview();
  }

  void _loadDevicePreview() async {
    final info = await DeviceService.getDeviceInfo();
    setState(() {
      _hardwareIdPreview = '${info['deviceName']} (ID: ${info['hardwareId']!.substring(0, 8)}...)';
    });
  }

  void _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Por favor ingresa tu usuario y contraseña.');
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService.login(_usernameController.text, _passwordController.text);
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: result['user'])),
      );
    } else {
      _showSnackBar(result['message'] ?? 'Error al iniciar sesión.');
    }
  }

  void _handleRequestDemo() async {
    setState(() => _isDemoLoading = true);
    final result = await ApiService.request5HourDemo();
    setState(() => _isDemoLoading = false);

    if (result['success'] == true) {
      if (!mounted) return;
      _showSnackBar('¡Demo de 5 Horas Activada!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: result['user'])),
      );
    } else {
      _showSnackBar(result['message'] ?? 'Dispositivo no elegible para demo.');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.blueAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Slate Navy
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 20, spreadRadius: 2)
              ],
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Banner / Logo IPTV Honduras
                const Icon(Icons.tv_rounded, size: 60, color: Colors.blueAccent),
                const SizedBox(height: 10),
                const Text(
                  'IPTV HONDURAS 🇭🇳',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const Text(
                  'Gestión y Reproducción HD/4K',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 25),

                // Campo Usuario
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                    labelText: 'Usuario IPTV',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),

                // Campo Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // Botón Iniciar Sesión
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                        : const Text('INGRESAR A MI CUENTA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 15),

                const Divider(color: Colors.white24),
                const SizedBox(height: 10),

                // BOTÓN PROMINENTE 1-CLIC SOLICITAR DEMO 5 HORAS
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '⚡ ¿No tienes una cuenta aún?',
                        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: _isDemoLoading ? null : _handleRequestDemo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[700],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: _isDemoLoading
                              ? const SizedBox.shrink()
                              : const Icon(Icons.flash_on_rounded, color: Colors.black),
                          label: _isDemoLoading
                              ? const SpinKitThreeBounce(color: Colors.black, size: 18)
                              : const Text(
                                  'PROBAR GRATIS (5 HORAS)',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Device ID info badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phonelink_lock, size: 14, color: Colors.white38),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _hardwareIdPreview,
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
