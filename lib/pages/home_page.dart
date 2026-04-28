import 'package:flutter/material.dart';
import '../services/spotify_service.dart';
import '../models/album_model.dart';
import '../widgets/spoti_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpotifyService _service = SpotifyService();
  List<AlbumModel> _albums = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarLanzamientos();
  }

  Future<void> _cargarLanzamientos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _service.getNewReleases();
      setState(() {
        _albums = items.map((e) => AlbumModel.fromJson(e)).toList();
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/img/spotify_logo.png',
                height: 28, errorBuilder: (_, __, ___) {
              return const Icon(Icons.music_note,
                  color: Color(0xFF1DB954), size: 28);
            }),
            const SizedBox(width: 10),
            const Text(
              'Spotiapp',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _cargarLanzamientos,
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const SpotiLoading(mensaje: 'Cargando nuevos lanzamientos...');
    }

    if (_error != null) {
      return SpotiError(
        mensaje: 'No se pudieron cargar los lanzamientos.\n\n'
            'Verifica tus credenciales en spotify_service.dart',
        onRetry: _cargarLanzamientos,
      );
    }

    if (_albums.isEmpty) {
      return const Center(
        child: Text('No hay lanzamientos disponibles.',
            style: TextStyle(color: Colors.white54)),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarLanzamientos,
      color: const Color(0xFF1DB954),
      backgroundColor: const Color(0xFF282828),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'Nuevos Lanzamientos',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                final album = _albums[index];
                return AlbumCard(
                  imageUrl: album.imageUrl,
                  nombre: album.name,
                  artista: album.artistsString,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
