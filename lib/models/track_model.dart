class TrackModel {
  final String id;
  final String name;
  final String? previewUrl;
  final int durationMs;
  final int trackNumber;
  final String? albumImageUrl;
  final List<String> artists;

  TrackModel({
    required this.id,
    required this.name,
    this.previewUrl,
    required this.durationMs,
    required this.trackNumber,
    this.albumImageUrl,
    required this.artists,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    final artistsList = (json['artists'] as List<dynamic>)
        .map((a) => a['name'] as String)
        .toList();
    final album = json['album'] as Map<String, dynamic>?;
    final images = album?['images'] as List<dynamic>?;

    return TrackModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Sin nombre',
      previewUrl: json['preview_url'] as String?,
      durationMs: json['duration_ms'] ?? 0,
      trackNumber: json['track_number'] ?? 0,
      albumImageUrl: images != null && images.isNotEmpty
          ? images[0]['url'] as String?
          : null,
      artists: artistsList,
    );
  }

  String get durationFormatted {
    final minutes = (durationMs / 60000).floor();
    final seconds = ((durationMs % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get artistsString => artists.join(', ');
}
