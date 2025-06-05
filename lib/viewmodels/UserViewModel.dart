import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // Adiciona marcador da localização do usuário
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

  // ⚠️ Atualizado: remove todos os marcadores (inclusive localização do usuário)
  void limparMarcadores() {
    _mapMarkers.clear();
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

  // ❌ NÃO USAR: Pesquisa foi movida para a classe Pesquisa.dart
  // Mantenho aqui para referência, mas não será usada
  @Deprecated('Use Pesquisa.realizarPesquisaMedicamento em vez disso.')
  Future<bool> pesquisarMedicamento(String nomeMedicamento) async {
    limparMarcadores(); // remove tudo, inclusive localização do usuário
    final prefs = await SharedPreferences.getInstance();
    final firestore = FirebaseFirestore.instance;
    final query = nomeMedicamento.toLowerCase();
    bool encontrou = false;

    final snapshot = await firestore.collection("farmacias").get();

    for (var doc in snapshot.docs) {
      final farmaciaId = doc.id;
      final data = doc.data();
      final nomeFarmacia = data["nome"] ?? "Farmácia";
      final latitude = data["latitude"];
      final longitude = data["longitude"];

      if (latitude == null || longitude == null) continue;

      final medDoc = await firestore
          .collection("farmacias")
          .doc(farmaciaId)
          .collection("medicamentos")
          .doc(nomeMedicamento)
          .get();

      if (medDoc.exists) {
        final medData = medDoc.data();
        final quantidade = medData?['quantidade'] ?? 0;
        final preco = medData?['preco'] ?? 0;

        if (quantidade > 0 && preco > 0) {
          _mapMarkers.add(
            Marker(
              markerId: MarkerId(farmaciaId),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: nomeFarmacia,
                snippet: "$nomeMedicamento - $quantidade un. - $preco MT",
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          );
          encontrou = true;
        }
      }
    }

    notifyListeners();

    if (_mapMarkers.isNotEmpty) {
      final primeiro = _mapMarkers.first.position;
      mapController?.animateCamera(CameraUpdate.newLatLng(primeiro));
    }

    return encontrou;
  }

  // Métodos de imagem (a implementar)
  void selectImageFromCamera() async {
    // TODO: Implementar
  }

  void selectImageFromGallery() async {
    // TODO: Implementar
  }
}
