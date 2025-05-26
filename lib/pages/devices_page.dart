import 'package:flutter/material.dart';
import '../models/device.dart';

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  late List<Device> _deviceList;

  @override
  void initState() {
    super.initState();
    _deviceList = List.from(devices);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dispositivos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _deviceList.length,
                  itemBuilder: (context, index) {
                    return _buildDeviceCard(_deviceList[index], index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(Device device, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: device.isOn ? Color(0xFF3282B8) : Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(device.icon, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                    _deviceList[index].isOn = value;
                  });
                },
                activeColor: Color(0xFF3282B8),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consumo: ${device.powerConsumption}W',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                device.isOn ? 'Encendido' : 'Apagado',
                style: TextStyle(
                  color: device.isOn ? Color(0xFF3282B8) : Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
