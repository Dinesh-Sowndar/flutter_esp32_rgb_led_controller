import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rgb_led_controller/package/color_picker.dart';
import 'package:rgb_led_controller/package/utils.dart';
import 'package:rgb_led_controller/services/bluetooth_service.dart';
import 'package:rgb_led_controller/utils/permissions.dart';
import 'package:rgb_led_controller/widgets/color_palette_grid.dart';
import 'package:rgb_led_controller/widgets/color_swatches_grid.dart';
import 'package:rgb_led_controller/widgets/device_list_modal.dart';
import 'package:rgb_led_controller/widgets/section_header.dart';

class ControllerPage extends StatefulWidget {
  const ControllerPage({super.key});

  @override
  State<ControllerPage> createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  final MyBluetoothService _bluetoothManager = MyBluetoothService();
  Color pickerColor = const Color(0xff0000ff);
  bool _isBluetoothConnected = false;
  Timer? _debounce;

  final List<Color> colors = [
    const Color(0xff0000ff), // Blue
    const Color(0xffff0000), // Red
    const Color(0xff00ff00), // Green
    const Color(0xffffffff), // White
    const Color(0xffffff00), // Yellow
    const Color(0xffff00ff), // Magenta
    const Color(0xffff8000), // Orange
    const Color(0xff8000ff), // Purple
  ];

  final List<Map<String, String>> colorPalettes = [
    {'label': 'Rainbow', 'value': '1'},
    {'label': 'Pastel', 'value': '2'},
    {'label': 'Warm', 'value': '3'},
    {'label': 'Cool', 'value': '4'},
  ];

  final List<Map<String, String>> animations = [
    {'label': 'Pulse', 'value': '5'},
    {'label': 'Rainbow', 'value': '6'},
    {'label': 'Strobe', 'value': '7'},
    {'label': 'Fade', 'value': '8'},
  ];

  String? selectedValue;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initBluetooth() async {
    await requestBluetoothPermissions();
    if (!await _bluetoothManager.checkBluetooth()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth not available')),
        );
      }
      return;
    }

    await _bluetoothManager.enableBluetooth();
  }

  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
      selectedValue = null;
    });
    _sendData(toHexColor(color));
  }

  Future<void> _sendData(String data) async {
    if (_bluetoothManager.isConnected) {
      await _bluetoothManager.sendData(data);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to any device')),
      );
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await _bluetoothManager.connectToDevice(device);
      setState(() => _isBluetoothConnected = true);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connected to ${device.name}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection failed: $e')));
      }
    }
  }

  Future<void> _disconnect() async {
    await _bluetoothManager.disconnect();
    setState(() => _isBluetoothConnected = false);
  }

  void _showDeviceList() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return DeviceListModal(onDeviceSelected: _connectToDevice);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        useWhiteForeground(pickerColor) ? Colors.white : Colors.black;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness:
            useWhiteForeground(pickerColor)
                ? Brightness.dark
                : Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("RGB Controller"),
          backgroundColor: pickerColor,
          foregroundColor: foregroundColor,
          actions: [
            IconButton(
              icon: Icon(
                _isBluetoothConnected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth,
                color: _isBluetoothConnected ? Colors.green : foregroundColor,
              ),
              onPressed: () async {
                if (_isBluetoothConnected) {
                  _disconnect();
                } else {
                  await _initBluetooth();
                  _showDeviceList();
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SizedBox(height: 15),
                HueRingPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (color) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 100), () {
                      changeColor(color);
                    });
                  },
                  hueRingStrokeWidth: 25,
                  colorPickerHeight: MediaQuery.of(context).size.width * 0.75,
                ),
                const SizedBox(height: 25),

                ColorSwatchesGrid(colors: colors, onSelect: changeColor),

                const SizedBox(height: 30),
                SectionHeader(title: "Color Palettes"),
                const SizedBox(height: 15),

                OptionGrid(
                  options: colorPalettes,
                  selectedValue: selectedValue,
                  onSelected: (value) {
                    setState(() => selectedValue = value);
                    _sendData(value);
                  },
                ),

                const SizedBox(height: 30),
                SectionHeader(title: "Animations"),
                const SizedBox(height: 15),
                OptionGrid(
                  options: animations,
                  selectedValue: selectedValue,
                  onSelected: (value) {
                    setState(() => selectedValue = value);
                    _sendData(value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
