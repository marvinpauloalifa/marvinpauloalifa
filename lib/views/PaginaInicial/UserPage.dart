import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farmacia2pdm/views/CriarUsers/RegistoFarmacias.dart';
import 'package:farmacia2pdm/views/Logins/LoginPage.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  File? _imageFile;
  late CameraController _cameraController;
  bool _isCameraReady = false;
  final TextEditingController _searchController = TextEditingController();

  String? _farmaciaSelecionadaId;
  String? _farmaciaSelecionadaNome;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras.first, ResolutionPreset.medium);
    await _cameraController.initialize();
    if (mounted) setState(() => _isCameraReady = true);
  }

  Future<void> _takePicture() async {
    if (!_isCameraReady || !_cameraController.value.isInitialized) return;

    final picture = await _cameraController.takePicture();
    setState(() => _imageFile = File(picture.path));
    if (_imageFile != null) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Foto tirada'),
          content: Image.file(_imageFile!),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar fonte da imagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }
  Future<void> _buscarFarmacias(String nomeMedicamento) async {
    setState(() {
      _markers.clear();
      _farmaciaSelecionadaId = null;
      _farmaciaSelecionadaNome = null;
    });

    final query = nomeMedicamento.toLowerCase().trim();
    final snapshot = await FirebaseFirestore.instance.collection('farmacias').get();

    bool encontrou = false;

    for (var farmaciaDoc in snapshot.docs) {
      final medicamentosRef = farmaciaDoc.reference.collection('medicamentos');
      final medDoc = await medicamentosRef.doc(query).get();

      if (medDoc.exists) {
        final data = medDoc.data();
        if (data != null && (data['quantidade'] ?? 0) > 0) {
          final farmacia = farmaciaDoc.data();

          // Corrigido aqui: de 'endereco' para 'localizacao'
          final GeoPoint location = farmacia['localizacao'];
          final LatLng pos = LatLng(location.latitude, location.longitude);

          _markers.add(
            Marker(
              markerId: MarkerId(farmaciaDoc.id),
              position: pos,
              infoWindow: InfoWindow(
                title: farmacia['nome'] ?? 'Farmácia',
                onTap: () {
                  setState(() {
                    _farmaciaSelecionadaId = farmaciaDoc.id;
                    _farmaciaSelecionadaNome = farmacia['nome'] ?? 'Farmácia';
                  });
                },
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          );

          encontrou = true;
        }
      }
    }

    if (encontrou) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_markers.first.position, 14),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma farmácia encontrada com esse medicamento.')),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.02),
          child: Column(
            children: [
              _buildSearchBar(size),
              if (_imageFile != null)
                Container(
                  height: size.height * 0.2,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              if (_farmaciaSelecionadaId != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Comprar na farmácia $_farmaciaSelecionadaNome')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Comprar', style: TextStyle(fontSize: 16)),
                  ),
                ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition ?? const LatLng(-25.9692, 32.5732),
                      zoom: 14,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(Size size) {
    return Container(
      height: size.height * 0.07,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.green.shade700),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.green[700]),
            onPressed: () => _abrirMenu(),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.green[700]),
            onPressed: _showImageSourceDialog,
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Pesquisar medicamento",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green[700]),
            onPressed: () {
              final medicamento = _searchController.text.trim();
              if (medicamento.isNotEmpty) {
                _buscarFarmacias(medicamento);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Digite o nome de um medicamento.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _abrirMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.login, color: Colors.green),
                title: const Text("Login"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.local_pharmacy, color: Colors.green),
                title: const Text("Registar-se como nova Farmácia"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistoFarmacias()));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
