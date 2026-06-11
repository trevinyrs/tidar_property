import 'package:flutter/material.dart';
import 'package:tidar_property/core/services/property_service.dart';
import 'package:tidar_property/features/br/screens/br_property_list_screen.dart';
import 'package:tidar_property/models/property_model.dart';
import 'add_property_screen.dart';

class BrStockScreen extends StatelessWidget {
  const BrStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: StreamBuilder<List<Property>>(
          stream: PropertyService().getProperties(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error : ${snapshot.error}"));
            }

            final properties = snapshot.data ?? [];

            final totalStock = properties.length;
            final available = properties
                .where((p) => p.status == "AVAILABLE")
                .length;
            final booking = properties
                .where((p) => p.status == "BOOKING")
                .length;
            final soldOut = properties.where((p) => p.status == "SOLD").length;

            return Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundImage: AssetImage(
                              "assets/images/profile.png",
                            ),
                          ),
                          const SizedBox(width: 10),

                          Image.asset(
                            "assets/images/logo_tidar.png",
                            height: 38,
                          ),
                        ],
                      ),

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Color(0xFF263238),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= HEADER =================
                        const Text(
                          "Stock Management",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F4C75),
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "Review and manage your real estate portfolio.",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text(
                              "Tambah Properti",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddPropertyScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D6EFD),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ================= STATISTICS =================
                        Row(
                          children: [
                            _buildStatCard(
                              "TOTAL STOCK",
                              totalStock.toString(),
                              const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              "AVAILABLE",
                              available.toString(),
                              const Color(0xFF16A34A),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            _buildStatCard(
                              "BOOKING",
                              booking.toString(),
                              const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              "SOLD OUT",
                              soldOut.toString(),
                              const Color(0xFF64748B),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),


                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.tune, size: 18),
                            label: const Text("Filters"),
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ================= PROPERTY LIST =================
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const BrPropertyListScreen(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        height: 95,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
