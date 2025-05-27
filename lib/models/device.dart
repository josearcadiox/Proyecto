import 'package:flutter/material.dart';

class Device {
  final String id;
  final String name;
  final String room;
  bool isOn;
  final double powerConsumption;
  final IconData icon;

  Device({
    required this.id,
    required this.name,
    required this.room,
    required this.isOn,
    required this.powerConsumption,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'room': room,
      'isOn': isOn,
      'powerConsumption': powerConsumption,
    };
  }

  static Device fromMap(String id, Map<String, dynamic> map) {
    IconData icon = Icons.device_unknown;
    if (map['name'].toString().toLowerCase().contains('lamp')) {
      icon = Icons.lightbulb;
    } else if (map['name'].toString().toLowerCase().contains('tv')) {
      icon = Icons.tv;
    } else if (map['name'].toString().toLowerCase().contains('fan')) {
      icon = Icons.toys;
    }

    return Device(
      id: id,
      name: map['name'],
      room: map['room'],
      isOn: map['isOn'],
      powerConsumption: (map['powerConsumption'] as num).toDouble(),
      icon: icon,
    );
  }
}
