import 'package:demo/providers/valentine_provider.dart';
import 'package:flutter/material.dart';
import 'package:demo/models/device.dart';
import 'package:demo/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddDevice extends StatefulWidget {
  const AddDevice({super.key});

  @override
  State<AddDevice> createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
  bool _hasDevice = false;

  @override
  void initState() {
    super.initState();
    _loadDevicesFromFirestore();
  }

  Future<void> _loadDevicesFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Lắng nghe thay đổi từ Firestore
      _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null && data.containsKey('device')) {
            final deviceData = data['device'] as Map<String, dynamic>;
            setState(() {
              _devices.clear(); // Xóa danh sách cũ
              _devices.add(Device(
                id: deviceData['id'],
                name: deviceData['name'],
                type: deviceData['type'],
                isConnected: deviceData['isConnected'] ?? false,
              ));
              _hasDevice = true;
            });
          } else {
            setState(() {
              _devices.clear();
              _hasDevice = false;
            });
          }
        }
      });
    }
  }

  Future<void> _addDevice() async {
    if (_hasDevice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only add one device')),
      );
      return;
    }

    if (_deviceNameController.text.isEmpty ||
        _deviceIdController.text.isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // 1. Kiểm tra device có tồn tại trong collection devices
        final deviceDoc = await _firestore
            .collection('devices')
            .doc('device_type')
            .collection(_selectedType)
            .doc(_deviceIdController.text)
            .get();

        if (!deviceDoc.exists) {
          throw 'Device not found in database';
        }

        // 2. Thêm thông tin device vào user data
        await _firestore.collection('users').doc(user.uid).update({
          'device': {
            'id': _deviceIdController.text,
            'name': _deviceNameController.text,
            'type': _selectedType,
            'isConnected': false,
            'addedAt': Timestamp.now(),
          }
        });

        _deviceNameController.clear();
        _deviceIdController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _updateDeviceConnection(Device device, bool isConnected) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'device.isConnected': isConnected,
      });

      setState(() {
        final index = _devices.indexWhere((d) => d.id == device.id);
        if (index != -1) {
          _devices[index] = Device(
            id: device.id,
            name: device.name,
            type: device.type,
            isConnected: isConnected,
          );
        }
      });
    }
  }

  Future<void> _removeDevice(Device device) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'device': FieldValue.delete(),
      });
      setState(() {
        _devices.remove(device);
        _hasDevice = false;
      });
    }
  }

  void _showAddDeviceDialog() {
    if (_hasDevice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only add one device'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
                _addDevice(); // Remove Navigator.pop here
                Navigator.pop(context);
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    device.isConnected ? Icons.link : Icons.link_off,
                    color: device.isConnected
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  onPressed: () =>
                      _updateDeviceConnection(device, !device.isConnected),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => _removeDevice(device),
                ),
              ],
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
    final isValentine = context.watch<ValentineProvider>().isValentineMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Device',
          style: TextStyle(
            color: isValentine ? Colors.pink[400] : null,
          ),
        ),
      ),
      body: _buildDeviceList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDeviceDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Device'),
        backgroundColor: isValentine ? Colors.pink[300] : null,
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
