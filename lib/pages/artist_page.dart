import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/spotify_service.dart';
import '../models/artist_model.dart';
import '../models/track_model.dart';
import '../widgets/spoti_widgets.dart';

class ArtistPage extends StatefulWidget {
  final String artistId;

  const ArtistPage({super.key, required this.artistId});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final SpotifyService _service = SpotifyService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  ArtistModel? _artista;
  List<TrackModel> _tracks = [];
  bool _isLoading = true;
  String? _error;
  String? _currentTrackId;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
          _currentTrackId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final artistData =
          await _service.getArtistDetail(widget.artistId);
      final tracksData =
          await _service.getTopTracks(widget.artistId);

      setState(() {
        _artista = ArtistModel.fromJson(artistData);
        _tracks = tracksData.map((e) => TrackModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePlay(TrackModel track) async {
    if (track.previewUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay preview disponible para esta canción'),
          backgroundColor: Color(0xFF282828),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_currentTrackId == track.id && _isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      if (_currentTrackId != track.id) {
        await _audioPlayer.setUrl(track.previewUrl!);
      }
      await _audioPlayer.play();
      setState(() {
        _currentTrackId = track.id;
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _isLoading
          ? const SpotiLoading(mensaje: 'Cargando artista...')
          : _error != null
              ? SpotiError(
                  mensaje: 'Error al cargar el artista',
                  onRetry: _cargarDatos,
                )
              : _buildContenido(),
    );
  }

  Widget _buildContenido() {
    if (_artista == null) return const SizedBox.shrink();

    return CustomScrollView(
      slivers: [
        // ── Header con imagen del artista ────────────────────────
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: const Color(0xFF121212),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              _artista!.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                spotiImage(_artista!.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover),
                // Gradiente oscuro hacia abajo
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xFF121212)],
                      stops: [0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Info del artista ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _infoChip(
                  Icons.people,
                  '${_artista!.followersFormatted} seguidores',
                ),
                const SizedBox(width: 12),
                _infoChip(
                  Icons.trending_up,
                  'Popularidad: ${_artista!.popularity}',
                ),
              ],
            ),
          ),
        ),

        // ── Géneros ──────────────────────────────────────────────
        if (_artista!.genres.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _artista!.genres
                    .take(4)
                    .map((g) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF1DB954), width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(g,
                              style: const TextStyle(
                                  color: Color(0xFF1DB954), fontSize: 12)),
                        ))
                    .toList(),
              ),
            ),
          ),

        // ── Título Top Tracks ─────────────────────────────────────
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Top Canciones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // ── Lista de canciones ────────────────────────────────────
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final track = _tracks[index];
              final isCurrentTrack = _currentTrackId == track.id;

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: SizedBox(
                  width: 44,
                  child: Center(
                    child: isCurrentTrack && _isPlaying
                        ? const Icon(Icons.equalizer,
                            color: Color(0xFF1DB954))
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrentTrack
                                  ? const Color(0xFF1DB954)
                                  : Colors.white54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                title: Text(
                  track.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isCurrentTrack
                        ? const Color(0xFF1DB954)
                        : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  track.durationFormatted,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: IconButton(
                  onPressed: () => _togglePlay(track),
                  icon: Icon(
                    isCurrentTrack && _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: track.previewUrl != null
                        ? (isCurrentTrack
                            ? const Color(0xFF1DB954)
                            : Colors.white70)
                        : Colors.white24,
                    size: 32,
                  ),
                ),
              );
            },
            childCount: _tracks.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF1DB954), size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}
