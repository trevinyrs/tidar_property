import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/property_service.dart';
import '../../../models/property_model.dart';
import '../../../models/user_model.dart';
import '../../../widgets/custom_app_bar.dart';
import 'property_detail_screen.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final PropertyService _propertyService = PropertyService();

  String _searchQuery = "";
  String _selectedFilter = "Semua";
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, String>> _filterOptions = [
    {"value": "Semua", "label": "All Properties"},
    {"value": "rumah", "label": "Rumah"},
    {"value": "rumah kos", "label": "Rumah Kos"},
    {"value": "tanah", "label": "Tanah"},
  ];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: CustomAppBar(
        titleWidget: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Cari properti...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
                style: const TextStyle(fontSize: 16, color: Color(0xFF1C2D37)),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFEDF1F4),
                    backgroundImage: (user?.fotoProfil != null && user!.fotoProfil!.isNotEmpty)
                        ? NetworkImage(user!.fotoProfil!)
                        : null,
                    child: (user?.fotoProfil == null || user!.fotoProfil!.isEmpty)
                        ? const Icon(Icons.person, size: 20, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Image.asset(
                    "assets/images/logo_tidar.png",
                    height: 38,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      "TIMPRO",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F658A),
                      ),
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = "";
                } else {
                  _isSearching = true;
                }
              });
            },
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              size: 26,
              color: const Color(0xFF1C2D37),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // HERO SECTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Discover Spaces.",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C2D37),
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Curated properties for discerning lifestyles.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // FILTER CHIPS (Horizontal scrolling)
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  final filter = _filterOptions[index];
                  final isSelected = _selectedFilter == filter["value"];

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter["value"]!;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1F658A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            if (!isSelected)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            filter["label"]!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // PROPERTY STREAM LIST
            Expanded(
              child: StreamBuilder<List<Property>>(
                stream: _propertyService.getProperties(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1F658A),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  var properties = snapshot.data ?? [];

                  if (_searchQuery.isNotEmpty) {
                    properties = properties.where((p) =>
                        p.title.toLowerCase().contains(_searchQuery) ||
                        p.location.toLowerCase().contains(_searchQuery)
                    ).toList();
                  }

                  if (_selectedFilter != "Semua") {
                    properties = properties
                        .where(
                          (p) =>
                              p.type.toLowerCase() ==
                              _selectedFilter.toLowerCase(),
                        )
                        .toList();
                  }

                  if (properties.isEmpty) {
                    return Center(
                      child: Text(
                        "Tidak ada properti ditemukan",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      return _buildMockupPropertyCard(
                        context,
                        properties[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Card matched with the UI mockup image
  Widget _buildMockupPropertyCard(BuildContext context, Property property) {
    final isSold = property.status.toUpperCase() == "SOLD";

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section with Status Badge Overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Image.network(
                  property.imageUrls.isNotEmpty
                      ? property.imageUrls.first
                      : "https://picsum.photos/600/400",
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getBadgeBgColor(property.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    property.status.toUpperCase(),
                    style: TextStyle(
                      color: _getBadgeTextColor(property.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F658A).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    property.type.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF1F658A),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  property.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C2D37),
                  ),
                ),
                const SizedBox(height: 4),

                // Location info
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Attention-Grabbing Specifications Bar
                Row(
                  children: [
                    _buildMiniSpec(Icons.king_bed_outlined, "${property.bedrooms} KT"),
                    const SizedBox(width: 12),
                    _buildMiniSpec(Icons.bathtub_outlined, "${property.bathrooms} KM"),
                    const SizedBox(width: 12),
                    _buildMiniSpec(Icons.landscape_outlined, "${property.landArea.toStringAsFixed(0)} m² LT"),
                    const SizedBox(width: 12),
                    _buildMiniSpec(Icons.home_outlined, "${property.buildingArea.toStringAsFixed(0)} m² LB"),
                  ],
                ),
                const SizedBox(height: 14),

                // Price tag
                Text(
                  "Rp ${property.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                  style: const TextStyle(
                    color: Color(0xFF1F658A),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 16),

                // Conditional Action Buttons based on status
                isSold
                    ? SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: TextButton(
                          onPressed: null,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            "Unavailable",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyDetailScreen(
                                  property: property,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getButtonColor(property.status),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            "Lihat Detail",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dynamic solid button colors for AVAILABLE / BOOKING
  Color _getButtonColor(String status) {
    if (status.toUpperCase() == "BOOKING") {
      return const Color(0xFFD97706); // Solid amber orange
    }
    return const Color(0xFF1F658A); // Solid primary blue (default/AVAILABLE)
  }

  // Soft Badge Backgrounds matching design and mockup
  Color _getBadgeBgColor(String status) {
    switch (status.toUpperCase()) {
      case "AVAILABLE":
        return const Color(0xFF96D3FD).withOpacity(0.25);
      case "BOOKING":
        return const Color(0xFFECEFF1);
      case "SOLD":
        return const Color(0xFFEEEEEE);
      default:
        return Colors.grey[100]!;
    }
  }

  // Soft Badge Text Colors matching design and mockup
  Color _getBadgeTextColor(String status) {
    switch (status.toUpperCase()) {
      case "AVAILABLE":
        return const Color(0xFF1F658A);
      case "BOOKING":
        return const Color(0xFF455A64);
      case "SOLD":
        return const Color(0xFF757575);
      default:
        return Colors.grey[600]!;
    }
  }

  Widget _buildMiniSpec(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF1F658A)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
