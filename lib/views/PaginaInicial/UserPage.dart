import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:farmacia2pdm/views/CriarUsers/RegistoFarmacias.dart';
import 'package:farmacia2pdm/views/Logins/LoginPage.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    await _cameraController.initialize();
    if (mounted) {
      setState(() {
        _isCameraReady = true;
      });
    }
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
      _markers.add(
        Marker(
          markerId: const MarkerId('meu_local'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'Você está aqui'),
        ),
      );
    });
  }

  Future<void> _takePicture() async {
    if (!_isCameraReady || !_cameraController.value.isInitialized) {
      return;
    }

    try {
      final XFile picture = await _cameraController.takePicture();
      setState(() {
        _imageFile = File(picture.path);
      });

      // Mostra um diálogo com a foto tirada
      if (_imageFile != null) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Foto tirada'),
            content: Image.file(_imageFile!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao tirar foto: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
          EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
          child: Column(
            children: [
              Container(
                height: height * 0.07,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.green.shade700),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.menu, color: Colors.green[700]),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.login, color: Colors.green),
                                    title: const Text("Login"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const LoginPage()),
                                      );
                                    },
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading:
                                    const Icon(Icons.local_pharmacy, color: Colors.green),
                                    title:
                                    const Text("Registar-se como nova Farmacia"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const RegistoFarmacias()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.green[700]),
                      onPressed: _showImageSourceDialog,
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Pesquisar medicamento",
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: width * 0.04),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.green[700]),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.02),

              // Mostra a imagem selecionada/tipada se existir
              if (_imageFile != null)
                Container(
                  height: height * 0.2,
                  margin: EdgeInsets.only(bottom: height * 0.02),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                ),

              // Mapa
              Expanded(
                child: _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
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
}