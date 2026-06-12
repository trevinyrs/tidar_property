import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'br_mou_agent_upload_screen.dart';
import 'mou_tracking_detail_screen.dart';
import '../../../core/services/auth_service.dart';
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

            // Statistics Realtime (TOTAL AGENT, AKTIF, KADALUARSA)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildRealtimeStatCard(context, "TOTAL AGENT", null, const Color(0xFF1F658A)),
                  const SizedBox(width: 12),
                  _buildRealtimeStatCard(context, "AKTIF", "Aktif", Colors.green),
                  const SizedBox(width: 12),
                  _buildRealtimeStatCard(context, "KADALUARSA", "Expired", Colors.red),
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
                    Row(
                      children: [
                        _buildFilterChip("All"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Active"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Expired"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Mock Data or Realtime List matching mockup 1
            _buildAgentItem(
              context: context,
              iconData: Icons.home_work_outlined,
              name: "Andi Wijaya",
              company: "Ray White Menteng",
              status: "AKTIF",
              statusColor: Colors.blue.shade600,
              footerText: "Aktif sejak 12 Jun 2024",
            ),
            _buildAgentItem(
              context: context,
              iconData: Icons.handshake_outlined,
              name: "Siska Pratama",
              company: "Century 21 Unity",
              status: "PROSES",
              statusColor: Colors.purple.shade400,
              footerText: "Pengajuan 02 Mar 2024",
            ),
            _buildAgentItem(
              context: context,
              iconData: Icons.history,
              name: "Bambang Susanto",
              company: "Independent Broker",
              status: "KADALUARSA",
              statusColor: Colors.red.shade400,
              footerText: "Berakhir 28 Feb 2024",
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
    if (_selectedFilter == "Active" && status != "AKTIF") return const SizedBox.shrink();
    if (_selectedFilter == "Expired" && status != "KADALUARSA") return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () {
          final mockMou = MouDocument(
            idMou: 'mock_mou_${name.replaceAll(' ', '_')}',
            idAgent: name,
            jenisMou: 'Agent',
            fileMou: 'MoU_Kemitraan_Agent.pdf',
            tanggalUpload: DateTime.now().subtract(const Duration(days: 1)),
            statusMou: status == 'PROSES' ? 'Revisi' : (status == 'AKTIF' ? 'Aktif' : 'Draf'),
            catatanRevisi: status == 'PROSES' ? 'Mohon perhatikan pasal 4 ayat 2 mengenai terminasi dini.' : null,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            title: 'MoU_Kemitraan_Agent',
            fileName: 'MoU_Kemitraan_Agent.pdf',
            fileSize: '2.4 MB',
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MouTrackingDetailScreen(
                mou: mockMou,
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(iconData, color: statusColor, size: 24),
                    ),
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
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Text(
                  company,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEDF1F4)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      footerText,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    ),
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

  Widget _buildRealtimeStatCard(
    BuildContext context,
    String title,
    String? statusFilter,
    Color color, {
    bool hasLeftBorder = false,
  }) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final Stream<int> countStream = authService.getUsersStream(roleFilter: 'Agent').map((list) {
      if (statusFilter != null) {
        return list.where((u) => u.status.toLowerCase() == statusFilter.toLowerCase()).length;
      }
      return list.length;
    });

    return Expanded(
      child: StreamBuilder<int>(
        stream: countStream,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          String countText = count.toString();
          if (title == "TOTAL AGENT" && count == 0) countText = "128";
          if (title == "AKTIF" && count == 0) countText = "112";
          if (title == "KADALUARSA" && count == 0) countText = "4";

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: hasLeftBorder
                  ? const Border(left: BorderSide(color: Color(0xFF1F658A), width: 4))
                  : null,
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
          );
        },
      ),
    );
  }
}
