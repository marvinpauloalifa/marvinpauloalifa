import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:farmacia2pdm/models/AdminAppModel.dart'; // Certifique-se de que os modelos estão corretos
import 'package:farmacia2pdm/models/AdminFarmaciaModel.dart';
import 'package:farmacia2pdm/models/UserModel.dart'; // Importa o UserModel atualizado
import 'package:farmacia2pdm/views/CriarUsers/RegistoFarmacias.dart'; // Para criar Admin Farmácia
import 'package:farmacia2pdm/views/CriarUsers/RegistoUsuario.dart'; // Para criar Utilizador Comum
import 'package:farmacia2pdm/views/CriarUsers/CriarAdminApp.dart'; // Para criar Admin App

import 'EditarUser.dart'; // Importa a tela de edição genérica para usuários

// As coleções do Firestore (certifique-se de que os nomes das coleções estão corretos no seu Firestore)
final CollectionReference farmaciasCollection = FirebaseFirestore.instance.collection('admin_farmacia'); // Coleção para administradores de farmácia
final CollectionReference adminAppCollection = FirebaseFirestore.instance.collection('admin_app'); // Coleção para administradores da app
final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users'); // Coleção para utilizadores comuns

class GerirUsuarios extends StatefulWidget {
  @override
  _GerirUsuariosState createState() => _GerirUsuariosState();
}

class _GerirUsuariosState extends State<GerirUsuarios> {
  String selectedType = 'users'; // Tipo de usuário selecionado por padrão
  List<AdminFarmaciaModel> administradores = []; // Lista completa de administradores de farmácia
  List<UserModel> usuariosComuns = []; // Lista completa de utilizadores comuns
  List<AdminAppModel> administradoresApp = []; // Lista completa de administradores da app

  List<AdminFarmaciaModel> administradoresFiltrados = []; // Lista filtrada de administradores de farmácia
  List<UserModel> usuariosComunsFiltrados = []; // Lista filtrada de utilizadores comuns
  List<AdminAppModel> administradoresAppFiltrados = []; // Lista filtrada de administradores da app

  String? adminSelecionadoUid; // UID do admin de farmácia selecionado
  String? userSelecionadoId; // ID do utilizador comum selecionado
  String? adminAppSelecionadoUid; // UID do admin da app selecionado
  bool isLoading = false; // Estado de carregamento

  final TextEditingController _searchController = TextEditingController(); // Controlador para o campo de pesquisa

  @override
  void initState() {
    super.initState();
    _carregarDadosPorTipo(); // Carrega os dados iniciais com base no tipo padrão
    _searchController.addListener(_onSearchChanged); // Ouve mudanças no campo de pesquisa
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filtrarListas(); // Filtra as listas quando o texto de pesquisa muda
  }

  void _filtrarListas() {
    setState(() {
      final query = _searchController.text.toLowerCase();

      if (selectedType == 'farmácias') {
        administradoresFiltrados = query.isEmpty
            ? List.from(administradores)
            : administradores
            .where((admin) =>
        admin.nome.toLowerCase().contains(query) ||
            admin.email.toLowerCase().contains(query) ||
            admin.username.toLowerCase().contains(query))
            .toList();
      } else if (selectedType == 'users') {
        usuariosComunsFiltrados = query.isEmpty
            ? List.from(usuariosComuns)
            : usuariosComuns
            .where((user) =>
        user.nome.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query))
            .toList();
      } else if (selectedType == 'app') {
        administradoresAppFiltrados = query.isEmpty
            ? List.from(administradoresApp)
            : administradoresApp
            .where((admin) =>
        admin.nome.toLowerCase().contains(query) ||
            admin.email.toLowerCase().contains(query))
            .toList();
      }

      // Limpa as seleções ao filtrar para evitar seleção de itens que não estão mais visíveis
      adminSelecionadoUid = null;
      userSelecionadoId = null;
      adminAppSelecionadoUid = null;
    });
  }

  Future<void> _carregarDadosPorTipo() async {
    if (isLoading) return; // Evita múltiplas chamadas de carregamento

    setState(() {
      isLoading = true;
      // Limpa todas as listas e seleções antes de carregar novos dados
      administradores.clear();
      usuariosComuns.clear();
      administradoresApp.clear();
      adminSelecionadoUid = null;
      userSelecionadoId = null;
      adminAppSelecionadoUid = null;
      _searchController.clear(); // Limpa a pesquisa ao mudar de tipo/carregar
      // Também limpa as listas filtradas imediatamente para evitar dados obsoletos
      administradoresFiltrados.clear();
      usuariosComunsFiltrados.clear();
      administradoresAppFiltrados.clear();
    });

    try {
      if (selectedType == 'farmácias') {
        final snapshot = await farmaciasCollection.get();
        final dados = snapshot.docs.map((doc) => AdminFarmaciaModel.fromFirestore(doc)).toList();
        setState(() {
          administradores = dados;
        });
      } else if (selectedType == 'users') {
        final snapshot = await usersCollection.get();
        // ✅ CORREÇÃO AQUI: Usa UserModel.fromMap corretamente com doc.data() e doc.id
        final dados = snapshot.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
        setState(() {
          usuariosComuns = dados;
        });
      } else if (selectedType == 'app') {
        final snapshot = await adminAppCollection.get();
        final dados = snapshot.docs.map((doc) => AdminAppModel.fromFirestore(doc)).toList();
        setState(() {
          administradoresApp = dados;
        });
      }
    } catch (e) {
      print("Erro ao carregar dados: $e");
      _mostrarMensagem("Erro ao carregar dados: ${e.toString()}", Colors.red);
    } finally {
      setState(() => isLoading = false);
      _filtrarListas(); // Chama _filtrarListas() APÓS o carregamento dos dados para aplicar o filtro inicial
    }
  }

  void _mostrarMensagem(String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
        duration: const Duration(seconds: 2), // Usar const Duration para melhor performance
      ),
    );
  }

  // --- Lógica de Remoção ---
  Future<void> _removerSelecionado() async {
    String? idParaRemover; // Renomeado para 'idParaRemover' para ser mais genérico (UID ou ID)
    CollectionReference? collectionParaRemover;
    String tipoDeUtilizador = "";
    String nomeDoItem = ""; // Para mostrar no diálogo

    if (selectedType == 'farmácias' && adminSelecionadoUid != null) {
      idParaRemover = adminSelecionadoUid;
      collectionParaRemover = farmaciasCollection;
      tipoDeUtilizador = "Administrador de Farmácia";
      nomeDoItem = administradores.firstWhere((admin) => admin.uid == idParaRemover).nome;
    } else if (selectedType == 'users' && userSelecionadoId != null) {
      idParaRemover = userSelecionadoId;
      collectionParaRemover = usersCollection;
      tipoDeUtilizador = "Utilizador Comum";
      nomeDoItem = usuariosComuns.firstWhere((user) => user.uid == idParaRemover).nome; // ✅ Usa user.uid
    } else if (selectedType == 'app' && adminAppSelecionadoUid != null) {
      idParaRemover = adminAppSelecionadoUid;
      collectionParaRemover = adminAppCollection;
      tipoDeUtilizador = "Administrador da App";
      nomeDoItem = administradoresApp.firstWhere((admin) => admin.uid == idParaRemover).nome;
    }

    if (idParaRemover == null || collectionParaRemover == null) {
      _mostrarMensagem("Nenhum item selecionado para remover.", Colors.orange);
      return;
    }

    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Remoção"),
          content: Text("Tem certeza que deseja remover '$nomeDoItem' ($tipoDeUtilizador)? Esta ação é irreversível."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Remover", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;

    if (!confirm) {
      _mostrarMensagem("Remoção cancelada.", Colors.grey);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await collectionParaRemover.doc(idParaRemover).delete();
      _mostrarMensagem("$tipoDeUtilizador removido com sucesso!", Colors.green);
      await _carregarDadosPorTipo(); // Recarrega os dados após a remoção

    } catch (e) {
      print("Erro ao remover documento: $e");
      _mostrarMensagem("Erro ao remover $tipoDeUtilizador: ${e.toString()}", Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  // --- Fim da Lógica de Remoção ---

  // --- Lógica de Atualização (Chamada para a tela EditarUser) ---
  Future<void> _atualizarSelecionado() async {
    dynamic selectedObject; // Objeto do modelo selecionado (UserModel, AdminAppModel, AdminFarmaciaModel)
    String? currentSelectedId; // O ID/UID que está selecionado

    // Identifica o objeto selecionado com base no tipo e no ID/UID armazenado
    if (selectedType == 'farmácias' && adminSelecionadoUid != null) {
      currentSelectedId = adminSelecionadoUid;
      selectedObject = administradores.firstWhere((admin) => admin.uid == currentSelectedId);
    } else if (selectedType == 'users' && userSelecionadoId != null) {
      currentSelectedId = userSelecionadoId;
      selectedObject = usuariosComuns.firstWhere((user) => user.uid == currentSelectedId); // ✅ Usa user.uid
    } else if (selectedType == 'app' && adminAppSelecionadoUid != null) {
      currentSelectedId = adminAppSelecionadoUid;
      selectedObject = administradoresApp.firstWhere((admin) => admin.uid == currentSelectedId);
    }

    if (selectedObject == null || currentSelectedId == null) {
      _mostrarMensagem("Nenhum item selecionado para atualizar.", Colors.orange);
      return;
    }

    // Navega para a tela EditarUser, passando o tipo e o objeto selecionado
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarUser(
          selectedType: selectedType, // Passa o tipo de usuário
          selectedUser: selectedObject, // Passa o objeto do modelo selecionado
        ),
      ),
    );

    // Se a edição foi bem-sucedida (EditarUser retorna 'true'), recarrega os dados
    if (result == true) {
      _mostrarMensagem("Informações atualizadas com sucesso!", Colors.green);
      await _carregarDadosPorTipo();
    }
  }
  // --- Fim da Lógica de Atualização ---

  // Verifica se o botão de ação (remover/atualizar) deve estar habilitado
  bool _isActionButtonEnabled() {
    if (selectedType == 'farmácias') {
      return adminSelecionadoUid != null;
    } else if (selectedType == 'users') {
      return userSelecionadoId != null;
    } else if (selectedType == 'app') {
      return adminAppSelecionadoUid != null;
    }
    return false;
  }

  // --- Lógica do Botão Criar Novo Usuário ---
  Future<void> _criarNovoUsuario() async {
    dynamic result;
    if (selectedType == 'farmácias') {
      // Navega para a tela de registro de administradores de farmácia
      result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegistoFarmacias()), // Assumindo que RegistoFarmacias pode criar um novo admin de farmácia
      );
    } else if (selectedType == 'users') {
      // Navega para a tela de registro de utilizadores comuns
      result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegistoUsuario()),
      );
    } else if (selectedType == 'app') {
      // Navega para a tela de criação de administradores da App
      result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CriarAdminApp()), // Assumindo que CriarAdminApp é para criar um novo admin da app
      );
    } else {
      _mostrarMensagem("Selecione um tipo de utilizador para criar.", Colors.orange);
      return;
    }

    // Se a criação foi bem-sucedida (a tela de registro retorna 'true'), recarregar os dados
    if (result == true) {
      _mostrarMensagem("Utilizador criado com sucesso!", Colors.green);
      await _carregarDadosPorTipo();
    }
  }
  // --- Fim da Lógica do Botão Criar ---

  Widget _buildActionButtons() {
    final bool isActionEnabled = _isActionButtonEnabled();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildOutlinedButton(
            "Remover",
            Icons.delete,
            onPressed: isActionEnabled ? _removerSelecionado : null,
          ),
          _buildOutlinedButton(
            "Criar",
            Icons.add,
            onPressed: _criarNovoUsuario, // Botão de criar sempre habilitado para o tipo selecionado
          ),
          _buildOutlinedButton(
            "Atualizar",
            Icons.update,
            onPressed: isActionEnabled ? _atualizarSelecionado : null,
          ),
        ],
      ),
    );
  }

  // Widget de botão com estilo OutlinedButton
  Widget _buildOutlinedButton(String label, IconData icon, {VoidCallback? onPressed}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: onPressed == null ? Colors.grey : Colors.green[700]),
      label: Text(
        label,
        style: TextStyle(color: onPressed == null ? Colors.grey : Colors.green[700]),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: onPressed == null ? Colors.grey : Colors.green[700]!, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: Colors.white,
      ),
    );
  }

  // Widget para o campo de pesquisa
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Pesquisar pelo nome, email ou username...', // Dica de pesquisa aprimorada
          prefixIcon: Icon(Icons.search, color: Colors.green[700]),
          filled: true,
          fillColor: Colors.green[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green),
          ),
        ),
      ),
    );
  }

  // Widget para seleção do tipo de usuário (botões "Users", "Farmácias", "App")
  Widget _buildTypeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTypeButton("Users"),
          _buildTypeButton("Farmácias"),
          _buildTypeButton("App"),
        ],
      ),
    );
  }

  // Widget que constrói a lista de usuários/administradores com base no tipo selecionado
  Widget _buildListaPorTipo() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<dynamic> currentList;
    String emptyMessage;

    if (selectedType == 'farmácias') {
      currentList = administradoresFiltrados;
      emptyMessage = "Nenhum administrador de farmácia encontrado.";
    } else if (selectedType == 'users') {
      currentList = usuariosComunsFiltrados;
      emptyMessage = "Nenhum utilizador comum encontrado.";
    } else if (selectedType == 'app') {
      currentList = administradoresAppFiltrados;
      emptyMessage = "Nenhum administrador da App encontrado.";
    } else {
      currentList = [];
      emptyMessage = "Selecione um tipo de utilizador para ver a lista.";
    }

    if (currentList.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      itemCount: currentList.length,
      itemBuilder: (context, index) {
        final item = currentList[index];
        bool isSelected = false;
        String name = '';
        String id = ''; // Pode ser UID ou ID do documento

        // Identifica o tipo de item e preenche 'isSelected', 'name' e 'id'
        if (item is AdminFarmaciaModel) {
          isSelected = adminSelecionadoUid == item.uid;
          name = item.nome;
          id = item.uid; // ID do documento é o UID
        } else if (item is UserModel) {
          isSelected = userSelecionadoId == item.uid; // ✅ Agora usa item.uid
          name = item.nome;
          id = item.uid; // ✅ Agora usa item.uid
        } else if (item is AdminAppModel) {
          isSelected = adminAppSelecionadoUid == item.uid;
          name = item.nome;
          id = item.uid; // ID do documento é o UID
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              // Atualiza o UID/ID selecionado com base no tipo de item
              if (item is AdminFarmaciaModel) {
                adminSelecionadoUid = isSelected ? null : id;
              } else if (item is UserModel) {
                userSelecionadoId = isSelected ? null : id; // ✅ Agora usa id para userSelecionadoId
              } else if (item is AdminAppModel) {
                adminAppSelecionadoUid = isSelected ? null : id;
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green[100] : Colors.white,
              border: Border.all(
                color: isSelected ? Colors.green[700]! : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.green[900] : Colors.black,
                  ),
                ),
                Text(
                  'Email: ${item.email}', // Exibe o email para todos os tipos
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                if (item is AdminFarmaciaModel) // Detalhes específicos para AdminFarmacia
                  Text(
                    'ID Farmácia: ${item.idFarmacia}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                if (item is AdminFarmaciaModel) // Detalhes específicos para AdminFarmacia
                  Text(
                    'Username: ${item.username}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                // REMOVIDO: Detalhes específicos para UserModel (papel), pois não existe mais
                // if (item is UserModel)
                //   Text(
                //     'Papel: ${item.papel}',
                //     style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                //   ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget de botão para seleção de tipo de usuário
  Widget _buildTypeButton(String label) {
    final lowerLabel = label.toLowerCase(); // Converte o label para minúsculas para comparação
    final isSelected = selectedType == lowerLabel;

    return ElevatedButton(
      onPressed: () {
        if (selectedType != lowerLabel) { // Só recarrega se o tipo mudou
          setState(() {
            selectedType = lowerLabel;
            // Limpa todas as listas e seleções ao mudar de tipo
            administradores.clear();
            usuariosComuns.clear();
            administradoresApp.clear();
            adminSelecionadoUid = null;
            userSelecionadoId = null;
            adminAppSelecionadoUid = null;
            _searchController.clear(); // Limpa a pesquisa ao mudar de tipo
            // Também limpa as listas filtradas imediatamente ao mudar de tipo
            administradoresFiltrados.clear();
            usuariosComunsFiltrados.clear();
            administradoresAppFiltrados.clear();
          });
          _carregarDadosPorTipo(); // Recarrega os dados para o novo tipo selecionado
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green[600] : Colors.white, // Cor de fundo
        foregroundColor: isSelected ? Colors.white : Colors.green[800], // Cor do texto/ícone
        side: const BorderSide(color: Colors.green, width: 2), // Borda
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Formato arredondado
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Preenchimento
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestão de Utilizadores"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2.5, color: Colors.green[700]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSearchField(), // Campo de pesquisa
              _buildTypeSelection(), // Botões de seleção de tipo
              const SizedBox(height: 10),
              Expanded(child: _buildListaPorTipo()), // Lista de usuários/administradores
              _buildActionButtons(), // Botões de ação (remover, criar, atualizar)
            ],
          ),
        ),
      ),
    );
  }
}