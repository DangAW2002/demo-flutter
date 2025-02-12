import 'package:flutter/material.dart';
import 'package:demo/models/device.dart';
import 'package:demo/constants/colors.dart';

class AddDevice extends StatefulWidget {
  const AddDevice({super.key});

  @override
  State<AddDevice> createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  final _deviceNameController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final List<Device> _devices = [];
  final List<String> _deviceTypes = [
    'Smartwatch',
    'Heart Rate Monitor',
    'Blood Pressure Monitor',
    'Scale'
  ];
  String _selectedType = 'Smartwatch';

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _deviceNameController,
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                  hintText: 'Enter device name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _deviceIdController,
                decoration: const InputDecoration(
                  labelText: 'Device ID',
                  hintText: 'Enter device ID',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Device Type',
                ),
                items: _deviceTypes.map((String type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_deviceNameController.text.isNotEmpty &&
                    _deviceIdController.text.isNotEmpty) {
                  setState(() {
                    _devices.add(Device(
                      id: _deviceIdController.text,
                      name: _deviceNameController.text,
                      type: _selectedType,
                    ));
                  });
                  Navigator.pop(context);
                  _deviceNameController.clear();
                  _deviceIdController.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeviceList() {
    if (_devices.isEmpty) {
      return const Center(
        child: Text(
          'No devices added yet',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(_getDeviceIcon(device.type)),
            title: Text(device.name),
            subtitle: Text('ID: ${device.id}\nType: ${device.type}'),
            trailing: IconButton(
              icon: Icon(
                device.isConnected ? Icons.link : Icons.link_off,
                color: device.isConnected ? AppColors.success : AppColors.error,
              ),
              onPressed: () {
                setState(() {
                  final updatedDevice = Device(
                    id: device.id,
                    name: device.name,
                    type: device.type,
                    isConnected: !device.isConnected,
                  );
                  _devices[index] = updatedDevice;
                });
              },
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  IconData _getDeviceIcon(String type) {
    switch (type) {
      case 'Smartwatch':
        return Icons.watch;
      case 'Heart Rate Monitor':
        return Icons.favorite;
      case 'Blood Pressure Monitor':
        return Icons.speed;
      case 'Scale':
        return Icons.monitor_weight;
      default:
        return Icons.devices_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Device'),
      ),
      body: _buildDeviceList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDeviceDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Device'),
      ),
    );
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }
}
