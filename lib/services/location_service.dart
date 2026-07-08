import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

class GpsPoint {
  const GpsPoint(this.latitude, this.longitude, {this.isMock = false});
  final double latitude;
  final double longitude;
  final bool isMock;
}

class LocationService {
  Future<GpsPoint> currentPoint({double fallbackLat = 60.167, double fallbackLng = -1.206}) async {
    try {
      final bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return _mock(fallbackLat, fallbackLng);
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return _mock(fallbackLat, fallbackLng);
      final Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, timeLimit: Duration(seconds: 4)));
      return GpsPoint(position.latitude, position.longitude);
    } catch (_) {
      return _mock(fallbackLat, fallbackLng);
    }
  }

  int distanceYards(double lat1, double lng1, double lat2, double lng2) {
    const double earthMeters = 6371000;
    final double dLat = _rad(lat2 - lat1);
    final double dLng = _rad(lng2 - lng1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) + math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.sin(dLng / 2) * math.sin(dLng / 2);
    return (earthMeters * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a)) * 1.09361).round();
  }

  GpsPoint _mock(double lat, double lng) => GpsPoint(lat + (math.Random().nextDouble() * .002), lng + (math.Random().nextDouble() * .002), isMock: true);
  double _rad(double degrees) => degrees * math.pi / 180;
}
