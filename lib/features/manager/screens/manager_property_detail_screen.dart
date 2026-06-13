import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/property_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ManagerPropertyDetailScreen extends StatelessWidget {
  final Property property;

  const ManagerPropertyDetailScreen({super.key, required this.property});

  Future<void> _launchMapUrl() async {
    final double lat = property.latitude ?? -7.9602;
    final double lng = property.longitude ?? 112.6074;
    
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    
    try {
      bool launched = await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      try {
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      } catch (err) {
        debugPrint("Gagal membuka peta Google Maps: $err");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

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
                  tag: 'manager-property-image-${property.idProperti}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    child: SizedBox(
                      height: 340,
                      width: double.infinity,
                      child: property.imageUrls.isNotEmpty
                          ? PageView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: property.imageUrls.length,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  property.imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFFEDF1F4),
                                    child: const Icon(Icons.broken_image_outlined, size: 64, color: Colors.grey),
                                  ),
                                );
                              },
                            )
                          : Image.network(
                              "https://picsum.photos/800/500",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFFEDF1F4),
                                child: const Icon(Icons.broken_image_outlined, size: 64, color: Colors.grey),
                              ),
                            ),
                    ),
                  ),
                ),
                
                // Gradient Overlay
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

                // Top Actions (Back Button)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
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
                      ],
                    ),
                  ),
                ),

                // Status Badge Overlay
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(property.status, primaryColor),
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
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: primaryColor,
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
                      color: primaryColor.withOpacity(0.06),
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
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
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
                            border: Border.all(color: primaryColor.withOpacity(0.2)),
                          ),
                          child: Text(
                            "Nego",
                            style: TextStyle(
                              color: primaryColor,
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
                          context,
                          Icons.king_bed_outlined,
                          "${property.bedrooms} Kamar",
                          "KAMAR TIDUR",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _specCard(
                          context,
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
                          context,
                          Icons.landscape_outlined,
                          "${property.landArea} m²",
                          "LUAS TANAH",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _specCard(
                          context,
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
                          context,
                          Icons.apartment_outlined,
                          property.type.toUpperCase(),
                          "TIPE PROPERTI",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _specCard(
                          context,
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
                        icon: Icon(Icons.map_outlined, size: 16, color: primaryColor),
                        label: Text(
                          "Google Maps",
                          style: TextStyle(
                            color: primaryColor,
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
                  const SizedBox(height: 36),

                  // Kembali Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 20),
                      label: const Text(
                        "Kembali ke Daftar Properti",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
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

  Color _getStatusColor(String status, Color primaryColor) {
    switch (status.toUpperCase()) {
      case "AVAILABLE":
        return primaryColor;
      case "BOOKING":
        return const Color(0xFFD97706);
      case "SOLD":
        return Colors.grey.shade500;
      default:
        return Colors.grey.shade400;
    }
  }

  Widget _specCard(BuildContext context, IconData icon, String value, String title) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: primaryColor),
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
