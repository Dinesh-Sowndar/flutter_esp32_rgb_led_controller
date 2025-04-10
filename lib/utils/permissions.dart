import 'package:permission_handler/permission_handler.dart';

Future<void> requestBluetoothPermissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.location,
    Permission.locationWhenInUse,
  ].request();

  await Permission.bluetoothAdvertise.request(); // Always safe
}
