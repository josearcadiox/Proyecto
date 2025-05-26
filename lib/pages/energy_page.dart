import 'package:flutter/material.dart';

class EnergyPage extends StatelessWidget {
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
                'Energía',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              _buildEnergyStats(),
              SizedBox(height: 24),
              _buildConsumptionChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnergyStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Consumo Hoy',
            value: '2.4 kWh',
            icon: Icons.flash_on,
            color: Color(0xFF3282B8),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Costo Estimado',
            value: '\$45.20',
            icon: Icons.attach_money,
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildConsumptionChart() {
    return Container(
      height: 200,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, color: Color(0xFF3282B8), size: 48),
            SizedBox(height: 16),
            Text(
              'Gráfico de Consumo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Aquí se mostraría el gráfico de consumo energético',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
