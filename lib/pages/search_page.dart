import 'package:flutter/material.dart';
import '../services/spotify_service.dart';
import '../models/artist_model.dart';
import '../widgets/spoti_widgets.dart';
import 'artist_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SpotifyService _service = SpotifyService();
  final TextEditingController _controller = TextEditingController();

  List<ArtistModel> _artistas = [];
  bool _isLoading = false;
  bool _hasBuscado = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _buscar(String termino) async {
    final query = termino.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasBuscado = true;
      _error = null;
    });

    try {
      final items = await _service.getArtistas(query);
      setState(() {
        _artistas = items.map((e) => ArtistModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'Buscar Artistas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Barra de búsqueda ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.search,
              onSubmitted: _buscar,
              decoration: InputDecoration(
                hintText: 'Artistas, bandas...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF282828),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF1DB954)),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _artistas = [];
                            _hasBuscado = false;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}), // para mostrar botón limpiar
            ),
          ),

          // ── Resultados ────────────────────────────────────────────
          Expanded(child: _buildResultados()),
        ],
      ),
    );
  }

  Widget _buildResultados() {
    if (_isLoading) {
      return const SpotiLoading(mensaje: 'Buscando artistas...');
    }

    if (_error != null) {
      return SpotiError(
        mensaje: 'Error al buscar. Verifica tu conexión.',
        onRetry: () => _buscar(_controller.text),
      );
    }

    if (!_hasBuscado) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            const Text(
              'Busca tu artista favorito',
              style: TextStyle(color: Colors.white38, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_artistas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              'No se encontraron artistas para\n"${_controller.text}"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _artistas.length,
      itemBuilder: (context, index) {
        final artista = _artistas[index];
        return ArtistTile(
          imageUrl: artista.imageUrl,
          nombre: artista.name,
          seguidores: artista.followersFormatted,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArtistPage(artistId: artista.id),
              ),
            );
          },
        );
      },
    );
  }
}
