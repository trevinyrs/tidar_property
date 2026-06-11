import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/favorite_provider.dart';
import '../../../core/services/property_service.dart';
import '../../../models/property_model.dart';
import '../../../widgets/custom_app_bar.dart';
import 'property_detail_screen.dart';

class AgentFavoriteScreen extends StatefulWidget {
  const AgentFavoriteScreen({super.key});

  @override
  State<AgentFavoriteScreen> createState() => _AgentFavoriteScreenState();
}

class _AgentFavoriteScreenState extends State<AgentFavoriteScreen> {
  final PropertyService _propertyService = PropertyService();

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: const CustomAppBar(
        titleText: "Listing Favorit Saya",
      ),
      body: favoriteProvider.favoriteIds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Belum Ada Listing Favorit",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Ketuk ikon favorit pada properti untuk menyimpannya.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : StreamBuilder<List<Property>>(
              stream: _propertyService.getProperties(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final allProperties = snapshot.data ?? [];
                // Filter only favorited properties
                final favoritedProperties = allProperties
                    .where((p) => favoriteProvider.isFavorite(p.idProperti))
                    .toList();

                if (favoritedProperties.isEmpty) {
                  return Center(
                    child: Text(
                      "Tidak ada properti favorit aktif",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: favoritedProperties.length,
                  itemBuilder: (context, index) {
                    return _buildMockupPropertyCard(
                      context,
                      favoritedProperties[index],
                    );
                  },
                );
              },
            ),
    );
  }

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

                // Specifications Bar
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

  Color _getButtonColor(String status) {
    if (status.toUpperCase() == "BOOKING") {
      return const Color(0xFFD97706);
    }
    return const Color(0xFF1F658A);
  }

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
