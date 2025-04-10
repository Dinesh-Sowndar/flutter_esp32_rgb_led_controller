import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MyBluetoothService {
  static final MyBluetoothService _instance = MyBluetoothService._internal();
  factory MyBluetoothService() => _instance;
  MyBluetoothService._internal();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;

  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectedDevice != null;

  Future<bool> checkBluetooth() async {
    return await FlutterBluePlus.isAvailable;
  }

  Future<void> enableBluetooth() async {
    if (!await FlutterBluePlus.isOn) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<List<BluetoothDevice>> scanDevices() async {
    List<BluetoothDevice> devices = [];
    bool isScanning = false;

    try {
      FlutterBluePlus.scanResults.listen((results) {
        devices = results.map((r) => r.device).toList();
      });

      // Start scan
      isScanning = true;
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        androidUsesFineLocation: false,
      );

      // Wait for results
      await Future.delayed(const Duration(seconds: 4));

      return devices;
    } finally {
      if (isScanning) {
        await FlutterBluePlus.stopScan();
      }
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
    _connectedDevice = device;

    List<BluetoothService> services = await device.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        _characteristic = characteristic;
        break;
      }
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _characteristic = null;
    }
  }

  Future<void> sendData(String data) async {
    if (_characteristic == null) return;

    try {
      await _characteristic!.write(data.codeUnits);
    } catch (e) {
      print("Error sending data: $e");
    }
  }
}
