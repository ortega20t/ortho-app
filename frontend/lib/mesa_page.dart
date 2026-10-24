import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'theme.dart';

class MesaPage extends StatefulWidget {
  const MesaPage({super.key});

  @override
  State<MesaPage> createState() => _MesaPageState();
}

class _MesaPageState extends State<MesaPage> {
  final Dio _dio = Dio(BaseOptions(baseUrl: kBase));

  List<Map<String, dynamic>> _mesas = [];
  final Map<String, List<Map<String, dynamic>>> _bancos = {};
  final Map<int, int> _llenos = {}; // id del lugar -> id del instrumento
  int _m = 0;
  int _errores = 0;
  bool _estudio = false;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final r = await _dio.get('/mesas');
      final mesas = (r.data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      for (final m in mesas) {
        final slots = (m['slots'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        m['slots'] = slots;
        _bancos[m['id']] = List.of(slots)..shuffle();
      }
      setState(() {
        _mesas = mesas;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error =
            'No se pudo conectar con el servidor.\n¿Está corriendo uvicorn?\n\n$e';
        _cargando = false;
      });
    }
  }

  Map<String, dynamic> get _mesa => _mesas[_m];
  List<Map<String, dynamic>> get _slots =>
      List<Map<String, dynamic>>.from(_mesa['slots']);

  int get _colocados =>
      _slots.where((s) => _llenos.containsKey(s['id'])).length;

  void _soltar(Map<String, dynamic> slot, Map<String, dynamic> item) {
    if (slot['nombre'] == item['nombre']) {
      setState(() => _llenos[slot['id'] as int] = item['id'] as int);
      if (_colocados == _slots.length) _felicitar();
    } else {
      setState(() => _errores++);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Ese no va en el lugar ${slot['num']}. Inténtalo de nuevo.'),
          duration: const Duration(seconds: 2),
        ));
    }
  }

  void _felicitar() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¡Mesa completa! 🎉'),
        content: Text('Errores: $_errores'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _reiniciar() {
    setState(() {
      for (final s in _slots) {
        _llenos.remove(s['id']);
      }
      _bancos[_mesa['id']]!.shuffle();
      _errores = 0;
    });
  }

  void _cambiarMesa(int i) {
    setState(() {
      _m = i;
      _errores = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arma la mesa'),
        actions: [
          IconButton(
              tooltip: 'Reiniciar',
              icon: const Icon(Icons.refresh),
              onPressed: _mesas.isEmpty ? null : _reiniciar),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!, textAlign: TextAlign.center)))
              : _contenido(),
    );
  }

  Widget _contenido() {
    final banco = _bancos[_mesa['id']]!
        .where((i) => !_llenos.containsValue(i['id']))
        .toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<int>(
              segments: [
                for (var i = 0; i < _mesas.length; i++)
                  ButtonSegment(value: i, label: Text(_mesas[i]['nombre'])),
              ],
              selected: {_m},
              onSelectionChanged: (s) => _cambiarMesa(s.first),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Colocados: $_colocados / ${_slots.length}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: kTexto)),
                Text('Errores: $_errores',
                    style: const TextStyle(color: kNaranja)),
              ],
            ),
            const SizedBox(height: 8),
            _tabla(),
            const SizedBox(height: 4),
            const Text(
              'Mantén presionado un instrumento y suéltalo en su número.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            if (banco.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final i in banco) _itemArrastrable(i)],
              ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ver respuestas (modo estudio)'),
              value: _estudio,
              onChanged: (v) => setState(() => _estudio = v),
            ),
            if (_estudio)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final s in _slots)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                              '${s['num']}. ${_etiqueta(s)}'),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _etiqueta(Map<String, dynamic> i) {
    final c = i['cantidad'] as int;
    return c > 1 ? '$c× ${i['nombre']}' : '${i['nombre']}';
  }

  Widget _chip(Map<String, dynamic> i, {bool sombra = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kTeal.withAlpha(150)),
        boxShadow: sombra
            ? [const BoxShadow(blurRadius: 8, color: Colors.black26)]
            : null,
      ),
      child: Text(_etiqueta(i),
          style: const TextStyle(
              fontSize: 13, color: kTexto, decoration: TextDecoration.none,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _itemArrastrable(Map<String, dynamic> i) {
    return LongPressDraggable<Map<String, dynamic>>(
      data: i,
      delay: const Duration(milliseconds: 120),
      feedback: Material(
          color: Colors.transparent, child: _chip(i, sombra: true)),
      childWhenDragging: Opacity(opacity: 0.3, child: _chip(i)),
      child: _chip(i),
    );
  }

  Widget _tabla() {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth < 620 ? 620.0 : c.maxWidth;
      final h = w / (_mesa['aspecto'] as num);
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: const Color(0xFFBBDFE3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kTeal.withAlpha(150)),
          ),
          child: Stack(
            children: [for (final s in _slots) _slot(s, w, h)],
          ),
        ),
      );
    });
  }

  Widget _slot(Map<String, dynamic> s, double w, double h) {
    const d = 32.0;
    final id = s['id'] as int;
    final lleno = _llenos.containsKey(id);

    return Positioned(
      left: (s['x'] as num) * w - d / 2,
      top: (s['y'] as num) * h - d / 2,
      child: DragTarget<Map<String, dynamic>>(
        onWillAcceptWithDetails: (_) => !lleno,
        onAcceptWithDetails: (det) => _soltar(s, det.data),
        builder: (context, cand, rej) {
          final encima = cand.isNotEmpty;
          return Tooltip(
            message: lleno ? '${s['nombre']}' : 'Lugar ${s['num']}',
            child: Container(
              width: d,
              height: d,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lleno
                    ? Colors.green.shade600
                    : encima
                        ? kNaranja.withAlpha(70)
                        : Colors.white,
                border: Border.all(
                    color: lleno
                        ? Colors.green.shade800
                        : (encima ? kNaranja : kTeal),
                    width: 2),
              ),
              child: lleno
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : Text('${s['num']}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kTexto)),
            ),
          );
        },
      ),
    );
  }
}