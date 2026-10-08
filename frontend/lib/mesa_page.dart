import 'package:flutter/material.dart';
import 'theme.dart';

class MesaPage extends StatelessWidget {
  const MesaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arma la mesa')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction, size: 64, color: kNaranja),
              SizedBox(height: 16),
              Text('Próximamente',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kTexto)),
              SizedBox(height: 8),
              Text('Aquí armarás la mesa de instrumentación arrastrando cada pinza a su lugar.',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}