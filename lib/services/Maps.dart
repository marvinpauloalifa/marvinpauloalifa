import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsService {
  final Map<String, Marker> _markerMap = {};

  Set<Marker> get markers => _markerMap.values.toSet();

  void addMarker(String id, LatLng position, String title) {
    _markerMap[id] = Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(title: title),
    );
  }

  void removeMarker(String id) {
    _markerMap.remove(id);
  }

  void clearMarkers() {
    _markerMap.clear();
  }

  Marker? getMarkerById(String id) {
    return _markerMap[id];
  }
}
