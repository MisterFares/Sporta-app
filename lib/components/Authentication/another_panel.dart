import 'package:fit/components/Widgets/build_icon.dart';
import 'package:flutter/material.dart';

Widget anotherPanel(
  context,
  String title,
  String description,
  IconData icon,
  List<Widget> children,
) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(0, -1),
        radius: 1.2,
        colors: [Color(0xFF1A201E), Color(0xFF0B0F0E)],
      ),
    ),
    child: Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        decoration: BoxDecoration(
          color: const Color(0xFF161C1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF232B28)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 40,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildIcon(icon),
            const SizedBox(height: 32),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8B949E),
                height: 1.6,
              ),
            ),
            Column(children: children),
          ],
        ),
      ),
    ),
  );
}
