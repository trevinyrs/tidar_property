import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../../core/services/property_service.dart';
import '../../../models/property_model.dart';
import 'add_property_screen.dart'; // To reuse MapPickerScreen if needed, or we declare it here

class EditPropertyScreen extends StatefulWidget {
  final Property property;

  const EditPropertyScreen({super.key, required this.property});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _landAreaController;
  late TextEditingController _buildingAreaController;

  late int _bedrooms;
  late int _bathrooms;

  late String _selectedType;
  late String _selectedStatus;

  bool _isLoading = false;
  List<File> _selectedImages = [];
  double? _latitude;
  double? _longitude;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.property.title);
    _descriptionController = TextEditingController(text: widget.property.description);
    _locationController = TextEditingController(text: widget.property.location);
    _priceController = TextEditingController(text: widget.property.price.toStringAsFixed(0));
    _landAreaController = TextEditingController(text: widget.property.landArea.toStringAsFixed(0));
    _buildingAreaController = TextEditingController(text: widget.property.buildingArea.toStringAsFixed(0));

    _bedrooms = widget.property.bedrooms;
    _bathrooms = widget.property.bathrooms;

    _selectedType = widget.property.type.toLowerCase();
    _selectedStatus = widget.property.status.toUpperCase();

    _latitude = widget.property.latitude;
    _longitude = widget.property.longitude;
  }

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (result != null) {
        setState(() {
          final newPaths = result.paths.where((path) => path != null).map((path) => File(path!));
          _selectedImages.clear(); // Replace/overwrite completely to save space
          _selectedImages.addAll(newPaths);
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

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

  Future<void> _updateProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedProperty = Property(
      idProperti: widget.property.idProperti,
      idProyek: widget.property.idProyek,
      kodeUnit: widget.property.kodeUnit,
      tipeRumah: _selectedType,
      luasTanah: double.tryParse(_landAreaController.text) ?? widget.property.luasTanah,
      luasBangunan: double.tryParse(_buildingAreaController.text) ?? widget.property.luasBangunan,
      kamarTidur: _bedrooms,
      kamarMandi: _bathrooms,
      harga: double.tryParse(_priceController.text) ?? widget.property.harga,
      statusProperti: _selectedStatus,
      createdAt: widget.property.createdAt,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _locationController.text.trim(),
      location: _locationController.text.trim(),
      agentId: widget.property.agentId,
      brId: widget.property.brId,
      imageUrls: widget.property.imageUrls,
      latitude: _latitude,
      longitude: _longitude,
    );

    final propertyService = Provider.of<PropertyService>(context, listen: false);
    
    bool success = await propertyService.updatePropertiDenganGambar(
      properti: updatedProperty,
      berkasGambar: _selectedImages,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      try {
        await FilePicker.platform.clearTemporaryFiles();
      } catch (e) {
        print("Error clearing temp files: $e");
      }
      messenger.showSnackBar(
        const SnackBar(content: Text("✅ Properti berhasil diupdate!"), backgroundColor: Colors.green),
      );
      navigator.pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengupdate properti")),
      );
    }
  }

  Future<void> _confirmDeleteProperty() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final propertyService = Provider.of<PropertyService>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Properti?"),
        content: const Text(
          "Apakah Anda yakin ingin menghapus properti ini secara permanen? Seluruh foto dan data properti akan dihapus dari sistem.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await propertyService.deleteProperty(widget.property.idProperti);
      
      if (mounted) {
        setState(() => _isLoading = false);
      }

      if (success) {
        messenger.showSnackBar(
          const SnackBar(content: Text("✅ Properti berhasil dihapus!"), backgroundColor: Colors.green),
        );
        navigator.pop(true); // Go back and refresh
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text("Gagal menghapus properti"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Edit Properti",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
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
                      "Edit Properti",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Sesuaikan detail dan spesifikasi properti Anda",
                      style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),

                    // Card 1: Aset Visual (Sama seperti Tambah Properti)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
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
                            "Mengunggah gambar baru akan menggantikan (menimpa) gambar yang ada agar hemat penyimpanan.",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),

                          // Main Image Picker Area
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: _selectedImages.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(_selectedImages.first, fit: BoxFit.cover),
                                    )
                                  : (widget.property.imageUrls.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.network(widget.property.imageUrls.first, fit: BoxFit.cover),
                                        )
                                      : const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add_photo_alternate_outlined, size: 28, color: Color(0xFF1F658A)),
                                            SizedBox(height: 8),
                                            Text("Unggah Gambar Baru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                          ],
                                        )),
                            ),
                          ),
                          if (_selectedImages.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Gambar baru dipilih. Gambar lama akan otomatis terhapus saat Anda menekan simpan.",
                                    style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
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
                            decoration: _buildInputDecoration("Villa Azure Heights"),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Spesifikasi & Kategori",
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
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
                            decoration: _buildInputDecoration("Jelaskan keunggulan arsitektur..."),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Simpan Perubahan Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProperty,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F658A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Simpan Perubahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Hapus Properti Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _confirmDeleteProperty,
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        label: const Text(
                          "Hapus Properti",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
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