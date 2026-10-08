import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  static const String _base = 'http://localhost:8000';
  final Dio _dio = Dio(BaseOptions(baseUrl: _base));

  String _modo = 'imagen'; // 'imagen' o 'uso'
  Map<String, dynamic>? _pregunta;
  int? _seleccion;
  int _aciertos = 0;
  int _total = 0;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _siguiente();
  }

  Future<void> _siguiente() async {
    setState(() {
      _cargando = true;
      _seleccion = null;
      _error = null;
    });
    try {
      final r = await _dio.get('/quiz', queryParameters: {'modo': _modo});
      setState(() {
        _pregunta = r.data as Map<String, dynamic>;
        _cargando = false;
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.statusCode == 400
            ? 'Aún no hay fotos en la carpeta static/.\nCambia al modo "Por uso".'
            : 'No se pudo cargar la pregunta.\n¿Está corriendo uvicorn?\n\n$e';
        _cargando = false;
      });
    }
  }

  void _cambiarModo(String modo) {
    if (modo == _modo) return;
    setState(() {
      _modo = modo;
      _aciertos = 0;
      _total = 0;
    });
    _siguiente();
  }

  void _elegir(int id) {
    if (_seleccion != null) return;
    setState(() {
      _seleccion = id;
      _total++;
      if (id == _pregunta!['correcta']) _aciertos++;
    });
  }

  Color? _colorOpcion(int id) {
    if (_seleccion == null) return null;
    if (id == _pregunta!['correcta']) return Colors.green.shade200;
    if (id == _seleccion) return Colors.red.shade200;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz de instrumental'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('Aciertos: $_aciertos / $_total',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'imagen',
                        label: Text('Por foto'),
                        icon: Icon(Icons.image)),
                    ButtonSegment(
                        value: 'uso',
                        label: Text('Por uso'),
                        icon: Icon(Icons.description)),
                  ],
                  selected: {_modo},
                  onSelectionChanged: (s) => _cambiarModo(s.first),
                ),
              ),
              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(_error!, textAlign: TextAlign.center),
                            ),
                          )
                        : _contenido(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contenido() {
    final p = _pregunta!;
    final opciones = p['opciones'] as List<dynamic>;
    final respondio = _seleccion != null;
    final acerto = _seleccion == p['correcta'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (p['imagen_url'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '$_base${p['imagen_url']}',
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                Text(p['pregunta'],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final o in opciones)
          Card(
            color: _colorOpcion(o['id'] as int),
            child: ListTile(
              title: Text(o['nombre']),
              onTap: () => _elegir(o['id'] as int),
            ),
          ),
        const SizedBox(height: 12),
        if (respondio) ...[
          Text(
            acerto
                ? '¡Correcto! ✅'
                : 'Incorrecto ❌  (categoría: ${p['categoria']})',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _siguiente,
            child: const Text('Siguiente pregunta'),
          ),
        ],
      ],
    );
  }
}