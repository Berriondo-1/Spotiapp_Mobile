class AlbumModel {
  final String id;
  final String name;
  final String? imageUrl;
  final List<String> artists;
  final String releaseDate;
  final String albumType;

  AlbumModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.artists,
    required this.releaseDate,
    required this.albumType,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>?;
    final artistsList = (json['artists'] as List<dynamic>)
        .map((a) => a['name'] as String)
        .toList();

    return AlbumModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Sin nombre',
      imageUrl: images != null && images.isNotEmpty
          ? images[0]['url'] as String?
          : null,
      artists: artistsList,
      releaseDate: json['release_date'] ?? '',
      albumType: json['album_type'] ?? 'album',
    );
  }

  String get artistsString => artists.join(', ');
}
