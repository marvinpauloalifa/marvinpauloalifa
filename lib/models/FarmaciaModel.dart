class FarmaciaModel {
  final String id;
  final String nome;
  final String endereco;
  final double latitude;
  final double longitude;

  FarmaciaModel({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.latitude,
    required this.longitude,
  });

  factory FarmaciaModel.fromMap(Map<String, dynamic> map, String id) {
    return FarmaciaModel(
      id: id,
      nome: map['nome'] ?? '',
      endereco: map['endereco'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'endereco': endereco,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
