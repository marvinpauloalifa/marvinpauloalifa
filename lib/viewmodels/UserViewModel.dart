// lib/viewmodels/UserViewModel.dart
import 'dart:io'; // Para o tipo File
import 'package:flutter/material.dart'; // Para ChangeNotifier e TextEditingController
import 'package:geolocator/geolocator.dart'; // Para obter a localização do utilizador
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Para marcadores do mapa
import 'package:image_picker/image_picker.dart'; // Para seleção de imagens

class UserViewModel extends ChangeNotifier {
  // Controlador para o campo de pesquisa de medicamento
  final TextEditingController searchController = TextEditingController();

  // Posição atual do utilizador
  Position? userPosition;

  // Controlador do GoogleMap para interação programática com o mapa
  GoogleMapController? mapController;

  // Imagem selecionada pelo utilizador (da câmera ou galeria)
  File? _selectedImage;
  File? get selectedImage => _selectedImage; // Getter para acessar a imagem selecionada

  // Conjunto de marcadores a serem exibidos no mapa
  // Usamos um Set para garantir que não haja marcadores duplicados
  final Set<Marker> _mapMarkers = {};
  Set<Marker> get mapMarkers => _mapMarkers; // Getter para acessar os marcadores do mapa

  // Define o controlador do mapa assim que o GoogleMap for criado
  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  // --- Funções de Localização ---

  // Busca a localização atual do utilizador
  Future<void> fetchUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se os serviços de localização estão ativados no dispositivo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Serviços de localização desativados.');
      return Future.error('Serviços de localização desativados.');
    }

    // Verifica e solicita permissão de localização ao utilizador
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permissões de localização negadas');
        return Future.error('Permissões de localização negadas');
      }
    }

    // Verifica se as permissões foram permanentemente negadas
    if (permission == LocationPermission.deniedForever) {
      print('Permissões de localização permanentemente negadas');
      return Future.error('Permissões de localização permanentemente negadas.');
    }

    // Obtém a posição atual do utilizador
    userPosition = await Geolocator.getCurrentPosition();

    // Adiciona o marcador da localização do utilizador ao conjunto de marcadores
    // Isso garante que o marcador do utilizador esteja sempre presente no mapa
    _mapMarkers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(userPosition!.latitude, userPosition!.longitude),
        infoWindow: const InfoWindow(title: 'Você está aqui'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Marcador azul para o utilizador
      ),
    );
    notifyListeners(); // Notifica os Widgets que dependem deste ViewModel para reconstruir
  }

  // Limpa todos os marcadores do mapa e, em seguida, adiciona de volta apenas o do utilizador,
  // se a localização do utilizador estiver disponível.
  void clearAndResetMarkers() {
    _mapMarkers.clear(); // Limpa todos os marcadores
    if (userPosition != null) {
      // Adiciona o marcador do utilizador de volta
      _mapMarkers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(userPosition!.latitude, userPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Você está aqui'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }
    notifyListeners(); // Notifica os Widgets sobre as mudanças
  }

  // Adiciona um marcador de farmácia específico ao mapa
  void addFarmacyMarker(String id, double latitude, double longitude, String title, String snippet) {
    final marker = Marker(
      markerId: MarkerId(id), // ID único para o marcador da farmácia
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(title: title, snippet: snippet), // Título e snippet para o InfoWindow
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // Marcador verde para farmácias
    );
    _mapMarkers.add(marker); // Adiciona o novo marcador ao conjunto
    notifyListeners(); // Notifica os Widgets
  }

  // --- Funções de Seleção de Imagem ---

  final ImagePicker _picker = ImagePicker(); // Instância do ImagePicker

  // Permite ao utilizador selecionar uma imagem da câmera
  Future<void> selectImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path); // Armazena o File da imagem
      notifyListeners(); // Notifica os Widgets para exibir a imagem
    }
  }

  // Permite ao utilizador selecionar uma imagem da galeria
  Future<void> selectImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path); // Armazena o File da imagem
      notifyListeners(); // Notifica os Widgets para exibir a imagem
    }
  }
}
