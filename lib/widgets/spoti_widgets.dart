import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ─── Loading Widget ───────────────────────────────────────────────────────────

class SpotiLoading extends StatelessWidget {
  final String? mensaje;

  const SpotiLoading({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF1DB954),
            strokeWidth: 3,
          ),
          if (mensaje != null) ...[
            const SizedBox(height: 16),
            Text(
              mensaje!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Error Widget ─────────────────────────────────────────────────────────────

class SpotiError extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onRetry;

  const SpotiError({super.key, required this.mensaje, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.black,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// ─── Imagen con fallback (Null Safety) ───────────────────────────────────────

Widget spotiImage(
  String? imageUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
}) {
  // Null safety: si no hay imagen, mostrar placeholder
  if (imageUrl == null || imageUrl.isEmpty) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: borderRadius,
      ),
      child: const Icon(Icons.person, color: Colors.white38, size: 40),
    );
  }

  Widget img = CachedNetworkImage(
    imageUrl: imageUrl,
    width: width,
    height: height,
    fit: fit,
    placeholder: (_, __) => Container(
      color: const Color(0xFF282828),
      child: const Center(
        child: CircularProgressIndicator(
            color: Color(0xFF1DB954), strokeWidth: 2),
      ),
    ),
    errorWidget: (_, __, ___) => Container(
      color: const Color(0xFF282828),
      child: const Icon(Icons.broken_image, color: Colors.white38),
    ),
  );

  if (borderRadius != null) {
    return ClipRRect(borderRadius: borderRadius, child: img);
  }
  return img;
}

// ─── Album Card ───────────────────────────────────────────────────────────────

class AlbumCard extends StatelessWidget {
  final String? imageUrl;
  final String nombre;
  final String artista;
  final VoidCallback? onTap;

  const AlbumCard({
    super.key,
    this.imageUrl,
    required this.nombre,
    required this.artista,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: spotiImage(
                imageUrl,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artista,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Artist Tile ──────────────────────────────────────────────────────────────

class ArtistTile extends StatelessWidget {
  final String? imageUrl;
  final String nombre;
  final String? seguidores;
  final VoidCallback? onTap;

  const ArtistTile({
    super.key,
    this.imageUrl,
    required this.nombre,
    this.seguidores,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipOval(
        child: spotiImage(imageUrl, width: 52, height: 52),
      ),
      title: Text(
        nombre,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: seguidores != null
          ? Text(
              '$seguidores seguidores',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
    );
  }
}
