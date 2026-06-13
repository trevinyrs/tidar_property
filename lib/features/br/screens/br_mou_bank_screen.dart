import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'br_mou_bank_upload_screen.dart';
import 'br_mou_bank_detail_screen.dart';
import '../../../core/services/mou_service.dart';
import '../../../models/mou_model.dart';
import '../../../widgets/custom_app_bar.dart';

class BrMouBankScreen extends StatefulWidget {
  const BrMouBankScreen({super.key});

  @override
  State<BrMouBankScreen> createState() => _BrMouBankScreenState();
}

class _BrMouBankScreenState extends State<BrMouBankScreen> {
  String _searchQuery = "";
  String _selectedFilter = "All";
  late Stream<List<MouDocument>> _mousStream;

  @override
  void initState() {
    super.initState();
    _mousStream = Provider.of<MouService>(context, listen: false).getMousStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomAppBar(
        titleText: "MoU Bank",
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Text(
                "Mengelola semua MOU bank",
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ),

            // Tambah MoU Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BrMouBankUploadScreen(bankName: "Bank Mandiri")),
                    );
                  },
                  icon: const Icon(Icons.add, size: 20, color: Colors.white),
                  label: const Text(
                    "Tambah MoU",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F658A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Main StreamBuilder wrapping stats and list to avoid flicker
            StreamBuilder<List<MouDocument>>(
              stream: _mousStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ));
                }
                final mous = snapshot.data ?? [];
                final bankMous = mous.where((m) => m.jenisMou == 'Bank').toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Realtime (MOU AKTIF, DALAM PROSES)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildRealtimeStatCard("MOU AKTIF", const Color(0xFF1F658A), bankMous),
                          const SizedBox(width: 12),
                          _buildRealtimeStatCard("DALAM PROSES", Colors.orange, bankMous),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Search Bar & Filter Chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val.trim().toLowerCase();
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Search by bank name...",
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(28),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  _buildFilterChip("All"),
                                  const SizedBox(width: 8),
                                  _buildFilterChip("Active"),
                                  const SizedBox(width: 8),
                                  _buildFilterChip("Draf"),
                                  const SizedBox(width: 8),
                                  _buildFilterChip("In Proces"),
                                  const SizedBox(width: 8),
                                  _buildFilterChip("Revisi"),
                                  const SizedBox(width: 8),
                                  _buildFilterChip("Menunggu TTD"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bank List
                    if (bankMous.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            "Belum ada berkas MoU Bank terdaftar.",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      )
                    else
                      ...bankMous.map((mou) {
                        final status = mou.statusMou.toUpperCase();
                        Color statusColor;
                        if (status == 'AKTIF') {
                          statusColor = Colors.green;
                        } else if (status == 'REVISI') {
                          statusColor = Colors.red;
                        } else if (status == 'MENUNGGU TTD') {
                          statusColor = Colors.orange;
                        } else {
                          statusColor = const Color(0xFF96D3FD); // Draf / Process
                        }

                        return _buildBankItem(
                          context: context,
                          logoWidget: mou.logoUrl != null && mou.logoUrl!.isNotEmpty
                              ? Image.network(
                                  mou.logoUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: const Color(0xFF0F4C81),
                                  child: Center(
                                    child: Text(
                                      mou.idBank != null && mou.idBank!.isNotEmpty ? mou.idBank![0].toUpperCase() : "B",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                          bankName: mou.idBank ?? "Bank Tanpa Nama",
                          description: mou.catatan ?? "Kemitraan strategis untuk penyediaan KPR dan fasilitas pembiayaan.",
                          status: status,
                          statusColor: statusColor,
                          validText: "DRAF DIUNGGAH\n${mou.fileName}",
                          mou: mou,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BrMouBankDetailScreen(mou: mou),
                              ),
                            );
                          },
                        );
                      }),
                  ],
                );
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1F658A) : const Color(0xFFEDF1F4),
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
    );
  }

  Widget _buildBankItem({
    required BuildContext context,
    required Widget logoWidget,
    required String bankName,
    required String description,
    required String status,
    required Color statusColor,
    required String validText,
    required MouDocument mou,
    required VoidCallback onTap,
  }) {
    if (_searchQuery.isNotEmpty && !bankName.toLowerCase().contains(_searchQuery)) {
      return const SizedBox.shrink();
    }
    
    // Filtering logic
    if (_selectedFilter != "All") {
      final s = status.toUpperCase();
      if (_selectedFilter == "Active" && s != "AKTIF") return const SizedBox.shrink();
      if (_selectedFilter == "Draf" && s != "DRAF") return const SizedBox.shrink();
      if (_selectedFilter == "In Proces" && s != "DRAF") return const SizedBox.shrink(); // Assuming Draf is In Proces
      if (_selectedFilter == "Revisi" && s != "REVISI") return const SizedBox.shrink();
      if (_selectedFilter == "Menunggu TTD" && s != "MENUNGGU TTD") return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: logoWidget,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor == Colors.grey ? Colors.grey.shade700 : statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Hapus MoU"),
                                content: const Text("Apakah Anda yakin ingin menghapus dokumen MoU ini? Tindakan ini tidak dapat dibatalkan dan file akan dihapus."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("Batal"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      final mouService = Provider.of<MouService>(context, listen: false);
                                      // Hapus file
                                      await mouService.deleteMouFile(mou.fileMou);
                                      // Hapus dokumen di database
                                      await mouService.deleteMou(mou.idMou);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("MoU berhasil dihapus")),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text("Hapus", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  bankName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEDF1F4)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            validText.split('\n').first,
                            style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            validText.split('\n').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDF1F4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRealtimeStatCard(String title, Color color, List<MouDocument> mous) {
    int count = 0;
    if (title == "MOU AKTIF") {
      count = mous.where((m) => m.statusMou.toUpperCase() == 'AKTIF').length;
    } else if (title == "DALAM PROSES") {
      count = mous.where((m) => m.statusMou.toUpperCase() != 'AKTIF').length;
    }
    String countText = count < 10 ? "0$count" : "$count";

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              countText,
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