import 'package:flutter/material.dart';
import '../models/FarmaciaModel.dart';
import '../services/FirestoreService.dart';

class PesquisaViewModel extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<FarmaciaModel> _resultados = [];
  List<FarmaciaModel> get resultados => _resultados;

  Future<void> pesquisarMedicamento(String nomeMedicamento) async {
    _resultados = await _firestore.buscarFarmaciasComMedicamento(nomeMedicamento);
    notifyListeners();
  }
}
