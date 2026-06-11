import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/property_service.dart';
import '../../../models/property_model.dart';
import '../../../models/user_model.dart';
import 'add_property_screen.dart';
import 'edit_property_screen.dart';

class BrPropertyListScreen extends StatefulWidget {
  const BrPropertyListScreen({super.key});

  @override
  State<BrPropertyListScreen> createState() => _BrPropertyListScreenState();
}

class _BrPropertyListScreenState extends State<BrPropertyListScreen> {
  final PropertyService _propertyService = PropertyService();
  String _searchQuery = "";
  String _selectedFilter = "Semua";

  final List<String> _filterOptions = [
    "Semua",
    "rumah",
    "apartemen",
    "tanah",
    "ruko",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: "Search properties by name or location",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        // Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                bool isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter == "Semua" ? "Semua" : filter.toUpperCase()),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1E88E5),
                    onSelected: (selected) => setState(() => _selectedFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // List Properti BR
        Expanded(
          child: StreamBuilder<List<Property>>(
            stream: _propertyService.getProperties(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var properties = snapshot.data ?? [];

              if (_searchQuery.isNotEmpty) {
                properties = properties.where((p) =>
                    p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    p.location.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
              }

              if (_selectedFilter != "Semua") {
                properties = properties.where((p) =>
                    p.type.toLowerCase() == _selectedFilter.toLowerCase()).toList();
              }

              if (properties.isEmpty) {
                return const Center(child: Text("Tidak ada properti"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  return _buildBrPropertyCard(context, properties[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Card khusus BR dengan tombol Edit & Hapus
  Widget _buildBrPropertyCard(BuildContext context, Property property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              property.imageUrls.isNotEmpty ? property.imageUrls.first : "https://picsum.photos/id/1015/600/400",
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Chip(
                      label: Text(property.status),
                      backgroundColor: _getStatusColor(property.status),
                    ),
                  ],
                ),
                Text(property.location, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text(
                  "Rp ${property.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                ),

                const SizedBox(height: 16),

                // Tombol Aksi BR
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditPropertyScreen(property: property),
                            ),
                          );
                        },
                        child: const Text("Edit"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _confirmDelete(context, property),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text("Hapus"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Konfirmasi Hapus
  void _confirmDelete(BuildContext context, Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Properti?"),
        content: Text("Apakah Anda yakin ingin menghapus properti:\n${property.title}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool success = await _propertyService.deleteProperty(property.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Properti berhasil dihapus"), backgroundColor: Colors.green),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "AVAILABLE": return const Color.fromARGB(255, 0, 255, 8)!;
      case "BOOKING": return const Color.fromARGB(255, 255, 153, 0)!;
      case "SOLD": return const Color.fromARGB(255, 255, 0, 25)!;
      default: return Colors.grey[100]!;
    }
  }
}