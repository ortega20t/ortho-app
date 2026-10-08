import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'theme.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final Dio _dio = Dio(BaseOptions(baseUrl: kBase));
  final TextEditingController _ctrl = TextEditingController();

  late Future<List<dynamic>> _instrumentos;
  String _busqueda = '';
  String? _categoria;

  @override
  void initState() {
    super.initState();
    _instrumentos = _cargar();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _cargar() async {
    final r = await _dio.get('/instrumentos');
    return r.data as List<dynamic>;
  }

  String _normalizar(String s) {
    const con = 'áéíóúüñÁÉÍÓÚÜÑ';
    const sin = 'aeiouunAEIOUUN';
    var r = s;
    for (var i = 0; i < con.length; i++) {
      r = r.replaceAll(con[i], sin[i]);
    }
    return r.toLowerCase().trim();
  }

  List<dynamic> _filtrar(List<dynamic> lista) {
    final q = _normalizar(_busqueda);
    return lista.where((i) {
      final okCat = _categoria == null || i['categoria'] == _categoria;
      final okTxt = q.isEmpty ||
          _normalizar(i['nombre']).contains(q) ||
          _normalizar(i['uso']).contains(q);
      return okCat && okTxt;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo')),
      body: FutureBuilder<List<dynamic>>(
        future: _instrumentos,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                    'No se pudo conectar con el servidor.\n¿Está corriendo uvicorn?\n\n${snap.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }

          final todos = snap.data!;
          final categorias =
              (todos.map((i) => i['categoria'] as String).toSet().toList()..sort());
          final lista = _filtrar(todos);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: TextField(
                      controller: _ctrl,
                      onChanged: (v) => setState(() => _busqueda = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o uso...',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _busqueda.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _ctrl.clear();
                                  setState(() => _busqueda = '');
                                },
                              ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 52,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('Todas'),
                            selected: _categoria == null,
                            onSelected: (_) => setState(() => _categoria = null),
                          ),
                        ),
                        for (final c in categorias)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(c),
                              selected: _categoria == c,
                              onSelected: (_) =>
                                  setState(() => _categoria = (_categoria == c) ? null : c),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('${lista.length} de ${todos.length} instrumentos',
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ),
                  Expanded(
                    child: lista.isEmpty
                        ? const Center(child: Text('No se encontraron instrumentos'))
                        : ListView.builder(
                            itemCount: lista.length,
                            itemBuilder: (context, i) {
                              final item = lista[i];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: ListTile(
                                  leading: item['imagen_url'] != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            '$kBase${item['imagen_url']}',
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : CircleAvatar(child: Text('${item['id']}')),
                                  title: Text(item['nombre']),
                                  subtitle: Text('${item['categoria']}\n${item['uso']}'),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}