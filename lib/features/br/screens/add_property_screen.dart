import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../../core/providers/user_provider.dart';
import '../../../core/services/property_service.dart';
import '../../../core/services/project_service.dart';
import '../../../models/property_model.dart';
import '../../../models/project_model.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();

  int _bedrooms = 3;
  int _bathrooms = 2;
  final _landAreaController = TextEditingController(text: "500");
  final _buildingAreaController = TextEditingController(text: "280");

  String _selectedType = "rumah";
  String _selectedStatus = "AVAILABLE";
  String? _selectedProjectId;

  bool _isLoading = false;
  List<File> _selectedImages = [];
  double? _latitude;
  double? _longitude;

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (result != null) {
        setState(() {
          final newPaths = result.paths.where((path) => path != null).map((path) => File(path!));
          _selectedImages.addAll(newPaths);
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  Future<void> _submitProperty(String? currentUserId, {required String status}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final property = Property(
      idProperti: "",
      idProyek: _selectedProjectId ?? "dummy_proyek",
      kodeUnit: "UNIT-${DateTime.now().millisecondsSinceEpoch}",
      tipeRumah: _selectedType,
      luasTanah: double.tryParse(_landAreaController.text) ?? 0,
      luasBangunan: double.tryParse(_buildingAreaController.text) ?? 0,
      kamarTidur: _bedrooms,
      kamarMandi: _bathrooms,
      harga: double.tryParse(_priceController.text) ?? 0,
      statusProperti: status,
      createdAt: DateTime.now(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _locationController.text.trim(),
      location: _locationController.text.trim(),
      agentId: currentUserId ?? "unknown",
      latitude: _latitude,
      longitude: _longitude,
    );

    final propertyService = Provider.of<PropertyService>(context, listen: false);
    try {
      String? docId = await propertyService.tambahPropertiDenganGambar(
        properti: property,
        berkasGambar: _selectedImages,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (docId != null) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        try {
          await FilePicker.platform.clearTemporaryFiles();
        } catch (e) {
          print("Error clearing temp files: $e");
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(status == 'Draft' ? "Properti disimpan sebagai Draft!" : "Properti berhasil dipublikasikan!"),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Gagal Menyimpan Properti"),
          content: Text(
            "Terjadi kesalahan saat mengunggah foto atau menyimpan data properti:\n\n$e\n\nPenulisan data telah dibatalkan. Silakan periksa koneksi internet Anda dan coba lagi.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  bool _isGeocoding = false;

  Future<void> _geocodeAddress() async {
    final String address = _locationController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan masukkan alamat terlebih dahulu"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isGeocoding = true);

    try {
      List<geo.Location> locations = await geo.locationFromAddress(address);
      if (locations.isNotEmpty) {
        final geo.Location loc = locations.first;
        setState(() {
          _latitude = loc.latitude;
          _longitude = loc.longitude;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Koordinat ditemukan: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Alamat tidak ditemukan di peta"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal melacak alamat: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeocoding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header (Avatar di kiri, Logo di tengah, Notif di kanan) - Dashboard Style
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFEDF1F4),
                      backgroundImage: (currentUser?.fotoProfil != null && currentUser!.fotoProfil!.isNotEmpty)
                          ? NetworkImage(currentUser.fotoProfil!)
                          : null,
                      child: (currentUser?.fotoProfil == null || currentUser!.fotoProfil!.isEmpty)
                          ? const Icon(Icons.person, size: 20, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Image.asset("assets/images/logo_tidar.png", height: 36),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    color: Color(0xFF263238),
                    size: 26,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Form Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Title & Subtitle
                    const Text(
                      "Tambah Properti",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Tentukan detail struktur properti Anda",
                      style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),

                    // Card 1: Aset Visual
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Aset Visual",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Gambar beresolusi tinggi meningkatkan konversi sebesar 40%.",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),

                          // Main Image Upload Area
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                              ),
                              child: _selectedImages.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(_selectedImages.first, fit: BoxFit.cover),
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined, size: 28, color: Color(0xFF1F658A)),
                                        SizedBox(height: 8),
                                        Text("Unggah Gambar Utama", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                        SizedBox(height: 4),
                                        Text("Disarankan: 1920×1080px", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Secondary Image Placeholders/Previews
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: _selectedImages.length > 1
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.file(_selectedImages[1], fit: BoxFit.cover),
                                        )
                                      : const Icon(Icons.image_outlined, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: _selectedImages.length > 2
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.file(_selectedImages[2], fit: BoxFit.cover),
                                        )
                                      : const Icon(Icons.image_outlined, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Card 2: Detail Utama
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Detail Utama",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 20),

                          _buildInputLabel("NAMA PROPERTI"),
                          TextFormField(
                            controller: _titleController,
                            validator: (val) => val == null || val.isEmpty ? "Wajib diisi" : null,
                            decoration: _buildInputDecoration("contoh: Villa Azure Heights"),
                          ),

                          const SizedBox(height: 16),

                          _buildInputLabel("LOKASI"),
                          TextFormField(
                            controller: _locationController,
                            validator: (val) => val == null || val.isEmpty ? "Wajib diisi" : null,
                            decoration: _buildInputDecoration("Masukkan alamat lengkap").copyWith(
                              prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                              suffixIcon: _isGeocoding
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1F658A)),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.search, color: Color(0xFF1F658A)),
                                      tooltip: "Cari Koordinat",
                                      onPressed: _geocodeAddress,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Tip: Klik ikon pencarian di atas untuk mendeteksi koordinat dari alamat secara otomatis.",
                            style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                          ),

                          const SizedBox(height: 16),

                          _buildInputLabel("HARGA (RP)"),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.isEmpty ? "Wajib diisi" : null,
                            decoration: _buildInputDecoration("0.00"),
                          ),

                          const SizedBox(height: 16),

                          _buildInputLabel("TITIK KOORDINAT GMAPS"),
                          GestureDetector(
                            onTap: () async {
                              final LatLng? pickedLocation = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapPickerScreen(
                                    initialLocation: _latitude != null && _longitude != null
                                        ? LatLng(_latitude!, _longitude!)
                                        : const LatLng(-7.9602, 112.6074),
                                  ),
                                ),
                              );
                              if (pickedLocation != null) {
                                setState(() {
                                  _latitude = pickedLocation.latitude;
                                  _longitude = pickedLocation.longitude;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDF1F4),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.map_outlined, color: Color(0xFF1F658A)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _latitude == null || _longitude == null
                                          ? "Ketuk untuk memilih titik koordinat Tidar, Malang"
                                          : "Koordinat: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}",
                                      style: TextStyle(
                                        color: _latitude == null || _longitude == null ? Colors.grey.shade500 : Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Card 3: Spesifikasi
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Spesifikasi",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInputLabel("KAMAR TIDUR"),
                                    _buildCounterWidget(
                                      value: _bedrooms,
                                      onDecrease: () => setState(() => _bedrooms = _bedrooms > 0 ? _bedrooms - 1 : 0),
                                      onIncrease: () => setState(() => _bedrooms++),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInputLabel("KAMAR MANDI"),
                                    _buildCounterWidget(
                                      value: _bathrooms,
                                      onDecrease: () => setState(() => _bathrooms = _bathrooms > 0 ? _bathrooms - 1 : 0),
                                      onIncrease: () => setState(() => _bathrooms++),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInputLabel("LUAS TANAH (M2)"),
                                    TextFormField(
                                      controller: _landAreaController,
                                      keyboardType: TextInputType.number,
                                      decoration: _buildInputDecoration("500"),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInputLabel("BANGUNAN (M2)"),
                                    TextFormField(
                                      controller: _buildingAreaController,
                                      keyboardType: TextInputType.number,
                                      decoration: _buildInputDecoration("280"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                           _buildInputLabel("TIPE PROPERTI"),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: _buildInputDecoration("Pilih Tipe"),
                            items: const [
                              DropdownMenuItem(value: "rumah", child: Text("Rumah")),
                              DropdownMenuItem(value: "rumah kos", child: Text("Rumah Kos")),
                              DropdownMenuItem(value: "tanah", child: Text("Tanah")),
                            ],
                            onChanged: (value) => setState(() => _selectedType = value!),
                          ),
                          const SizedBox(height: 16),
                          _buildInputLabel("PROYEK"),
                          StreamBuilder<List<Project>>(
                            stream: Provider.of<ProjectService>(context, listen: false).getProjects(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final projects = snapshot.data!;
                              if (projects.isEmpty) {
                                return const Text(
                                  "Belum ada proyek tersedia. Harap tambahkan proyek terlebih dahulu.",
                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                );
                              }
                              // Set default project selection if null or not in list
                              if (_selectedProjectId == null || !projects.any((p) => p.idProyek == _selectedProjectId)) {
                                _selectedProjectId = projects.first.idProyek;
                              }
                              return DropdownButtonFormField<String>(
                                value: _selectedProjectId,
                                decoration: _buildInputDecoration("Pilih Proyek"),
                                items: projects.map((project) {
                                  return DropdownMenuItem(
                                    value: project.idProyek,
                                    child: Text(project.namaProyek),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => _selectedProjectId = value),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Card 4: Narasi Pemasaran
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Narasi Pemasaran",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 20),

                          _buildInputLabel("DESKRIPSI PROPERTI"),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: _buildInputDecoration("Jelaskan keunggulan arsitektur, daya tarik lingkungan, dan nilai jual unik..."),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),



                    // Publikasikan Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _submitProperty(currentUser?.uid, status: "Available"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F658A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Publikasikan Properti", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        labelText,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFEDF1F4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildCounterWidget({
    required int value,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFEDF1F4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onDecrease,
            icon: const Icon(Icons.remove, size: 18, color: Colors.black87),
          ),
          Text(
            "$value",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          IconButton(
            onPressed: onIncrease,
            icon: const Icon(Icons.add, size: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class MapPickerScreen extends StatefulWidget {
  final LatLng initialLocation;
  const MapPickerScreen({super.key, required this.initialLocation});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pilih Koordinat Lokasi",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 16,
              onTap: (tapPosition, point) {
                setState(() {
                  _currentLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tidar_property',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF1F658A), size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Koordinat Terpilih",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                "${_currentLocation.latitude.toStringAsFixed(6)}, ${_currentLocation.longitude.toStringAsFixed(6)}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, _currentLocation);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F658A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Pilih Lokasi Ini",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

