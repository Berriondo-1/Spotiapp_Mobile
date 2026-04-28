class ArtistModel {
  final String id;
  final String name;
  final String? imageUrl;
  final int followers;
  final List<String> genres;
  final int popularity;

  ArtistModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.followers,
    required this.genres,
    required this.popularity,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>?;
    final genresList = (json['genres'] as List<dynamic>? ?? [])
        .map((g) => g as String)
        .toList();
    final followersMap = json['followers'] as Map<String, dynamic>?;

    return ArtistModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Artista desconocido',
      imageUrl: images != null && images.isNotEmpty
          ? images[0]['url'] as String?
          : null,
      followers: followersMap != null ? (followersMap['total'] ?? 0) : 0,
      genres: genresList,
      popularity: json['popularity'] ?? 0,
    );
  }

  String get followersFormatted {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }
}
