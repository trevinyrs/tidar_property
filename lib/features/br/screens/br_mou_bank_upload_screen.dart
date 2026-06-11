import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/mou_model.dart';
import 'br_mou_bank_detail_screen.dart';

class BrMouBankUploadScreen extends StatefulWidget {
  final String bankName;

  const BrMouBankUploadScreen({super.key, required this.bankName});

  @override
  State<BrMouBankUploadScreen> createState() => _BrMouBankUploadScreenState();
}

class _BrMouBankUploadScreenState extends State<BrMouBankUploadScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc'],
        allowMultiple: true,
      );

      if (result != null) {
        for (var file in result.files) {
          final mou = {
            'title': file.name.split('.').first,
            'fileName': file.name,
            'fileSize': file.size != null
                ? "${(file.size! / 1024 / 1024).toStringAsFixed(1)} MB"
                : "Unknown",
            'uploadedAt': DateTime.now().toString(),
            'type': 'Bank',
            'bankName': widget.bankName, // ← Simpan nama bank
            'status': 'Pending',
            'createdAt': FieldValue.serverTimestamp(),
            'uploadedBy': "BR User",
          };

          await _firestore.collection('mou_documents').add(mou);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Dokumen berhasil diunggah"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal upload: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFile(String docId) async {
    await _firestore.collection('mou_documents').doc(docId).delete();
  }

  Future<void> _ajukanUntukTinjauan() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrMouBankDetailScreen(bankName: widget.bankName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Unggah MoU - ${widget.bankName}"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Unggah MoU Bank ${widget.bankName}",
              style: const TextStyle(fontSize: 16),
            ),
            const Text(
              "Unggah Memorandum of Understanding (MoU) Anda dengan aman untuk tinjauan dokumen. Format yang didukung: PDF, DOCX.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF90CAF9)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Color(0xFF1565C0),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bank Mitra",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.bankName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickAndUploadFile,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Color(0xFF1E88E5),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Pilih file Anda di sini",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "atau tarik dan lepas dokumen",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Dokumen Terunggah",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('mou_documents')
                  .where('type', isEqualTo: 'Bank')
                  .where('status', isEqualTo: 'Pending')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada dokumen terunggah",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final files = snapshot.data!.docs
                    .map(
                      (doc) => MouDocument.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .toList();

                return Column(
                  children: files
                      .map((file) => _buildUploadedFile(file))
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _ajukanUntukTinjauan,
                icon: const Icon(Icons.send),
                label: const Text("Ajukan untuk Tinjauan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedFile(MouDocument file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${file.fileSize} • ${file.uploadedAt}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            file.status,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteFile(file.id),
          ),
        ],
      ),
    );
  }
}
