import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/mou_model.dart';

class ManagerMouDetailScreen extends StatelessWidget {
  final MouDocument mou;

  const ManagerMouDetailScreen({super.key, required this.mou});

  @override
  Widget build(BuildContext context) {
    final title = mou.title.isNotEmpty ? mou.title : mou.fileName;
    final category = mou.jenisMou;
    final dateString = DateFormat('dd MMM yyyy, HH:mm').format(mou.tanggalUpload);

    Color statusColor;
    IconData statusIcon;
    switch (mou.statusMou.toLowerCase()) {
      case 'revisi':
        statusColor = const Color(0xFFE67E22);
        statusIcon = Icons.edit_note_outlined;
        break;
      case 'disetujui':
      case 'aktif':
        statusColor = const Color(0xFF2ECC71);
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = const Color(0xFF1F658A);
        statusIcon = Icons.schedule_outlined;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          "Detail MoU",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Status Icon Section
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 60),
                  ),
                  const SizedBox(height: 20),
                  Text("Status MoU", style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(mou.statusMou, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: statusColor)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF1F4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(dateString, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Detail Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Informasi Dokumen", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 20),
                  _buildDetailRow("ID MoU", mou.idMou.length > 15 ? "${mou.idMou.substring(0, 15)}..." : mou.idMou),
                  const Divider(height: 32, color: Color(0xFFEDF1F4)),
                  _buildDetailRow("Nama Dokumen", title),
                  const Divider(height: 32, color: Color(0xFFEDF1F4)),
                  _buildDetailRow("Kategori", category.toUpperCase()),
                  
                  if (category.toLowerCase() == 'bank' && mou.idBank != null && mou.idBank!.isNotEmpty) ...[
                    const Divider(height: 32, color: Color(0xFFEDF1F4)),
                    _buildDetailRow("Instansi Bank", mou.idBank!),
                  ] else if (category.toLowerCase() == 'agent' && mou.idAgent != null && mou.idAgent!.isNotEmpty) ...[
                    const Divider(height: 32, color: Color(0xFFEDF1F4)),
                    _buildDetailRow("Instansi / Nama Agen", mou.idAgent!),
                  ] else if (mou.namaPrincipal != null && mou.namaPrincipal!.isNotEmpty) ...[
                    const Divider(height: 32, color: Color(0xFFEDF1F4)),
                    _buildDetailRow("Nama Principal", mou.namaPrincipal!),
                  ],

                  if (mou.prioritas != null && mou.prioritas!.isNotEmpty) ...[
                    const Divider(height: 32, color: Color(0xFFEDF1F4)),
                    _buildDetailRow("Urgensi", mou.prioritas!, isHighlight: mou.prioritas?.toLowerCase() == 'urgent'),
                  ],

                  if (mou.catatanRevisi != null && mou.catatanRevisi!.isNotEmpty) ...[
                    const Divider(height: 32, color: Color(0xFFEDF1F4)),
                    _buildDetailRow("Catatan Revisi", mou.catatanRevisi!),
                  ] else if (mou.catatan != null && mou.catatan!.isNotEmpty) ...[
                    const Divider(height: 32, color: Color(0xFFEDF1F4)),
                    _buildDetailRow("Catatan", mou.catatan!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey))),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: Text(
            value, 
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold, 
              color: isHighlight ? Colors.red : const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
