import 'package:flutter/material.dart';

class BuildDashboardCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String value;

  const BuildDashboardCard({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.value  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
           
          ],
        ),
      ),
    );
  }
}
