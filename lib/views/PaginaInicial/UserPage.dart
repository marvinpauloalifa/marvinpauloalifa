import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/UserViewModel.dart';
import '../CriarUsers/RegistoFarmacias.dart';
import '../Logins/LoginPage.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
    // Busca a localização assim que o widget for inicializado
    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    viewModel.fetchUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
          child: Column(
            children: [
              Container(
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
                                        MaterialPageRoute(builder: (context) => const LoginPage()),
                                      );
                                    },
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.local_pharmacy, color: Colors.green),
                                    title: const Text("Registar-se como nova Farmacia"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RegistoFarmacias()),
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
                      onPressed: () => _showImageSourceDialog(context, viewModel),
                    ),
                    Expanded(
                      child: TextField(
                        controller: viewModel.searchController,
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
                        final query = viewModel.searchController.text;
                        print("Pesquisar: $query");
                        // Adicione a lógica de pesquisa aqui
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              if (viewModel.selectedImage != null)
                Container(
                  height: size.height * 0.2,
                  margin: EdgeInsets.only(bottom: size.height * 0.02),
                  child: Image.file(viewModel.selectedImage!, fit: BoxFit.cover),
                ),

              Expanded(
                child: viewModel.userPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      viewModel.setMapController(controller);
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        viewModel.userPosition!.latitude,
                        viewModel.userPosition!.longitude,
                      ),
                      zoom: 14,
                    ),
                    markers: viewModel.mapMarkers,
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

  void _showImageSourceDialog(BuildContext context, UserViewModel viewModel) {
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
                viewModel.selectImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                viewModel.selectImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }
}
