import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/services/mou_service.dart';
import '../../../models/mou_model.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../core/providers/user_provider.dart';
import 'manager_mou_detail_screen.dart';

class ManagerMouListScreen extends StatefulWidget {
  const ManagerMouListScreen({super.key});

  @override
  State<ManagerMouListScreen> createState() => _ManagerMouListScreenState();
}

class _ManagerMouListScreenState extends State<ManagerMouListScreen> {
  String _selectedFilter = "Semua";
  final List<String> _filters = ["Semua", "Draf", "Revisi", "Menunggu TTD", "Aktif"];

  String _selectedUrgency = "Semua Urgensi";
  final List<String> _urgencyFilters = ["Semua Urgensi", "Normal", "Urgent"];
  
  String _selectedCategory = "Semua Kategori";
  final List<String> _categoryFilters = ["Semua Kategori", "Bank", "Agent"];
  
  String _searchQuery = "";
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  late Stream<List<MouDocument>> _mousStream;

  @override
  void initState() {
    super.initState();
    _mousStream = Provider.of<MouService>(context, listen: false).getMousStream();
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
    final secondaryColor = theme.colorScheme.secondary;
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: CustomAppBar(
        titleWidget: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Cari dokumen MoU...",
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
              color: const Color(0xFF263238),
              size: 26,
            ),
          ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TITLE & SUBTITLE ──────────────────────────────────────
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Daftar Dokumen MoU",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C2B36),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Pantau semua dokumen kemitraan bank dan agen secara menyeluruh.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF7B8D9A)),
                ),
              ],
            ),
          ),

          // ── FILTER DROPDOWNS ──────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                _buildFilterDropdown(
                  label: "Pilih Status",
                  selectedValue: _selectedFilter,
                  options: _filters,
                  onSelected: (val) => setState(() => _selectedFilter = val),
                ),
                const SizedBox(width: 8),
                _buildFilterDropdown(
                  label: "Pilih Urgensi",
                  selectedValue: _selectedUrgency,
                  options: _urgencyFilters,
                  onSelected: (val) => setState(() => _selectedUrgency = val),
                ),
                const SizedBox(width: 8),
                _buildFilterDropdown(
                  label: "Pilih Kategori",
                  selectedValue: _selectedCategory,
                  options: _categoryFilters,
                  onSelected: (val) => setState(() => _selectedCategory = val),
                ),
              ],
            ),
          ),

          // ── MOU LIST STREAM ───────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<MouDocument>>(
              stream: _mousStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada dokumen MoU",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                var documents = snapshot.data!;

                if (_searchQuery.isNotEmpty) {
                  documents = documents.where((doc) {
                    final title = doc.title.isNotEmpty ? doc.title.toLowerCase() : doc.fileName.toLowerCase();
                    return title.contains(_searchQuery);
                  }).toList();
                }

                if (_selectedFilter != "Semua") {
                  documents = documents
                      .where((doc) => doc.statusMou.toLowerCase() == _selectedFilter.toLowerCase())
                      .toList();
                }

                if (_selectedUrgency != "Semua Urgensi") {
                  documents = documents
                      .where((doc) => (doc.prioritas ?? 'Normal').toLowerCase() == _selectedUrgency.toLowerCase())
                      .toList();
                }

                if (_selectedCategory != "Semua Kategori") {
                  documents = documents
                      .where((doc) => doc.jenisMou.toLowerCase() == _selectedCategory.toLowerCase())
                      .toList();
                }

                if (documents.isEmpty) {
                  return Center(
                    child: Text(
                      "Tidak ada dokumen dengan status '$_selectedFilter'",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final mou = documents[index];
                    final title = mou.title.isNotEmpty ? mou.title : mou.fileName;
                    final category = mou.jenisMou;

                    // Badge color matching status
                    final Color badgeColor;
                    final Color badgeBg;
                    final IconData badgeIcon;

                    switch (mou.statusMou.toLowerCase()) {
                      case 'revisi':
                        badgeColor = const Color(0xFFE67E22);
                        badgeBg = const Color(0xFFFFF3E0);
                        badgeIcon = Icons.edit_note_outlined;
                        break;
                      case 'disetujui':
                      case 'aktif':
                        badgeColor = const Color(0xFF2ECC71);
                        badgeBg = const Color(0xFFE8F8F0);
                        badgeIcon = Icons.check_circle_outline;
                        break;
                      default:
                        badgeColor = primaryColor;
                        badgeBg = const Color(0xFFE3F2FF);
                        badgeIcon = Icons.schedule_outlined;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: secondaryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category.toLowerCase() == 'agent' ? Icons.person_outline : Icons.account_balance,
                            color: primaryColor,
                          ),
                        ),
                        title: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "ID: ${mou.idMou.length > 10 ? mou.idMou.substring(0, 10) : mou.idMou} • ${DateFormat('d MMM yyyy').format(mou.tanggalUpload)}",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: badgeBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(badgeIcon, size: 12, color: badgeColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          mou.statusMou,
                                          style: TextStyle(
                                            color: badgeColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1F658A).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      category.toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF1F658A),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (mou.prioritas?.toLowerCase() == 'urgent' ? Colors.red : Colors.grey).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      (mou.prioritas ?? 'Normal').toUpperCase(),
                                      style: TextStyle(
                                        color: mou.prioritas?.toLowerCase() == 'urgent' ? Colors.red : Colors.grey.shade700,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ManagerMouDetailScreen(mou: mou),
                            ),
                          );
                        },
                      ),
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

  Widget _buildFilterDropdown({
    required String label,
    required String selectedValue,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C2B36),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...options.map((option) {
                      final isSelected = selectedValue == option;
                      return ListTile(
                        title: Text(
                          option,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF1F658A) : Colors.black87,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Color(0xFF1F658A))
                            : null,
                        onTap: () {
                          onSelected(option);
                          Navigator.pop(context);
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  selectedValue,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C2B36),
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF1C2B36)),
            ],
          ),
        ),
      ),
    );
  }
}
