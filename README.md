# 🎵 Spotiapp Mobile — Flutter

Aplicación móvil que consume la API de Spotify para mostrar nuevos lanzamientos y buscar artistas.

---

## 🚀 Configuración Inicial

### 1. Credenciales de Spotify

1. Ve a [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Crea una aplicación llamada **"Spotiapp Mobile"**
3. Copia tu **Client ID** y **Client Secret**
4. Edita `lib/services/spotify_service.dart`:

```dart
static const String _clientId     = 'PEGA_TU_CLIENT_ID_AQUÍ';
static const String _clientSecret  = 'PEGA_TU_CLIENT_SECRET_AQUÍ';
```

5. En la configuración de tu app en el Dashboard, agrega el Redirect URI:
   ```
   http://localhost:8888/callback
   ```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Ejecutar

```bash
flutter run
```

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                    # Entry point + navegación
├── services/
│   └── spotify_service.dart     # Peticiones HTTP a Spotify
├── models/
│   ├── album_model.dart         # Modelo de álbum
│   ├── artist_model.dart        # Modelo de artista
│   └── track_model.dart         # Modelo de canción
├── pages/
│   ├── home_page.dart           # GridView de nuevos lanzamientos
│   ├── search_page.dart         # Búsqueda de artistas
│   └── artist_page.dart         # Detalle + Top Tracks + Preview
└── widgets/
    └── spoti_widgets.dart       # Widgets reutilizables
```

---

## ✅ Funcionalidades Implementadas

| Fase | Descripción | Estado |
|------|-------------|--------|
| 1 | Autenticación Client Credentials | ✅ |
| 2 | Arquitectura Flutter organizada | ✅ |
| 3 | `getNewReleases()` y `getArtistas()` | ✅ |
| 4 | Home con GridView de álbumes | ✅ |
| 4 | Search con TextField + Loading | ✅ |
| 4 | Null safety para imágenes | ✅ |
| 5 | Navegación a ArtistPage | ✅ |
| 5 | Top 10 canciones con ListView | ✅ |
| 5 | Preview de 30 segundos con just_audio | ✅ |

---

## 📦 Dependencias

```yaml
http: ^1.2.0              # Peticiones HTTP
just_audio: ^0.9.36       # Reproducción de audio
cached_network_image: ^3.3.1  # Caché de imágenes
```

---

## 📱 Permisos Requeridos

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```
