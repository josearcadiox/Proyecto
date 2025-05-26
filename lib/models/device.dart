import 'package:flutter/material.dart';

class Device {
  final String id;
  final String name;
  final String type;
  final IconData icon;
  bool isOn;
  double powerConsumption;
  String room;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    this.isOn = false,
    this.powerConsumption = 0.0,
    required this.room,
  });
}

List<Device> devices = [
  Device(
    id: '1',
    name: 'Luz Principal',
    type: 'light',
    icon: Icons.lightbulb,
    isOn: true,
    powerConsumption: 12.5,
    room: 'Sala',
  ),
  Device(
    id: '2',
    name: 'Aire Acondicionado',
    type: 'ac',
    icon: Icons.ac_unit,
    isOn: false,
    powerConsumption: 85.0,
    room: 'Dormitorio',
  ),
  Device(
    id: '3',
    name: 'Smart TV',
    type: 'tv',
    icon: Icons.tv,
    isOn: true,
    powerConsumption: 45.2,
    room: 'Sala',
  ),
];
