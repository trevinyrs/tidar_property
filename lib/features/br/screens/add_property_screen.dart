import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/property_service.dart';
import '../../../models/property_model.dart';

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

  final _bedroomsController = TextEditingController(text: "0");
  final _bathroomsController = TextEditingController(text: "0");
  final _landAreaController = TextEditingController(text: "0");
  final _buildingAreaController = TextEditingController(text: "0");

  String _selectedType = "rumah";
  String _selectedStatus = "AVAILABLE";

  final PropertyService _propertyService = PropertyService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Tambah Properti Baru"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Properti
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Judul Properti *",
                ),
                validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Deskripsi Properti",
                ),
              ),
              const SizedBox(height: 16),

              // Lokasi
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "Lokasi (Kota / Alamat) *",
                ),
                validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Harga
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Harga (Rp) *"),
                validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 24),

              // Spesifikasi Properti
              const Text(
                "Spesifikasi Properti",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bedroomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Kamar Tidur",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bathroomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Kamar Mandi",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _landAreaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Luas Tanah (m²)",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _buildingAreaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Luas Bangunan (m²)",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tipe Properti
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: "Tipe Properti"),
                items: const [
                  DropdownMenuItem(value: "rumah", child: Text("Rumah")),
                  DropdownMenuItem(
                    value: "apartemen",
                    child: Text("Apartemen"),
                  ),
                  DropdownMenuItem(value: "tanah", child: Text("Tanah")),
                  DropdownMenuItem(value: "ruko", child: Text("Ruko")),
                ],
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),

              // Status Properti
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: "Status Properti"),
                items: const [
                  DropdownMenuItem(
                    value: "AVAILABLE",
                    child: Text("Available"),
                  ),
                  DropdownMenuItem(value: "BOOKING", child: Text("Booking")),
                  DropdownMenuItem(value: "SOLD", child: Text("Sold")),
                ],
                onChanged: (value) => setState(() => _selectedStatus = value!),
              ),

              const SizedBox(height: 40),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => _isLoading = true);

                          final property = Property(
                            id: "",
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            address: _locationController.text.trim(),
                            location: _locationController.text.trim(),
                            price: double.tryParse(_priceController.text) ?? 0,
                            type: _selectedType,
                            bedrooms:
                                int.tryParse(_bedroomsController.text) ?? 0,
                            bathrooms:
                                int.tryParse(_bathroomsController.text) ?? 0,
                            landArea:
                                double.tryParse(_landAreaController.text) ?? 0,
                            buildingArea:
                                double.tryParse(_buildingAreaController.text) ??
                                0,
                            status: _selectedStatus,
                            agentId: currentUser?.uid ?? "unknown",
                            createdAt: DateTime.now(),
                          );

                          String? docId = await _propertyService.addProperty(
                            property,
                          );

                          if (mounted) {
                            setState(() => _isLoading = false);
                            if (docId != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Properti berhasil ditambahkan!",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Simpan Properti",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
