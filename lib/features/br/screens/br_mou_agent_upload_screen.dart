import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tidar_property/features/br/screens/br_mou_agent_detail_screen.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> uploadedFiles = [];

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc'],
        allowMultiple: true,
      );

      if (result != null) {
        for (var file in result.files) {
          final mouData = {
            'title': file.name.split('.').first,
            'fileName': file.name,
            'fileSize': file.size != null ? "${(file.size! / 1024 / 1024).toStringAsFixed(1)} MB" : "Unknown",
            'uploadedAt': DateTime.now().toString(),
            'type': 'Agent',
            'agentName': widget.agentName,
            'company': widget.company,
            'status': 'Pending',
            'createdAt': FieldValue.serverTimestamp(),
            'uploadedBy': "BR User",
          };

          await _firestore.collection('mou_documents').add(mouData);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Dokumen berhasil diunggah"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Unggah Dokumen MoU"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            const Text(
              "Kelola berkas dengan integrasi struktural. Pastikan dokumen dalam format PDF atau DOCX untuk proses tinjauan yang optimal.",
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // Upload Area
            GestureDetector(
              onTap: _pickAndUploadFile,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.4), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload_outlined, size: 60, color: Color(0xFF1E88E5)),
                      const SizedBox(height: 12),
                      const Text("Tarik & Lepas Dokumen", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text("atau klik untuk memilih file", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Keterangan Data
            const ListTile(
              leading: Icon(Icons.security_outlined, color: Colors.blue),
              title: Text("Keamanan Data"),
              subtitle: Text("Semua dokumen dienkripsi secara end-to-end untuk menjaga privasi klien."),
            ),

            const SizedBox(height: 16),

            // Berkas Terunggah
            const Text("Berkas Terunggah", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('mou_documents')
                  .where('type', isEqualTo: 'Agent')
                  .where('agentName', isEqualTo: widget.agentName)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("Belum ada berkas terunggah", style: TextStyle(color: Colors.grey));
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                      title: Text(data['fileName'] ?? ''),
                      subtitle: Text("${data['fileSize']} • ${data['uploadedAt']}"),
                      trailing: const Text("1 Berkas", style: TextStyle(color: Colors.grey)),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 32),

            // Submit Button
                        // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate langsung ke halaman Detail / Tracking
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BrMouAgentDetailScreen(
                        agentName: widget.agentName,
                        company: widget.company,
                      ),
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ MoU berhasil diajukan untuk review"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Submit for Review",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}