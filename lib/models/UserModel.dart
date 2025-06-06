// lib/models/UserModel.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid; // O ID único do usuário, que é o ID do documento no Firestore
  final Timestamp? createdAt; // Data de criação
  final String email;
  final String nome;

  // Construtor principal da classe UserModel
  UserModel({
    required this.uid,
    this.createdAt, // createdAt é opcional no construtor para permitir leitura de dados antigos sem ele
    required this.email,
    required this.nome,
  });

  // Método de fábrica para criar uma instância de UserModel
  // a partir de um Map de dados (geralmente vindo de doc.data())
  // e o UID do documento.
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid, // Usa o UID passado (que é o ID do documento)
      createdAt: map['createdAt'] as Timestamp?, // Mapeia o campo createdAt do Firestore
      email: map['email'] as String? ?? '', // Garante que não seja nulo, usando padrão vazio
      nome: map['nome'] as String? ?? '',   // Garante que não seja nulo, usando padrão vazio
    );
  }

  // Método para converter uma instância de UserModel em um Map
  // para ser salvo ou atualizado no Firestore.
  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt ?? Timestamp.now(), // Usa o createdAt existente ou o timestamp atual
      'email': email,
      'nome': nome,
      // 'papel' e 'senha' não existem para UserModel, então não são incluídos aqui.
    };
  }
}
