class MedicamentoModel {
  final String id;
  final String nome;
  final String descricao;
  final int quantidade;

  MedicamentoModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.quantidade,
  });

  factory MedicamentoModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicamentoModel(
      id: id,
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      quantidade: map['quantidade'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'quantidade': quantidade,
    };
  }
}
