import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

class LocationPoint {
  final double latitude;
  final double longitude;

  const LocationPoint(this.latitude, this.longitude);
}

class LocationService {
  /// Coordenada central padrão de Rio do Sul - SC.
  static const LocationPoint rioDoSulCenter = LocationPoint(-27.2156, -49.6431);

  /// Calcula distância Haversine em quilômetros entre dois pontos.
  static double distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);

  static String formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  /// Obtém posição atual com tratamento seguro de permissões.
  Future<(LocationPoint?, String?)> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return (
          null,
          'O GPS está desativado. Ative a localização ou escolha o ponto manualmente no mapa.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return (
            null,
            'Permissão de localização negada. Você ainda pode marcar o ponto no mapa manualmente.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return (
          null,
          'Permissão de localização bloqueada nas configurações do aparelho.',
        );
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return (LocationPoint(pos.latitude, pos.longitude), null);
    } catch (_) {
      return (
        null,
        'Não foi possível obter a localização agora. Marque no mapa ou preencha o bairro.',
      );
    }
  }
}
