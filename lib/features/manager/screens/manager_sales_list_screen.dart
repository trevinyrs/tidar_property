import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manager_sales_detail_screen.dart';

class ManagerSalesListScreen extends StatefulWidget {
  const ManagerSalesListScreen({super.key});

  @override
  State<ManagerSalesListScreen> createState() => _ManagerSalesListScreenState();
}

class _ManagerSalesListScreenState extends State<ManagerSalesListScreen> {
  String _searchQuery = "";
  String _selectedFilter = "Terbaru";

  final List<String> _filterOptions = [
    "Terbaru",
    "Terlama",
    "Harga Tertinggi",
    "Harga Terendah",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          "Riwayat Closing",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Cari Properti, Unit, atau Agen...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFEDF1F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // Filter Chips
          Container(
            color: Colors.white,
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilter = filter);
                        }
                      },
                      selectedColor: primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tb_penjualan')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Belum ada riwayat closing."));
                }

                final docs = snapshot.data!.docs;
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['properti_title'] ?? data['title'] ?? '').toString().toLowerCase();
                  final unit = (data['kode_unit'] ?? data['unit'] ?? '').toString().toLowerCase();
                  final agent = (data['nama_agen'] ?? data['agent'] ?? '').toString().toLowerCase();
                  
                  return title.contains(_searchQuery) ||
                         unit.contains(_searchQuery) ||
                         agent.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("Pencarian tidak ditemukan."));
                }

                // Sorting Logic
                filteredDocs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  
                  if (_selectedFilter == "Terbaru" || _selectedFilter == "Terlama") {
                    final timeA = dataA['created_at'] != null ? (dataA['created_at'] as Timestamp).toDate() : DateTime.fromMillisecondsSinceEpoch(0);
                    final timeB = dataB['created_at'] != null ? (dataB['created_at'] as Timestamp).toDate() : DateTime.fromMillisecondsSinceEpoch(0);
                    
                    return _selectedFilter == "Terbaru" ? timeB.compareTo(timeA) : timeA.compareTo(timeB);
                  } else {
                    final priceA = (dataA['harga'] ?? dataA['price'] ?? 0).toDouble();
                    final priceB = (dataB['harga'] ?? dataB['price'] ?? 0).toDouble();
                    
                    return _selectedFilter == "Harga Tertinggi" ? priceB.compareTo(priceA) : priceA.compareTo(priceB);
                  }
                });

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 10, bottom: 40),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    final title = data['properti_title'] ?? data['title'] ?? 'Aset Tidar';
                    final unit = data['kode_unit'] ?? data['unit'] ?? 'Unit';
                    final harga = (data['harga'] ?? data['price'] ?? 0).toDouble();
                    final agent = data['nama_agen'] ?? data['agent'] ?? 'Agen Tidar';
                    final priceText = "Rp ${harga.toStringAsFixed(0)}";

                    return _buildClosingItem(
                      title: title,
                      unit: unit,
                      price: priceText,
                      agent: agent,
                      primaryColor: primaryColor,
                      rawData: data,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingItem({
    required String title,
    required String unit,
    required String price,
    required String agent,
    required Color primaryColor,
    required Map<String, dynamic> rawData,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ManagerSalesDetailScreen(data: rawData)));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10)
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.home_work_outlined, size: 22, color: primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                    const SizedBox(height: 2),
                    Text("$unit • Agent: $agent", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                  const SizedBox(height: 2),
                  const Text("CLOSING SUCCESS", style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
