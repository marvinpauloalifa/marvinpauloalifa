import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../services/CameraService.dart';
import '../services/LocationService.dart';
import '../services/OCR.dart';

class UserViewModel extends ChangeNotifier {
  final CameraService _cameraService = CameraService();
  final LocationService _locationService = LocationService();
  final OCRService _ocrService = OCRService();

  final TextEditingController searchController = TextEditingController();

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  String _recognizedText = '';
  String get recognizedText => _recognizedText;

  Position? _userPosition;
  Position? get userPosition => _userPosition;

  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;

  Set<Marker> _mapMarkers = {};
  Set<Marker> get mapMarkers => _mapMarkers;

  Future<void> selectImageFromCamera() async {
    final XFile? xfile = await _cameraService.takePicture();
    if (xfile != null) {
      _selectedImage = File(xfile.path);
      notifyListeners();
      await extractTextFromImage();
    }
  }

  Future<void> selectImageFromGallery() async {
    final XFile? xfile = await _cameraService.pickFromGallery();
    if (xfile != null) {
      _selectedImage = File(xfile.path);
      notifyListeners();
      await extractTextFromImage();
    }
  }

  Future<void> extractTextFromImage() async {
    if (_selectedImage != null) {
      _recognizedText = await _ocrService.recognizeTextFromImage(_selectedImage!);
      searchController.text = _recognizedText; // <-- texto vai para barra de pesquisa
      notifyListeners();
    }
  }

  Future<void> fetchUserLocation() async {
    try {
      _userPosition = await _locationService.getCurrentLocation();
      notifyListeners();
      if (_userPosition != null) {
        addMarker(
          LatLng(_userPosition!.latitude, _userPosition!.longitude),
          'Localização Atual',
        );
      }
    } catch (e) {
      print('Erro ao obter localização: $e');
    }
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  void addMarker(LatLng position, String title) {
    final marker = Marker(
      markerId: MarkerId(title),
      position: position,
      infoWindow: InfoWindow(title: title),
    );
    _mapMarkers.add(marker);
    notifyListeners();
  }
}
