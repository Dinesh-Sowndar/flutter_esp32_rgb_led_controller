import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rgb_led_controller/services/bluetooth_service.dart';

class DeviceListModal extends StatefulWidget {
  final Function(BluetoothDevice) onDeviceSelected;

  const DeviceListModal({super.key, required this.onDeviceSelected});

  @override
  State<DeviceListModal> createState() => _DeviceListModalState();
}

class _DeviceListModalState extends State<DeviceListModal> {
  final MyBluetoothService _bluetoothManager = MyBluetoothService();

  bool _isScanning = false;
  List<BluetoothDevice> _devices = [];
  @override
  void initState() {
    super.initState();
    _scanDevices();
  }

  Future<void> _scanDevices() async {
    setState(() => _isScanning = true);
    try {
      _devices = await _bluetoothManager.scanDevices();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error scanning: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Available Devices',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child:
              _isScanning
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(device.name ?? 'Unknown Device'),
                        subtitle: Text(device.remoteId.toString()),
                        trailing:
                            _bluetoothManager.connectedDevice?.remoteId ==
                                    device.remoteId
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                        onTap: () {
                          widget.onDeviceSelected(device);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _scanDevices,
            child: const Text('Scan Again'),
          ),
        ),
      ],
    );
  }
}
