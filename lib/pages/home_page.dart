import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/device.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Device> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevicesFromFirebase();
  }

  Future<void> _loadDevicesFromFirebase() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('devices')
          .get();

      final devicesFromFirebase = snapshot.docs.map((doc) {
        final data = doc.data();
        final iconCodePoint = data['icon'];
        return Device(
          id: doc.id,
          name: (data['name'] ?? 'Sin nombre') as String,
          room: (data['room'] ?? 'Sin habitación') as String,
          isOn: data['isOn'] ?? false,
          powerConsumption: (data['powerConsumption'] ?? 0).toDouble(),
          icon: IconData(
            iconCodePoint is int ? iconCodePoint : Icons.lightbulb.codePoint,
            fontFamily: 'MaterialIcons',
          ),
        );
      }).toList();

      print('Dispositivos cargados: ${devicesFromFirebase.length}');

      setState(() {
        _devices = devicesFromFirebase;
      });
    } catch (e) {
      debugPrint('Error cargando dispositivos: $e');
    }
  }

  Future<void> _addDeviceToFirebase(Device device) async {
    try {
      await FirebaseFirestore.instance.collection('devices').add({
        'name': device.name,
        'room': device.room,
        'isOn': device.isOn,
        'powerConsumption': device.powerConsumption,
        'icon': device.icon.codePoint,
      });
      await _loadDevicesFromFirebase(); // recargar la lista para actualizar UI
    } catch (e) {
      debugPrint('Error agregando dispositivo: $e');
    }
  }

  Future<void> _deleteDeviceFromFirebase(String deviceId) async {
    try {
      await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .delete();
      await _loadDevicesFromFirebase(); // recargar lista para actualizar UI
    } catch (e) {
      debugPrint('Error borrando dispositivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al borrar dispositivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int activeDevices = _devices.where((d) => d.isOn).length;
    double totalConsumption = _devices
        .where((d) => d.isOn)
        .fold(0.0, (sum, d) => sum + d.powerConsumption);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        backgroundColor: const Color(0xFF3282B8),
        tooltip: 'Agregar dispositivo',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildQuickStats(activeDevices, totalConsumption),
              const SizedBox(height: 24),
              _buildRecentDevices(),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDeviceDialog() {
    final formKey = GlobalKey<FormState>();
    String? name;
    String? room;
    double? powerConsumption;
    bool isOn = false;
    IconData selectedIcon = Icons.lightbulb;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Agregar dispositivo'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese un nombre';
                          }
                          return null;
                        },
                        onSaved: (value) => name = value,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Habitación',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese la habitación';
                          }
                          return null;
                        },
                        onSaved: (value) => room = value,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Consumo (W)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el consumo';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Ingrese un número válido';
                          }
                          return null;
                        },
                        onSaved: (value) =>
                            powerConsumption = double.tryParse(value!),
                      ),
                      SwitchListTile(
                        title: const Text('¿Está encendido?'),
                        value: isOn,
                        onChanged: (value) {
                          setStateDialog(() {
                            isOn = value;
                          });
                        },
                      ),
                      DropdownButton<IconData>(
                        value: selectedIcon,
                        items: const [
                          DropdownMenuItem(
                            value: Icons.lightbulb,
                            child: Text('Lámpara'),
                          ),
                          DropdownMenuItem(
                            value: Icons.tv,
                            child: Text('Televisor'),
                          ),
                          DropdownMenuItem(
                            value: Icons.toys,
                            child: Text('Ventilador'),
                          ),
                        ],
                        onChanged: (icon) {
                          if (icon != null) {
                            setStateDialog(() {
                              selectedIcon = icon;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();

                      if (name != null &&
                          room != null &&
                          powerConsumption != null) {
                        final newDevice = Device(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name!,
                          room: room!,
                          isOn: isOn,
                          powerConsumption: powerConsumption!,
                          icon: selectedIcon,
                        );
                        _addDeviceToFirebase(newDevice);
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Bienvenido',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              'Smart Control',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _signOut,
            ),
            const CircleAvatar(
              backgroundColor: Color(0xFF3282B8),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildQuickStats(int activeDevices, double totalConsumption) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Dispositivos Activos',
            value: '$activeDevices',
            icon: Icons.devices,
            color: const Color(0xFF3282B8),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Consumo Actual',
            value: '${totalConsumption.toStringAsFixed(0)}W',
            icon: Icons.flash_on,
            color: const Color(0xFF0F4C75),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecentDevices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dispositivos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _devices.length,
          itemBuilder: (context, index) {
            final device = _devices[index];
            return _buildDeviceCard(device);
          },
        ),
      ],
    );
  }

  Widget _buildDeviceCard(Device device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: device.isOn
                  ? const Color(0xFF3282B8)
                  : Colors.grey.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(device.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  device.room,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: device.isOn,
            onChanged: (value) async {
              setState(() {
                device.isOn = value;
              });
              await FirebaseFirestore.instance
                  .collection('devices')
                  .doc(device.id)
                  .update({'isOn': value});
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              _confirmDeleteDevice(device);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDevice(Device device) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar borrado'),
          content: Text(
            '¿Seguro que quieres borrar el dispositivo "${device.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteDeviceFromFirebase(device.id);
              },
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );
  }
}
