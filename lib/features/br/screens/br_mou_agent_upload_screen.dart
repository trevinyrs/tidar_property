import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'br_mou_agent_detail_screen.dart';
import '../../../core/services/mou_service.dart';
import '../../../models/mou_model.dart';
import '../../../widgets/custom_app_bar.dart';

class BrMouAgentUploadScreen extends StatefulWidget {
  final String agentName;
  final String company;

  const BrMouAgentUploadScreen({
    super.key,
    required this.agentName,
    required this.company,
  });

  @override
  State<BrMouAgentUploadScreen> createState() => _BrMouAgentUploadScreenState();
}

class _BrMouAgentUploadScreenState extends State<BrMouAgentUploadScreen> {
  List<MouDocument> _tempUploadedFiles = [];

  @override
  void initState() {
    super.initState();
    // Pre-populate with mockup files if empty
    _tempUploadedFiles = [
      MouDocument(
        idMou: 'mock_1',
        idAgent: widget.agentName,
        jenisMou: 'Agent',
        fileMou: 'MoU_Apartment_CentralPark.pdf',
        tanggalUpload: DateTime.now().subtract(const Duration(days: 1)),
        statusMou: 'Draf',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        title: 'MoU_Apartment_CentralPark',
        fileName: 'MoU_Apartment_CentralPark.pdf',
        fileSize: '2.4 MB',
      ),
      MouDocument(
        idMou: 'mock_2',
        idAgent: widget.agentName,
        jenisMou: 'Agent',
        fileMou: 'Draft_Sewa_Ruko_Sudirman.docx',
        tanggalUpload: DateTime.now().subtract(const Duration(days: 1)),
        statusMou: 'Draf',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        title: 'Draft_Sewa_Ruko_Sudirman',
        fileName: 'Draft_Sewa_Ruko_Sudirman.docx',
        fileSize: '840 KB',
      ),
      MouDocument(
        idMou: 'mock_3',
        idAgent: widget.agentName,
        jenisMou: 'Agent',
        fileMou: 'Lampiran_Denah_Unit.jpg',
        tanggalUpload: DateTime.now().subtract(const Duration(days: 2)),
        statusMou: 'Draf',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        title: 'Lampiran_Denah_Unit',
        fileName: 'Lampiran_Denah_Unit.jpg',
        fileSize: '4.1 MB',
      ),
    ];
  }

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'jpg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            final mou = MouDocument(
              idMou: 'temp_${DateTime.now().millisecondsSinceEpoch}',
              idAgent: widget.agentName,
              jenisMou: 'Agent',
              fileMou: file.name,
              tanggalUpload: DateTime.now(),
              statusMou: 'Draf',
              createdAt: DateTime.now(),
              title: file.name.split('.').first,
              fileName: file.name,
              fileSize: file.size != null
                  ? "${(file.size! / 1024 / 1024).toStringAsFixed(1)} MB"
                  : "Unknown",
            );
            _tempUploadedFiles.add(mou);
          }
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Berkas ditambahkan ke antrean"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal upload: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteFile(int index) {
    setState(() {
      _tempUploadedFiles.removeAt(index);
    });
  }

  Future<void> _submitForReview() async {
    final mouService = Provider.of<MouService>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (_tempUploadedFiles.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Wajib mengunggah minimal 1 berkas MoU"), backgroundColor: Colors.red),
      );
      return;
    }

    // Save all to Firestore
    for (var file in _tempUploadedFiles) {
      final finalDoc = MouDocument(
        idMou: '',
        idAgent: widget.agentName,
        jenisMou: 'Agent',
        fileMou: file.fileName,
        tanggalUpload: DateTime.now(),
        statusMou: 'Draf',
        createdAt: DateTime.now(),
        title: file.title,
        fileName: file.fileName,
        fileSize: file.fileSize,
      );
      await mouService.addMou(finalDoc);
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BrMouAgentDetailScreen(
          agentName: widget.agentName,
          company: widget.company,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomAppBar(
        titleText: "Unggah Dokumen MoU",
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Kelola berkas perjanjian dengan integritas struktural. Pastikan dokumen dalam format PDF atau DOCX untuk proses tinjauan yang optimal.",
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),

            const SizedBox(height: 24),

            // Big Upload Area (Mockup 2)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF96D3FD).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload,
                      size: 36,
                      color: Color(0xFF1F658A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Tarik & Lepas Dokumen",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pilih berkas dari perangkat Anda atau seret langsung ke area ini.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickAndUploadFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F658A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text("Pilih Berkas", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Security & Quick Info Cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_user_outlined, color: Color(0xFF1F658A), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Keamanan Data", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                            const SizedBox(height: 4),
                            Text("Semua dokumen dienkripsi secara end-to-end untuk menjaga privasi klien.", style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Color(0xFFF1F5F9)),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.speed_outlined, color: Color(0xFF1F658A), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Tinjauan Cepat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                            const SizedBox(height: 4),
                            Text("Proses validasi MoU biasanya selesai dalam kurun waktu 24 jam kerja.", style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Berkas Terunggah Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Berkas Terunggah",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF96D3FD).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${_tempUploadedFiles.length} Berkas",
                    style: const TextStyle(color: Color(0xFF1F658A), fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // File List
            Column(
              children: List.generate(_tempUploadedFiles.length, (index) {
                final file = _tempUploadedFiles[index];
                final isPdf = file.fileName.endsWith('.pdf');
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isPdf ? Colors.red.shade50 : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                          color: isPdf ? Colors.red.shade700 : Colors.blue.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${file.fileSize} • 12 OCT 2023",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 22),
                        onPressed: () => _deleteFile(index),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submitForReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F658A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: const Text("Submit for Review", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 12),
            Center(
              child: Text(
                "Dengan menekan tombol di atas, Anda menyetujui syarat dan ketentuan penggunaan platform kami.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10, height: 1.4),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}