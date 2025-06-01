import 'package:flutter/material.dart';
import '../models/FarmaciaModel.dart';
import '../services/FirestoreService.dart';

class FarmaciaViewModel extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<FarmaciaModel> _farmacias = [];
  List<FarmaciaModel> get farmacias => _farmacias;

  Future<void> fetchFarmacias() async {
    _farmacias = await _firestore.getAllFarmacias();
    notifyListeners();
  }

  Future<void> addOrUpdateFarmacia(FarmaciaModel farmacia) async {
    await _firestore.saveFarmacia(farmacia);
    await fetchFarmacias();
  }
}
