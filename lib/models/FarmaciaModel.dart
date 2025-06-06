// lib/models/FarmaciaModel.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Importar para GeoPoint e Timestamp

class FarmaciaModel {
  final String id; // O ID do documento Firestore
  final Timestamp? createdAt; // Data de criação
  final String? email;
  final String? enderecoTexto; // O campo 'endereco' do Firestore (texto)
  final GeoPoint? localizacao; // O campo 'localizacao' do Firestore (GeoPoint)
  final String nome; // Nome da farmácia
  final String? telefone;

  // Construtor da FarmaciaModel
  FarmaciaModel({
    required this.id,
    this.createdAt,
    this.email,
    this.enderecoTexto,
    this.localizacao,
    required this.nome,
    this.telefone,
  });

  // Método de fábrica para criar uma instância de FarmaciaModel
  // a partir de um DocumentSnapshot do Firestore
  factory FarmaciaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // Converte os dados do documento para um mapa
    return FarmaciaModel(
      id: doc.id, // Usa o ID do documento como o ID da farmácia
      createdAt: data['createdAt'] as Timestamp?,
      email: data['email'] as String?,
      enderecoTexto: data['endereco'] as String?, // Mapeia 'endereco' do Firestore para 'enderecoTexto'
      localizacao: data['localizacao'] as GeoPoint?, // Mapeia 'localizacao' do Firestore para GeoPoint
      nome: data['nome'] as String,
      telefone: data['telefone'] as String?,
    );
  }

  // Método para converter a instância de FarmaciaModel para um Map
  // (útil para salvar ou atualizar dados no Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': createdAt ?? Timestamp.now(), // Se nulo, define a data/hora atual
      'email': email,
      'endereco': enderecoTexto, // O campo 'endereco' no Firestore receberá o texto
      'localizacao': localizacao, // O campo 'localizacao' no Firestore receberá o GeoPoint
      'nome': nome,
      'telefone': telefone,
    };
  }
}