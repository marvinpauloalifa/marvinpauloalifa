import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../views/Farmacia/Pesquisa.dart';

class UserViewModel extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();
  Position? userPosition;
  GoogleMapController? mapController;

  File? selectedImage;
  final Set<Marker> _mapMarkers = {};
  Set<Marker> get mapMarkers => _mapMarkers;

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> fetchUserLocation() async {
    final position = await Geolocator.getCurrentPosition();
    userPosition = position;

    _mapMarkers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: 'Você está aqui'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
    notifyListeners();
  }

  void limparMarcadores() {
    _mapMarkers.clear();
    notifyListeners();
  }

  void removerMarcadorUsuario() {
    _mapMarkers.removeWhere((m) => m.markerId.value == 'user_location');
    notifyListeners();
  }

  void addMarker(String id, double latitude, double longitude, String titulo) {
    final marker = Marker(
      markerId: MarkerId(id),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(title: titulo),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    _mapMarkers.add(marker);
    notifyListeners();
  }

  /// Pesquisa com marcador do usuário sendo removido
  Future<void> pesquisarMedicamento(BuildContext context) async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    await Pesquisa.realizarPesquisaMedicamento(
      query,
      this,
          (mensagem) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem)),
        );
      },
    );
  }

  // Métodos para imagens (não implementados ainda)
  void selectImageFromCamera() async {
    // TODO
  }

  void selectImageFromGallery() async {
    // TODO
  }
}
