import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/services/mou_service.dart';
import '../../../models/mou_model.dart';
import '../../../widgets/custom_app_bar.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import '../../../core/providers/user_provider.dart';
import 'manager_mou_list_screen.dart';
import 'manager_mou_detail_screen.dart';

class ManagerMouReportScreen extends StatelessWidget {
  const ManagerMouReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    const cardWhite = Colors.white;
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
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
      body: StreamBuilder<List<MouDocument>>(
        stream: Provider.of<MouService>(context, listen: false).getMousStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allMous = snapshot.data ?? [];
          final bankMous = allMous.where((m) => m.jenisMou.toLowerCase() == 'bank');
          final agentMous = allMous.where((m) => m.jenisMou.toLowerCase() == 'agent');

          // Count by status
          final activeCount = allMous.where((m) => m.statusMou.toLowerCase() == 'aktif').length;
          final processCount = allMous.where((m) => m.statusMou.toLowerCase() == 'draf' || m.statusMou.toLowerCase() == 'menunggu ttd').length;
          final revisionCount = allMous.where((m) => m.statusMou.toLowerCase() == 'revisi').length;
          final expiredCount = allMous.where((m) => m.statusMou.toLowerCase() == 'expired').length; // fallback
          
          final totalCount = allMous.length;
          final double activePercentage = totalCount > 0 ? (activeCount / totalCount) : 0.6;
          final double processPercentage = totalCount > 0 ? (processCount / totalCount) : 0.25;
          final double revisionPercentage = totalCount > 0 ? (revisionCount / totalCount) : 0.15;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER & RINGKASAN KEMITRAAN ───────────────────────
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Tracking & Kemitraan",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Ringkasan kerjasama strategis dengan lembaga perbankan & agen.",
                        style: TextStyle(fontSize: 13, color: Color(0xFF7B8D9A)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── ROW STATISTIK MOU AKTIF ───────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSimpleCard(
                          title: "BANK AKTIF",
                          value: bankMous.where((m) => m.statusMou.toLowerCase() == 'aktif').length.toString(),
                          subtitle: "${bankMous.length} Total Terdaftar",
                          icon: Icons.account_balance,
                          primaryColor: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSimpleCard(
                          title: "AGENT AKTIF",
                          value: agentMous.where((m) => m.statusMou.toLowerCase() == 'aktif').length.toString(),
                          subtitle: "${agentMous.length} Total Agen Mandiri",
                          icon: Icons.people_outline,
                          primaryColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── CARD DISTRIBUSI STATUS ────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Distribusi Status Dokumen",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 18),
                        
                        // Active Progress Bar
                        _buildStatusProgress("AKTIF", activePercentage, Colors.greenAccent),
                        const SizedBox(height: 12),
                        
                        // Process Progress Bar
                        _buildStatusProgress("PROSES", processPercentage, Colors.orangeAccent),
                        const SizedBox(height: 12),
                        
                        // Revision Progress Bar
                        _buildStatusProgress("REVISI", revisionPercentage, Colors.redAccent),
                        
                        const SizedBox(height: 16),
                        Divider(color: Colors.white.withOpacity(0.15)),
                        const SizedBox(height: 4),
                        Text(
                          "Total $totalCount MoU Terdaftar",
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── GRID STATUS BREAKDOWN ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _buildGridStatusItem("Aktif", activeCount.toString(), const Color(0xFF2ECC71)),
                      _buildGridStatusItem("Proses", processCount.toString(), const Color(0xFFE67E22)),
                      _buildGridStatusItem("Revisi", revisionCount.toString(), const Color(0xFFE74C3C)),
                      _buildGridStatusItem("Expired", expiredCount.toString(), Colors.grey),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── LIST MOU TERBARU ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        "MoU Terbaru",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          await _exportToExcel(context, allMous);
                        },
                        icon: const Icon(Icons.download_rounded, color: Color(0xFF1F658A), size: 22),
                        tooltip: "Export Laporan (.xlsx)",
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ManagerMouListScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text("Lihat Semua", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                allMous.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text("Belum ada dokumen MoU", style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: allMous.length > 5 ? 5 : allMous.length,
                        itemBuilder: (context, index) {
                          final mou = allMous[index];
                          final title = mou.title.isNotEmpty ? mou.title : mou.fileName;
                          final status = mou.statusMou;
                          
                          Color badgeColor = Colors.grey;
                          if (status.toLowerCase() == 'aktif') badgeColor = const Color(0xFF2ECC71);
                          if (status.toLowerCase() == 'revisi') badgeColor = const Color(0xFFE74C3C);
                          if (status.toLowerCase() == 'draf' || status.toLowerCase() == 'menunggu ttd') {
                            badgeColor = const Color(0xFFE67E22);
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ManagerMouDetailScreen(mou: mou)));
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardWhite,
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
                                    child: Icon(Icons.description_outlined, color: primaryColor, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "ID: ${mou.idMou.length > 10 ? mou.idMou.substring(0, 10) : mou.idMou} • ${DateFormat('d MMM yyyy').format(mou.tanggalUpload)}",
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          );
                        },
                      ),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
              Icon(icon, color: primaryColor, size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildStatusProgress(String label, double percent, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
            Text("${(percent * 100).round()}%", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.white.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildGridStatusItem(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Future<void> _exportToExcel(BuildContext context, List<MouDocument> mous) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Laporan MoU'];
      excel.setDefaultSheet('Laporan MoU');

      // Define Styles
      final headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.blue,
        fontColorHex: ExcelColor.white,
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      // Add Headers
      final headers = [
        "ID Dokumen", 
        "Nama Mitra", 
        "Tipe MoU (Agent/Bank)", 
        "Status Dokumen", 
        "Tanggal Unggah", 
        "Prioritas"
      ];
      
      for (var col = 0; col < headers.length; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.value = TextCellValue(headers[col]);
        cell.cellStyle = headerStyle;
      }

      // Add Rows
      for (var row = 0; row < mous.length; row++) {
        final mou = mous[row];
        final id = mou.idMou;
        final partner = mou.idAgent ?? mou.idBank ?? "Tanpa Nama";
        final type = mou.jenisMou.toUpperCase();
        final status = mou.statusMou;
        final date = DateFormat('yyyy-MM-dd').format(mou.tanggalUpload);
        final priority = mou.prioritas ?? 'Normal';

        final values = [id, partner, type, status, date, priority];

        for (var col = 0; col < values.length; col++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1));
          cell.value = TextCellValue(values[col]);

          // Styling specific cells (e.g. status)
          if (col == 3) {
            if (status.toLowerCase() == 'aktif' || status.toLowerCase() == 'disetujui') {
              cell.cellStyle = CellStyle(fontColorHex: ExcelColor.green, bold: true);
            } else if (status.toLowerCase() == 'revisi') {
              cell.cellStyle = CellStyle(fontColorHex: ExcelColor.red, bold: true);
            } else {
              cell.cellStyle = CellStyle(fontColorHex: ExcelColor.orange, bold: true);
            }
          }
        }
      }

      // Save to temp directory
      final fileBytes = excel.save();
      if (fileBytes == null) throw Exception("Gagal menghasilkan file Excel");

      final directory = await getTemporaryDirectory();
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final path = '${directory.path}/Laporan_MoU_$timestamp.xlsx';
      
      final File file = File(path);
      await file.writeAsBytes(fileBytes);

      // Share the file
      final XFile xFile = XFile(path);
      await Share.shareXFiles([xFile], text: 'Laporan MoU Timpro');
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal meng-export data: $e")),
        );
      }
    }
  }
}