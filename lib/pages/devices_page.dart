import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/device.dart';

/// Página principal de la aplicación de control domótico
/// Permite gestionar dispositivos inteligentes del hogar
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Lista local que mantiene todos los dispositivos cargados desde Firebase
  List<Device> _devices = [];

  @override
  void initState() {
    super.initState();
    // Cargar dispositivos al inicializar el widget
    _loadDevicesFromFirebase();
  }

  /// Carga todos los dispositivos desde la colección 'devices' de Firebase
  /// Convierte los datos de Firestore en objetos Device y actualiza la UI
  Future<void> _loadDevicesFromFirebase() async {
    try {
      // Obtener snapshot de la colección completa
      final snapshot = await FirebaseFirestore.instance
          .collection('devices')
          .get();

      // Mapear documentos de Firestore a objetos Device
      final devicesFromFirebase = snapshot.docs.map((doc) {
        final data = doc.data();
        final iconCodePoint = data['icon'];

        return Device(
          id: doc.id, // ID único del documento
          name: (data['name'] ?? 'Sin nombre') as String, // Nombre con fallback
          room:
              (data['room'] ?? 'Sin habitación')
                  as String, // Habitación con fallback
          isOn: data['isOn'] ?? false, // Estado on/off con fallback
          powerConsumption: (data['powerConsumption'] ?? 0)
              .toDouble(), // Consumo energético
          // Crear IconData desde el codePoint almacenado, con fallback a bombilla
          icon: IconData(
            iconCodePoint is int ? iconCodePoint : Icons.lightbulb.codePoint,
            fontFamily: 'MaterialIcons',
          ),
        );
      }).toList();

      print('Dispositivos cargados: ${devicesFromFirebase.length}');

      // Actualizar estado local con los datos cargados
      setState(() {
        _devices = devicesFromFirebase;
      });
    } catch (e) {
      debugPrint('Error cargando dispositivos: $e');
    }
  }

  /// Añade un nuevo dispositivo a Firebase
  /// Después de añadirlo, recarga la lista para actualizar la UI
  Future<void> _addDeviceToFirebase(Device device) async {
    try {
      // Añadir documento a la colección con los datos del dispositivo
      await FirebaseFirestore.instance.collection('devices').add({
        'name': device.name,
        'room': device.room,
        'isOn': device.isOn,
        'powerConsumption': device.powerConsumption,
        'icon': device.icon.codePoint, // Guardar solo el código del icono
      });
      // Recargar lista para reflejar cambios
      await _loadDevicesFromFirebase();
    } catch (e) {
      debugPrint('Error agregando dispositivo: $e');
    }
  }

  /// Elimina un dispositivo de Firebase usando su ID
  /// Maneja errores mostrando SnackBar al usuario
  Future<void> _deleteDeviceFromFirebase(String deviceId) async {
    try {
      // Eliminar documento específico por ID
      await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .delete();
      // Recargar lista para reflejar cambios
      await _loadDevicesFromFirebase();
    } catch (e) {
      debugPrint('Error borrando dispositivo: $e');
      // Mostrar error al usuario con SnackBar
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
    // Calcular estadísticas en tiempo real
    int activeDevices = _devices.where((d) => d.isOn).length;
    double totalConsumption = _devices
        .where((d) => d.isOn)
        .fold(0.0, (sum, d) => sum + d.powerConsumption);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Tema oscuro
      // Botón flotante para añadir dispositivos
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
              _buildHeader(), // Header con saludo y botón logout
              const SizedBox(height: 24),
              _buildQuickStats(
                activeDevices,
                totalConsumption,
              ), // Estadísticas rápidas
              const SizedBox(height: 24),
              _buildRecentDevices(), // Lista de dispositivos
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra diálogo modal para añadir un nuevo dispositivo
  /// Incluye formulario con validaciones y preview del icono seleccionado
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
        // StatefulBuilder permite actualizar el diálogo internamente
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
                      // Campo nombre con validación requerida
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
                      // Campo habitación con validación requerida
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
                      // Campo consumo energético con validación numérica
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
                      // Switch para estado inicial del dispositivo
                      SwitchListTile(
                        title: const Text('¿Está encendido?'),
                        value: isOn,
                        onChanged: (value) {
                          setStateDialog(() {
                            isOn = value;
                          });
                        },
                      ),
                      // Dropdown para seleccionar tipo de dispositivo/icono
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
                    // Validar y guardar formulario
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();

                      // Verificar que todos los campos requeridos están presentes
                      if (name != null &&
                          room != null &&
                          powerConsumption != null) {
                        // Crear nuevo dispositivo con ID temporal basado en timestamp
                        final newDevice = Device(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name!,
                          room: room!,
                          isOn: isOn,
                          powerConsumption: powerConsumption!,
                          icon: selectedIcon,
                        );
                        // Añadir a Firebase y cerrar diálogo
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

  /// Construye el header superior con saludo, título y controles de usuario
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Saludo y título de la app
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
        // Controles de usuario (logout y avatar)
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

  /// Maneja el cierre de sesión del usuario
  /// Redirige a la pantalla de login o muestra error
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Verificar que el widget sigue montado antes de navegar
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Mostrar error con SnackBar estilizado
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

  /// Construye la sección de estadísticas rápidas
  /// Muestra dispositivos activos y consumo total en tarjetas
  Widget _buildQuickStats(int activeDevices, double totalConsumption) {
    return Row(
      children: [
        // Tarjeta de dispositivos activos
        Expanded(
          child: _buildStatCard(
            title: 'Dispositivos Activos',
            value: '$activeDevices',
            icon: Icons.devices,
            color: const Color(0xFF3282B8),
          ),
        ),
        const SizedBox(width: 16),
        // Tarjeta de consumo energético
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

  /// Widget reutilizable para crear tarjetas de estadísticas
  /// Recibe título, valor, icono y color de personalización
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E), // Fondo de tarjeta
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28), // Icono representativo
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

  /// Construye la sección de dispositivos con título y lista
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
        // ListView que no scrollea (usa el scroll del padre)
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

  /// Construye una tarjeta individual para cada dispositivo
  /// Incluye icono, información, switch de control y botón eliminar
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
          // Icono del dispositivo con color según estado
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: device.isOn
                  ? const Color(0xFF3282B8) // Azul si está encendido
                  : Colors.grey.shade600, // Gris si está apagado
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(device.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          // Información del dispositivo (nombre y habitación)
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
          // Switch para controlar el estado on/off
          Switch(
            value: device.isOn,
            onChanged: (value) async {
              // Actualizar estado local inmediatamente para UX fluida
              setState(() {
                device.isOn = value;
              });
              // Sincronizar cambio con Firebase
              await FirebaseFirestore.instance
                  .collection('devices')
                  .doc(device.id)
                  .update({'isOn': value});
            },
          ),
          // Botón para eliminar dispositivo
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

  /// Muestra diálogo de confirmación antes de eliminar un dispositivo
  /// Incluye el nombre del dispositivo para evitar eliminaciones accidentales
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
                Navigator.pop(context); // Cerrar diálogo primero
                await _deleteDeviceFromFirebase(device.id); // Luego eliminar
              },
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );
  }
}
