import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class BluetoothSetupScreen extends StatefulWidget {
  const BluetoothSetupScreen({super.key});

  @override
  State<BluetoothSetupScreen> createState() => _BluetoothSetupScreenState();
}

class _BluetoothSetupScreenState extends State<BluetoothSetupScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  BluetoothConnection? _connection;
  bool _isConnecting = false;
  bool _isConnected = false;
  String _statusText = "Belum terhubung ke ESP32";

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  void dispose() {
    _connection?.dispose();
    _ssidController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  Future<void> _connectToESP() async {
    setState(() {
      _isConnecting = true;
      _statusText = "Mencari perangkat Bluetooth...";
    });

    try {
      // Dapatkan perangkat yang sudah dipasangkan (paired)
      List<BluetoothDevice> devices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
          
      // Cari yang bernama ESP32-Setup (dari Arduino code)
      BluetoothDevice? espDevice;
      for (var device in devices) {
        if (device.name == "ESP32-Setup") {
          espDevice = device;
          break;
        }
      }

      if (espDevice == null) {
        setState(() {
          _statusText =
              "ESP32-Setup tidak ditemukan! Pastikan sudah di-Pair di pengaturan Bluetooth HP Anda.";
          _isConnecting = false;
        });
        return;
      }

      setState(() {
        _statusText = "Menghubungkan ke ${espDevice!.name}...";
      });

      _connection = await BluetoothConnection.toAddress(espDevice.address);
      setState(() {
        _isConnected = true;
        _isConnecting = false;
        _statusText = "✅ Berhasil terhubung ke ESP32 via Bluetooth!";
      });

      // Dengarkan balasan dari ESP32 (STATUS:CONNECTED, dll)
      _connection!.input!.listen((Uint8List data) {
        String response = ascii.decode(data).trim();
        if (response.isNotEmpty) {
          setState(() {
            _statusText = "Balasan ESP32: $response";
          });
          if (response == "STATUS:CONNECTED") {
            // Berhasil!
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('WiFi Berhasil Tersambung di ESP32!'),
                backgroundColor: AppTheme.accentPrimary,
              ),
            );
          }
        }
      }).onDone(() {
        setState(() {
          _isConnected = false;
          _statusText = "Koneksi Bluetooth terputus.";
        });
      });
      
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _isConnected = false;
        _statusText = "Gagal terhubung: $e";
      });
    }
  }

  void _sendWifiConfig() {
    if (_connection == null || !_connection!.isConnected) {
      setState(() {
        _statusText = "Harap hubungkan ke ESP32 terlebih dahulu.";
      });
      return;
    }

    final ssid = _ssidController.text.trim();
    final pass = _passController.text.trim();

    if (ssid.isEmpty) {
      setState(() {
        _statusText = "SSID WiFi tidak boleh kosong!";
      });
      return;
    }

    setState(() {
      _statusText = "Mengirim konfigurasi WiFi ke ESP32...";
    });

    String command = "WIFI:$ssid,$pass\n";
    _connection!.output.add(ascii.encode(command));
    _connection!.output.allSent.then((_) {
      setState(() {
        _statusText = "Terkirim! Menunggu balasan dari ESP32...";
      });
    });
  }
  
  void _resetWifi() {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(ascii.encode("RESET\n"));
      setState(() {
        _statusText = "Perintah RESET dikirim.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Setup WiFi (Bluetooth)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    _isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                    size: 48,
                    color: _isConnected ? AppTheme.accentPrimary : Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isConnected ? AppTheme.accentPrimary : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isConnecting || _isConnected ? null : _connectToESP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    ),
                    child: _isConnecting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isConnected ? 'Terhubung' : 'Hubungkan ke ESP32'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Konfigurasi Jaringan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ssidController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Nama WiFi (SSID)",
                      labelStyle: const TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppTheme.accentPrimary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Password WiFi",
                      labelStyle: const TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppTheme.accentPrimary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isConnected ? _sendWifiConfig : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Kirim ke ESP32'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _isConnected ? _resetWifi : null,
                        tooltip: "Reset WiFi di ESP32",
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.danger.withValues(alpha: 0.2),
                          foregroundColor: AppTheme.danger,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                        ),
                        icon: const Icon(Icons.wifi_off),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
