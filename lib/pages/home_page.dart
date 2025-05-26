import 'package:flutter/material.dart';
import '../models/device.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Device> _devices;

  @override
  void initState() {
    super.initState();
    _devices = List.from(devices);
  }

  @override
  Widget build(BuildContext context) {
    int activeDevices = _devices.where((d) => d.isOn).length;
    double totalConsumption = _devices
        .where((d) => d.isOn)
        .fold(0.0, (sum, d) => sum + d.powerConsumption);

    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24),
              _buildQuickStats(activeDevices, totalConsumption),
              SizedBox(height: 24),
              _buildRecentDevices(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: _signOut,
            ),
            CircleAvatar(
              backgroundColor: Color(0xFF3282B8),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(int activeDevices, double totalConsumption) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Dispositivos Activos',
            value: '$activeDevices',
            icon: Icons.devices,
            color: Color(0xFF3282B8),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Consumo Actual',
            value: '${totalConsumption.toStringAsFixed(0)}W',
            icon: Icons.flash_on,
            color: Color(0xFF0F4C75),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecentDevices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dispositivos Recientes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12),
        ..._devices.take(3).map((device) => _buildDeviceCard(device)).toList(),
      ],
    );
  }

  Widget _buildDeviceCard(Device device) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: device.isOn ? Color(0xFF3282B8) : Colors.grey.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(device.icon, color: Colors.white, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  device.room,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: device.isOn,
            onChanged: (value) {
              setState(() {
                device.isOn = value;
              });
            },
            activeColor: Color(0xFF3282B8),
          ),
        ],
      ),
    );
  }
}
