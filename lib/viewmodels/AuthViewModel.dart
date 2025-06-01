import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/UserModel.dart';
import '../services/FirestoreService.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  UserModel? _userModel;
  UserModel? get user => _userModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String senha) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      _userModel = await _firestore.getUserData(cred.user!.uid);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String senha, String nome, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      _userModel = UserModel(
        uid: cred.user!.uid,
        email: email,
        nome: nome,
        papel: role,
        senha: '',
      );

      await _firestore.saveUserData(_userModel!);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }
}
