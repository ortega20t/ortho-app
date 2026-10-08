import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'theme.dart';

class TarjetasPage extends StatefulWidget {
  const TarjetasPage({super.key});

  @override
  State<TarjetasPage> createState() => _TarjetasPageState();
}

class _TarjetasPageState extends State<TarjetasPage> {
  final Dio _dio = Dio(BaseOptions(baseUrl: kBase));
  List<dynamic> _lista = [];
  int _i = 0;
  bool _volteada = false;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final r = await _dio.get('/instrumentos');
      final l = List<dynamic>.from(r.data as List)..shuffle();
      setState(() {
        _lista = l;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo conectar con el servidor.\n¿Está corriendo uvicorn?\n\n$e';
        _cargando = false;
      });
    }
  }

  void _mover(int d) {
    setState(() {
      _i = (_i + d) % _lista.length;
      _volteada = false;
    });
  }

  void _mezclar() {
    setState(() {
      _lista.shuffle();
      _i = 0;
      _volteada = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarjetas'),
        actions: [
          IconButton(
              tooltip: 'Mezclar', icon: const Icon(Icons.shuffle), onPressed: _lista.isEmpty ? null : _mezclar),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
              : _contenido(),
    );
  }

  Widget _contenido() {
    final item = _lista[_i];
    final tieneFoto = item['imagen_url'] != null;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('${_i + 1} / ${_lista.length}', style: const TextStyle(color: kTexto)),
              const SizedBox(height: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _volteada = !_volteada),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      key: ValueKey('$_i-$_volteada'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: (_volteada ? kNaranja : kTeal).withAlpha(150), width: 1.5),
                      ),
                      child: _volteada ? _reverso(item) : _frente(item, tieneFoto),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                      onPressed: () => _mover(-1),
                      child: const Text('Anterior'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _mover(1),
                      child: const Text('Siguiente'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _frente(dynamic item, bool tieneFoto) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (tieneFoto)
          Expanded(
            child: Image.network('$kBase${item['imagen_url']}', fit: BoxFit.contain),
          )
        else
          const Icon(Icons.help_outline, size: 64, color: kTeal),
        const SizedBox(height: 16),
        Text(
          tieneFoto
              ? '¿Cómo se llama esta pinza?'
              : '¿Qué instrumento se usa para esto?\n\n${item['uso']}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTexto),
        ),
        const SizedBox(height: 12),
        const Text('Toca la tarjeta para voltear', style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _reverso(dynamic item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(item['nombre'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kNaranja)),
        const SizedBox(height: 12),
        Chip(label: Text(item['categoria'])),
        const SizedBox(height: 16),
        Text(item['uso'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: kTexto)),
      ],
    );
  }
}