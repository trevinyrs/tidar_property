import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/favorite_provider.dart';
import '../../../models/property_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  Future<void> _openWhatsApp(String agentName) async {
    final String message = "Halo Kak, saya *(isikan nama anda)*.\n\nSaya tertarik dengan proyek *${property.title}* dan ingin mendapatkan informasi lebih lanjut terkait harga, ketersediaan unit, spesifikasi bangunan, serta promo yang sedang berlangsung.\n\nTerima kasih, saya menunggu informasinya.";
    final Uri url = Uri.parse("https://wa.me/6281230170280?text=${Uri.encodeComponent(message)}");
    await launchUrl(url, mode: LaunchMode.inAppBrowserView);
  }

  Future<void> _launchMapUrl() async {
    final double lat = property.latitude ?? -7.9602;
    final double lng = property.longitude ?? 112.6074;
    
    // Google Maps search URL with exact coordinates pin
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    
    try {
      // Direct launch in external application
      bool launched = await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Fallback to browser
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      // Secondary fallback
      try {
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      } catch (err) {
        debugPrint("Gagal membuka peta Google Maps: $err");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSold = property.status.toUpperCase() == "SOLD";
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final agentName = userProvider.currentUser?.name ?? "Agent TIMPRO";
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFavorite = favoriteProvider.isFavorite(property.idProperti);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER IMAGE WITH PREMIUM OVERLAYS
            Stack(
              children: [
                Hero(
                  tag: 'property-image-${property.idProperti}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    child: Image.network(
                      property.imageUrls.isNotEmpty
                          ? property.imageUrls.first
                          : "https://picsum.photos/800/500",
                      height: 340,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 340,
                        width: double.infinity,
                        color: const Color(0xFFEDF1F4),
                        child: const Icon(Icons.broken_image_outlined, size: 64, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                
                // Gradient Overlay for readability of top buttons
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                  ),
                ),

                // Top Actions (Back and Favorite)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF1C2D37)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.redAccent : const Color(0xFF1C2D37),
                            ),
                            onPressed: () => favoriteProvider.toggleFavorite(property.idProperti),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Status Badge Overlay at bottom-left of the image
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(property.status),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Text(
                      property.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // PROPERTY CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Title Row
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF1F658A),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          property.location,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Property Title
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C2D37),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F658A).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Harga Penawaran",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rp ${property.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F658A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF1F658A).withOpacity(0.2)),
                          ),
                          child: const Text(
                            "Nego",
                            style: TextStyle(
                              color: Color(0xFF1F658A),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Specifications Grid
                  const Text(
                    "Spesifikasi Properti",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C2D37),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _specCard(
                          Icons.king_bed_outlined,
                          "${property.bedrooms} Kamar",
                          "KAMAR TIDUR",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _specCard(
                          Icons.bathtub_outlined,
                          "${property.bathrooms} Kamar",
                          "KAMAR MANDI",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _specCard(
                          Icons.landscape_outlined,
                          "${property.landArea} m²",
                          "LUAS TANAH",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _specCard(
                          Icons.home_outlined,
                          "${property.buildingArea} m²",
                          "LUAS BANGUNAN",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _specCard(
                          Icons.apartment_outlined,
                          property.type.toUpperCase(),
                          "TIPE PROPERTI",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _specCard(
                          Icons.qr_code_scanner_outlined,
                          property.kodeUnit.toUpperCase(),
                          "KODE UNIT",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Description
                  const Text(
                    "Tentang Properti",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C2D37),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.description.isNotEmpty
                        ? property.description
                        : "Properti premium dengan desain modern, tata ruang yang optimal, dan berada di lokasi strategis yang sangat berkembang.",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Map/Location Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Lokasi Properti",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C2D37),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _launchMapUrl,
                        icon: const Icon(Icons.map_outlined, size: 16, color: Color(0xFF1F658A)),
                        label: const Text(
                          "Google Maps",
                          style: TextStyle(
                            color: Color(0xFF1F658A),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // OSM Map Container
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(property.latitude ?? -7.9602, property.longitude ?? 112.6074),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.tidar_property',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(property.latitude ?? -7.9602, property.longitude ?? 112.6074),
                              width: 60,
                              height: 60,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Agent/Advisor Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.015),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFF1F658A).withOpacity(0.1),
                          child: const Icon(Icons.person_outline, color: Color(0xFF1F658A), size: 28),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Advisor TIMPRO",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1C2D37),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Layanan Kemitraan Resmi",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Premium Action Button
                  isSold
                      ? SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: TextButton(
                            onPressed: null,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: Text(
                              "Unit Sudah Terjual",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => _openWhatsApp(agentName),
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                            label: const Text(
                              "Hubungi BR Sekarang",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F658A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Soft/Solid Modern Status Colors
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "AVAILABLE":
        return const Color(0xFF1F658A); // Primary Blue
      case "BOOKING":
        return const Color(0xFFD97706); // Amber Orange
      case "SOLD":
        return Colors.grey.shade500; // Muted Grey
      default:
        return Colors.grey.shade400;
    }
  }

  // Spec Card styled with modern light grey card layout
  Widget _specCard(IconData icon, String value, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF1F658A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1C2D37),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
