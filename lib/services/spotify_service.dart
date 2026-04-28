import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  static const String _clientId = f0d9a5f85ab34afd862fa742ed957d02;
  static const String _clientSecret = 5e0b6a009deb4121995503f4b661419f;

  String? _accessToken;
  DateTime? _tokenExpiry;

  // ─── Autenticación (Client Credentials Flow) ─────────────────────────────

  Future<void> authenticate() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return; // Token todavía válido
    }

    final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      _tokenExpiry =
          DateTime.now().add(Duration(seconds: data['expires_in'] - 60));
    } else {
      throw Exception(
          'Error al autenticar con Spotify: ${response.statusCode}');
    }
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

  // ─── Nuevos Lanzamientos ─────────────────────────────────────────────────

  Future<List<dynamic>> getNewReleases({int limit = 20}) async {
    await authenticate();

    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/browse/new-releases?limit=$limit&country=CO'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['albums']['items'] as List<dynamic>;
    } else {
      throw Exception(
          'Error al obtener nuevos lanzamientos: ${response.statusCode}');
    }
  }

  // ─── Búsqueda de Artistas ────────────────────────────────────────────────

  Future<List<dynamic>> getArtistas(String termino) async {
    await authenticate();

    final encoded = Uri.encodeComponent(termino);
    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/search?q=$encoded&type=artist&limit=15'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['artists']['items'] as List<dynamic>;
    } else {
      throw Exception('Error en búsqueda: ${response.statusCode}');
    }
  }

  // ─── Top Tracks del Artista ──────────────────────────────────────────────

  Future<List<dynamic>> getTopTracks(String artistId,
      {String market = 'CO'}) async {
    await authenticate();

    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/artists/$artistId/top-tracks?market=$market'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['tracks'] as List<dynamic>;
      return tracks.take(10).toList();
    } else {
      throw Exception('Error al obtener top tracks: ${response.statusCode}');
    }
  }

  // ─── Detalle del Artista ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> getArtistDetail(String artistId) async {
    await authenticate();

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/artists/$artistId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Error al obtener detalle del artista: ${response.statusCode}');
    }
  }
}
