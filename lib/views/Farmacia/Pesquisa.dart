import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../viewmodels/UserViewModel.dart';

class Pesquisa {
  static Future<void> realizarPesquisaMedicamento(
      String nomeMedicamento,
      UserViewModel viewModel,
      Function(String) mostrarMensagem,
      ) async {
    viewModel.limparMarcadores();
    viewModel.removerMarcadorUsuario(); // Remove marcador do usuário

    final firestore = FirebaseFirestore.instance;
    final query = nomeMedicamento.trim();
    bool encontrou = false;

    // === 🔍 BUSCA NO FIREBASE ===
    final snapshot = await firestore.collection("farmacias").get();

    for (var doc in snapshot.docs) {
      final farmaciaId = doc.id;
      final data = doc.data();
      final nomeFarmacia = data["nome"] ?? "Farmácia";
      final localizacao = data["localizacao"];

      if (localizacao == null || localizacao is! List || localizacao.length != 2) continue;

      final double latitude = localizacao[0];
      final double longitude = localizacao[1];

      final medSnapshot = await firestore
          .collection("farmacias")
          .doc(farmaciaId)
          .collection("medicamentos")
          .where("nome", isEqualTo: query)
          .get();

      if (medSnapshot.docs.isNotEmpty) {
        final medData = medSnapshot.docs.first.data();
        final estado = (medData['estado'] ?? "").toLowerCase();
        final preco = medData['preco'] ?? 0;
        final quantidade = medData['quantidade'] ?? 0;

        if ((estado == "disponível" || estado == "disponivel") && preco > 0 && quantidade > 0) {
          viewModel.addMarker(
            farmaciaId,
            latitude,
            longitude,
            "$nomeFarmacia\n${medData['nome']} - $quantidade un. - $preco MT",
          );
          encontrou = true;
        }
      }
    }


    // === 🔍 BUSCA LOCAL EM SharedPreferences ===
    final prefs = await SharedPreferences.getInstance();
    final todasFarmaciasStr = prefs.getStringList("farmacias_local") ?? [];

    for (var farmaciaJson in todasFarmaciasStr) {
      final farmacia = json.decode(farmaciaJson);
      final id = farmacia["id"];
      final nome = farmacia["nome"];
      final localizacao = farmacia["localizacao"];

      if (localizacao == null || localizacao is! List || localizacao.length != 2) continue;

      final double latitude = localizacao[0];
      final double longitude = localizacao[1];

      final medicamentos = farmacia["medicamentos"] ?? [];

      for (var med in medicamentos) {
        final nomeMed = (med["nome"] ?? "").toString();
        final estado = (med["estado"] ?? "").toString().toLowerCase();
        final preco = med["preco"] ?? 0;
        final quantidade = med["quantidade"] ?? 0;

        if (nomeMed == query &&
            (estado == "disponível" || estado == "disponivel") &&
            quantidade > 0 &&
            preco > 0) {
          viewModel.addMarker(
            id,
            latitude,
            longitude,
            "$nome\n${med['nome']} - $quantidade un. - ${med['preco']} MT",
          );
          encontrou = true;
          break;
        }
      }
    }

    // === RESULTADO FINAL ===
    if (encontrou && viewModel.mapMarkers.isNotEmpty) {
      final bounds = _calcularBounds(
        viewModel.mapMarkers.map((e) => e.position).toList(),
      );
      viewModel.mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } else {
      mostrarMensagem('O medicamento "$query" não foi encontrado em nenhuma farmácia.');
    }
  }

  static LatLngBounds _calcularBounds(List<LatLng> positions) {
    double x0 = positions.first.latitude;
    double x1 = positions.first.latitude;
    double y0 = positions.first.longitude;
    double y1 = positions.first.longitude;

    for (var latLng in positions) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(x0, y0),
      northeast: LatLng(x1, y1),
    );
  }
}
