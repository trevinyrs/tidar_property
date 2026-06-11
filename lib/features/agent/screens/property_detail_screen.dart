import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  Future<void> _openWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/6281230170280");

    await launchUrl(url, mode: LaunchMode.inAppBrowserView);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Image.network(
                    property.imageUrls.isNotEmpty
                        ? property.imageUrls.first
                        : "https://picsum.photos/800/500",
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.9),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.9),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 70,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(property.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      property.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Rp\n${property.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                        style: const TextStyle(
                          fontSize: 30,
                          height: 1.1,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "Negotiable",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _specCard(
                        Icons.bed_outlined,
                        "${property.bedrooms}",
                        "KAMAR TIDUR",
                      ),
                      _specCard(
                        Icons.bathtub_outlined,
                        "${property.bathrooms}",
                        "KAMAR MANDI",
                      ),
                      _specCard(
                        Icons.square_foot,
                        "${property.landArea}",
                        "LUAS TANAH",
                      ),
                      _specCard(
                        Icons.home_work_outlined,
                        "${property.buildingArea}",
                        "LUAS BANGUNAN",
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Tentang Properti",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    property.description.isNotEmpty
                        ? property.description
                        : "Properti premium dengan desain modern dan lokasi strategis.",
                    style: TextStyle(color: Colors.grey.shade700, height: 1.7),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Lokasi",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Lihat di Google Map"),
                      ),
                    ],
                  ),

                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.grey.shade300,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.location_pin,
                        size: 80,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(radius: 28, child: Icon(Icons.person)),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Budi Raharjo",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("Senior Property Advisor"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openWhatsApp,
                      icon: const Icon(Icons.chat),
                      label: const Text("Hubungi BR"),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Kontak"),
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

  // Warna Status Badge sesuai permintaan
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "AVAILABLE":
        return const Color.fromARGB(255, 0, 255, 8)!;
      case "BOOKING":
        return const Color.fromARGB(255, 255, 153, 0)!;
      case "SOLD":
        return const Color.fromARGB(255, 255, 0, 25)!;
      default:
        return Colors.grey[100]!;
    }
  }

  Widget _specCard(IconData icon, String value, String title) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1565C0)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.grey[700]),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
