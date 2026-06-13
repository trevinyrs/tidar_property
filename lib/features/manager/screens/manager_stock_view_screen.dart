import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/property_service.dart';
import '../../../models/property_model.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../core/providers/user_provider.dart';
import 'manager_property_detail_screen.dart';

class ManagerStockViewScreen extends StatefulWidget {
  const ManagerStockViewScreen({super.key});

  @override
  State<ManagerStockViewScreen> createState() => _ManagerStockViewScreenState();
}

class _ManagerStockViewScreenState extends State<ManagerStockViewScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedStatus = "All"; // All, Available, Sold
  late Stream<List<Property>> _propertiesStream;

  @override
  void initState() {
    super.initState();
    _propertiesStream = Provider.of<PropertyService>(context, listen: false).getProperties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        titleWidget: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFEDF1F4),
              backgroundImage: (user?.fotoProfil != null && user!.fotoProfil!.isNotEmpty)
                  ? NetworkImage(user.fotoProfil!)
                  : null,
              child: (user?.fotoProfil == null || user!.fotoProfil!.isEmpty)
                  ? const Icon(Icons.person, size: 20, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Image.asset(
              "assets/images/logo_tidar.png",
              height: 36,
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
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFF263238),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Property>>(
              stream: _propertiesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final properties = snapshot.data ?? [];

                // Compute statistics
                final totalStock = properties.length;
                final available = properties.where((p) => p.status.toUpperCase() == "AVAILABLE").length;
                final sold = properties.where((p) => p.status.toUpperCase() == "SOLD").length;

                // Apply search & status filter
                var filteredProperties = properties;
                if (_searchQuery.isNotEmpty) {
                  filteredProperties = filteredProperties.where((p) =>
                      p.title.toLowerCase().contains(_searchQuery) ||
                      p.location.toLowerCase().contains(_searchQuery) ||
                      p.kodeUnit.toLowerCase().contains(_searchQuery) ||
                      p.type.toLowerCase().contains(_searchQuery)).toList();
                }
                if (_selectedStatus != "All") {
                  filteredProperties = filteredProperties.where((p) =>
                      p.status.toUpperCase() == _selectedStatus.toUpperCase()).toList();
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Subtitle
                      const SizedBox(height: 20),
                      Text(
                        "Stock Management",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Review and manage your real estate portfolio.",
                        style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),

                      // Statistics Grid
                      Row(
                        children: [
                          _buildStatCard("TOTAL STOCK", totalStock.toString(), const Color(0xFF1F658A)),
                          const SizedBox(width: 12),
                          _buildStatCard("AVAILABLE", available.toString(), const Color(0xFF10B981)),
                          const SizedBox(width: 12),
                          _buildStatCard("SOLD OUT", sold.toString(), const Color(0xFF6B7280)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Search Field
                      TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim().toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search properties by name or location",
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFEDF1F4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Filter Selection Row (3 Chips)
                      Row(
                        children: [
                          _buildFilterChip("All"),
                          const SizedBox(width: 8),
                          _buildFilterChip("Available"),
                          const SizedBox(width: 8),
                          _buildFilterChip("Sold"),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Property list
                      filteredProperties.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text("Tidak ada properti ditemukan", style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredProperties.length,
                              itemBuilder: (context, index) {
                                return _buildPropertyItem(context, filteredProperties[index]);
                              },
                            ),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        height: 100, // Menyeragamkan tinggi card
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color, height: 1.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isActive = _selectedStatus.toLowerCase() == label.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatus = label;
          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? primaryColor : const Color(0xFFEDF1F4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyItem(BuildContext context, Property property) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final priceStr = property.price >= 1000000000
        ? "${(property.price / 1000000000).toStringAsFixed(1)}M"
        : property.price >= 1000000
            ? "${(property.price / 1000000).toStringAsFixed(1)}Jt"
            : "${property.price}";

    Color statusColor;
    switch (property.status.toUpperCase()) {
      case "AVAILABLE":
        statusColor = const Color(0xFF10B981);
        break;
      case "SOLD":
      default:
        statusColor = const Color(0xFF6B7280);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 100,
              height: 100,
              color: const Color(0xFFEDF1F4),
              child: property.imageUrls.isNotEmpty
                  ? Image.network(
                      property.imageUrls.first,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.home_work_outlined, color: Colors.grey, size: 32),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.home_work_outlined, color: Colors.grey, size: 32),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        property.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    Text(
                      "Rp $priceStr",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  property.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ManagerPropertyDetailScreen(property: property),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text("Lihat Detail", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
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
}
