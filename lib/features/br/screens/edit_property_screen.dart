import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/property_service.dart';
import '../../../models/property_model.dart';

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
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _landAreaController;
  late TextEditingController _buildingAreaController;

  late String _selectedType;
  late String _selectedStatus;

  final PropertyService _propertyService = PropertyService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.property.title);
    _descriptionController = TextEditingController(text: widget.property.description);
    _locationController = TextEditingController(text: widget.property.location);
    _priceController = TextEditingController(text: widget.property.price.toString());
    _bedroomsController = TextEditingController(text: widget.property.bedrooms.toString());
    _bathroomsController = TextEditingController(text: widget.property.bathrooms.toString());
    _landAreaController = TextEditingController(text: widget.property.landArea.toString());
    _buildingAreaController = TextEditingController(text: widget.property.buildingArea.toString());

    _selectedType = widget.property.type;
    _selectedStatus = widget.property.status;
  }

  Future<void> _updateProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedProperty = Property(
      id: widget.property.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      address: widget.property.address,
      location: _locationController.text.trim(),
      price: double.tryParse(_priceController.text) ?? widget.property.price,
      type: _selectedType,
      bedrooms: int.tryParse(_bedroomsController.text) ?? widget.property.bedrooms,
      bathrooms: int.tryParse(_bathroomsController.text) ?? widget.property.bathrooms,
      landArea: double.tryParse(_landAreaController.text) ?? widget.property.landArea,
      buildingArea: double.tryParse(_buildingAreaController.text) ?? widget.property.buildingArea,
      status: _selectedStatus,
      agentId: widget.property.agentId,
      createdAt: widget.property.createdAt,
    );

    bool success = await _propertyService.updateProperty(updatedProperty);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Properti berhasil diupdate!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Kembali dengan refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengupdate properti")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Properti")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: "Judul Properti *"), validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
              const SizedBox(height: 12),
              TextFormField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: "Deskripsi Properti")),
              const SizedBox(height: 12),
              TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: "Lokasi *"), validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
              const SizedBox(height: 12),
              TextFormField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Harga (Rp) *"), validator: (v) => v!.isEmpty ? "Wajib diisi" : null),

              const SizedBox(height: 24),
              const Text("Spesifikasi Properti", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: TextFormField(controller: _bedroomsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Kamar Tidur"))),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _bathroomsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Kamar Mandi"))),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: TextFormField(controller: _landAreaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Luas Tanah (m²)"))),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _buildingAreaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Luas Bangunan (m²)"))),
                ],
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: "Tipe Properti"),
                items: const [
                  DropdownMenuItem(value: "rumah", child: Text("Rumah")),
                  DropdownMenuItem(value: "apartemen", child: Text("Apartemen")),
                  DropdownMenuItem(value: "tanah", child: Text("Tanah")),
                  DropdownMenuItem(value: "ruko", child: Text("Ruko")),
                ],
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: "Status Properti"),
                items: const [
                  DropdownMenuItem(value: "AVAILABLE", child: Text("Available")),
                  DropdownMenuItem(value: "BOOKING", child: Text("Booking")),
                  DropdownMenuItem(value: "SOLD", child: Text("Sold")),
                ],
                onChanged: (value) => setState(() => _selectedStatus = value!),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProperty,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Simpan Perubahan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}