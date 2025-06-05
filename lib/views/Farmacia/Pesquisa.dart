import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../viewmodels/UserViewModel.dart';

class Pesquisa {
  static Future<void> realizarPesquisaMedicamento(
      String nomeMedicamento,
      UserViewModel viewModel,
      Function(String) mostrarMensagem,
      ) async {
    viewModel.limparMarcadores(); // remove todos os marcadores

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

      // Se não houver localização, ignorar
      if (latitude == null || longitude == null) continue;

      // Verifica se a farmácia tem o medicamento com dados válidos


    final medDoc = await firestore
        .collection("farmacias")
        .doc(farmaciaId)
        .collection("medicamentos")
        .doc(query) // 👈 CORRIGIDO AQUI
        .get();


    if (medDoc.exists) {
        final medData = medDoc.data();
        final quantidade = (medData?['quantidade'] ?? 0).toDouble();
        final preco = (medData?['preco'] ?? 0).toDouble();

        if (quantidade > 0 && preco > 0) {
          viewModel.addMarker(
            farmaciaId,
            latitude,
            longitude,
            "$nomeFarmacia\n$query - $quantidade un. - $preco MT",
          );
          encontrou = true;
        }
      }
    }

    // Se encontrou ao menos uma farmácia com o medicamento válido
    if (encontrou) {
      // Foca no primeiro marcador
      final posicao = viewModel.mapMarkers.first.position;
      viewModel.mapController?.animateCamera(CameraUpdate.newLatLng(posicao));
    } else {
      mostrarMensagem('O medicamento "$query" não foi encontrado em nenhuma farmácia.');
    }
  }
}
