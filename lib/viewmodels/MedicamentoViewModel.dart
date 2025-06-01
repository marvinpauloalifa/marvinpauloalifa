import 'package:flutter/material.dart';
import '../models/MedicamentoModel.dart';
import '../services/FirestoreService.dart';

class MedicamentoViewModel extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<MedicamentoModel> _medicamentos = [];
  List<MedicamentoModel> get medicamentos => _medicamentos;

  Future<void> fetchMedicamentos(String farmaciaId) async {
    _medicamentos = await _firestore.getMedicamentos(farmaciaId);
    notifyListeners();
  }

  Future<void> addOrUpdateMedicamento(String farmaciaId, MedicamentoModel medicamento) async {
    await _firestore.saveMedicamento(farmaciaId, medicamento);
    await fetchMedicamentos(farmaciaId);
  }
}
