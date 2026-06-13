import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'br_mou_agent_upload_screen.dart';
import 'mou_tracking_detail_screen.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/mou_service.dart';
import '../../../models/user_model.dart';
import '../../../models/mou_model.dart';
import '../../../widgets/custom_app_bar.dart';

class BrMouAgentScreen extends StatefulWidget {
  const BrMouAgentScreen({super.key});

  @override
  State<BrMouAgentScreen> createState() => _BrMouAgentScreenState();
}

class _BrMouAgentScreenState extends State<BrMouAgentScreen> {
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
        titleText: "Manajemen Agent MoU",
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
                "Kelola kemitraan strategis dengan agen properti profesional dalam ekosistem Anda.",
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500, height: 1.4),
              ),
            ),

            // Tambah Agent Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate directly to upload doc screen with default info
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BrMouAgentUploadScreen(
                          agentName: "Andi Wijaya",
                          company: "Ray White Menteng",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 20, color: Colors.white),
                  label: const Text(
                    "Tambah Agent",
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
                final agentMous = mous.where((m) => m.jenisMou == 'Agent').toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Realtime (MOU AKTIF, DALAM PROSES)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildRealtimeStatCard("MOU AKTIF", const Color(0xFF1F658A), agentMous),
                          const SizedBox(width: 12),
                          _buildRealtimeStatCard("DALAM PROSES", Colors.orange, agentMous),
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
                                hintText: "Search by agent name...",
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

                    // Agent List
                    if (agentMous.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            "Belum ada berkas MoU Agent terdaftar.",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      )

                    else
                      ...agentMous.map((mou) {
                        final status = mou.statusMou.toUpperCase();
                        Color statusColor;
                        if (status == 'AKTIF') {
                          statusColor = Colors.blue.shade600;
                        } else if (status == 'REVISI') {
                          statusColor = Colors.red.shade400;
                        } else if (status == 'MENUNGGU TTD') {
                          statusColor = Colors.orange;
                        } else {
                          statusColor = Colors.purple.shade400; // Proses / Draf
                        }

                        return _buildAgentItem(
                          context: context,
                          mou: mou,
                          iconData: Icons.home_work_outlined,
                          name: mou.namaPrincipal != null && mou.namaPrincipal!.isNotEmpty ? mou.namaPrincipal! : "Principal Tanpa Nama",
                          company: mou.idAgent ?? "Agen Tanpa Nama",
                          status: status,
                          statusColor: statusColor,
                          footerText: "${mou.fileSize ?? 'Ukuran tidak diketahui'} • ${mou.fileName}",
                        );
                      }),
                  ],
                );
              },
            ),

            const SizedBox(height: 120),
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

  Widget _buildAgentItem({
    required BuildContext context,
    required MouDocument mou,
    required IconData iconData,
    required String name,
    required String company,
    required String status,
    required Color statusColor,
    required String footerText,
  }) {
    if (_searchQuery.isNotEmpty && !name.toLowerCase().contains(_searchQuery)) {
      return const SizedBox.shrink();
    }
    
    // Filtering logic based on requested filters
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MouTrackingDetailScreen(
                mou: mou,
                agentName: name,
                company: company,
              ),
            ),
          );
        },
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
                    mou.logoUrl != null && mou.logoUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              mou.logoUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(iconData, color: statusColor, size: 24),
                          ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
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
                  company,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEDF1F4)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        footerText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDF1F4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right, color: Colors.black54, size: 16),
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
                fontSize: 26,
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
