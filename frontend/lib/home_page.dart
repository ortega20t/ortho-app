import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'catalogo_page.dart';
import 'mesa_page.dart';
import 'quiz_page.dart';
import 'tarjetas_page.dart';
import 'theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _total;

  @override
  void initState() {
    super.initState();
    _contar();
  }

  Future<void> _contar() async {
    try {
      final r = await Dio(BaseOptions(baseUrl: kBase)).get('/instrumentos');
      if (mounted) setState(() => _total = (r.data as List).length);
    } catch (_) {}
  }

  void _abrir(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Instrumental Ortopédico',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: kTexto)),
                      Text(
                        _total == null ? 'Nivel 1' : 'Nivel 1 · $_total pinzas',
                        style: const TextStyle(fontSize: 12, color: kTexto),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    'Aprende cada pinza y su lugar en la mesa',
                    style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: kTexto),
                  ),
                  const SizedBox(height: 6),
                  const Text('Elige cómo quieres practicar hoy.',
                      style: TextStyle(color: kTexto)),
                  const SizedBox(height: 24),
                  LayoutBuilder(builder: (context, c) {
                    final cards = [
                      _OpcionCard(
                        numero: '1',
                        titulo: 'Tarjetas',
                        descripcion:
                            'Foto de la pinza. Adivina el nombre, voltea y revisa su uso.',
                        color: kTeal,
                        onTap: () => _abrir(const TarjetasPage()),
                      ),
                      _OpcionCard(
                        numero: '2',
                        titulo: 'Quiz',
                        descripcion:
                            'Opción múltiple, relacionar nombre con foto o con su uso.',
                        color: kTeal,
                        onTap: () => _abrir(const QuizPage()),
                      ),
                      _OpcionCard(
                        numero: '3',
                        titulo: 'Arma la mesa',
                        descripcion:
                            'Arrastra cada instrumento a su lugar según el procedimiento.',
                        color: kNaranja,
                        onTap: () => _abrir(const MesaPage()),
                      ),
                    ];
                    if (c.maxWidth > 700) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 16),
                          Expanded(child: cards[1]),
                          const SizedBox(width: 16),
                          Expanded(child: cards[2]),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 12),
                        cards[1],
                        const SizedBox(height: 12),
                        cards[2],
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => _abrir(const CatalogoPage()),
                    icon: const Icon(Icons.search),
                    label: const Text('Ver catálogo completo (buscar y filtrar)'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OpcionCard extends StatelessWidget {
  final String numero, titulo, descripcion;
  final Color color;
  final VoidCallback onTap;

  const _OpcionCard({
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(150)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(numero,
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 6),
          Text(titulo,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: kTexto)),
          const SizedBox(height: 6),
          Text(descripcion,
              style: const TextStyle(fontSize: 13, color: kTexto)),
          const Spacer(),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: color),
            onPressed: onTap,
            child: const Text('Empezar'),
          ),
        ],
      ),
    );
  }
}