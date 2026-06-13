import 'dart:io' as io;
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
  final MouDocument? existingMou;

  const BrMouAgentUploadScreen({
    super.key,
    required this.agentName,
    required this.company,
    this.existingMou,
  });

  @override
  State<BrMouAgentUploadScreen> createState() => _BrMouAgentUploadScreenState();
}

class _BrMouAgentUploadScreenState extends State<BrMouAgentUploadScreen> {
  List<MouDocument> _tempUploadedFiles = [];
  List<PlatformFile> _pickedFiles = [];
  PlatformFile? _pickedLogoFile;
  bool _isLoading = false;

  late final TextEditingController _agentNameController;
  late final TextEditingController _principalNameController;
  late final TextEditingController _notesController;
  String _selectedPriority = "Normal";

  @override
  void initState() {
    super.initState();
    // Berkas kosong secara default agar aplikasi dinamis menggunakan berkas nyata
    _tempUploadedFiles = [];
    _agentNameController = TextEditingController(
      text: widget.existingMou?.idAgent ?? (widget.agentName == "Andi Wijaya" ? "" : widget.agentName)
    );
    _principalNameController = TextEditingController(
      text: widget.existingMou?.namaPrincipal ?? ""
    );
    _notesController = TextEditingController(
      text: widget.existingMou?.catatan ?? ""
    );
    _selectedPriority = widget.existingMou?.prioritas ?? "Normal";
  }

  @override
  void dispose() {
    _agentNameController.dispose();
    _principalNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    if (_isLoading) return;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            _pickedFiles.add(file);
            final mou = MouDocument(
              idMou: 'temp_${DateTime.now().millisecondsSinceEpoch}_${file.name}',
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

  Future<void> _pickLogoImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result != null) {
        setState(() {
          _pickedLogoFile = result.files.first;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memilih logo: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _deleteFile(int index) {
    if (_isLoading) return;
    setState(() {
      _tempUploadedFiles.removeAt(index);
      _pickedFiles.removeAt(index);
    });
  }

  Future<void> _submitForReview() async {
    if (_isLoading) return;
    final mouService = Provider.of<MouService>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (_tempUploadedFiles.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Wajib mengunggah minimal 1 berkas MoU"), backgroundColor: Colors.red),
      );
      return;
    }

    if (widget.existingMou == null && (_agentNameController.text.trim().isEmpty || _principalNameController.text.trim().isEmpty)) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Nama Agent dan Nama Principal wajib diisi"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? logoDownloadUrl;
      if (widget.existingMou == null && _pickedLogoFile != null) {
        logoDownloadUrl = await mouService.uploadMouFile(
          fileName: "logo_${DateTime.now().millisecondsSinceEpoch}_${_pickedLogoFile!.name}",
          jenisMou: 'Agent', // Store in same bucket
          fileBytes: _pickedLogoFile!.bytes,
          filePath: _pickedLogoFile!.path,
        );
      }

      // Simpan semua ke Storage dan Firestore secara berurutan
      for (int i = 0; i < _tempUploadedFiles.length; i++) {
        final file = _tempUploadedFiles[i];
        final pickedFile = _pickedFiles[i];

        final downloadUrl = await mouService.uploadMouFile(
          fileName: pickedFile.name,
          jenisMou: 'Agent',
          fileBytes: pickedFile.bytes,
          filePath: pickedFile.path,
        );

        if (downloadUrl == null) {
          throw Exception("Gagal mengunggah berkas ${pickedFile.name} ke Storage");
        }

        if (i == 0 && widget.existingMou != null) {
          // Edit/Re-upload mode untuk file pertama
          await mouService.deleteMouFile(widget.existingMou!.fileMou);

          final newStatus = widget.existingMou!.statusMou == 'Menunggu TTD' ? 'Aktif' : 'Draf';
          final updatedDoc = widget.existingMou!.copyWith(
            fileMou: downloadUrl,
            statusMou: newStatus,
            fileName: pickedFile.name,
            fileSize: file.fileSize,
            tanggalUpload: DateTime.now(), // update tanggal revisi
            catatanRevisi: newStatus == 'Draf' ? null : widget.existingMou!.catatanRevisi,
          );
          await mouService.updateMou(updatedDoc);
        } else {
          // Create mode
          final finalDoc = MouDocument(
            idMou: '',
            idAgent: _agentNameController.text.trim(),
            namaPrincipal: _principalNameController.text.trim(),
            jenisMou: 'Agent',
            fileMou: downloadUrl, 
            tanggalUpload: DateTime.now(),
            statusMou: 'Draf',
            catatan: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
            prioritas: _selectedPriority,
            createdAt: DateTime.now(),
            title: file.title,
            fileName: file.fileName,
            fileSize: file.fileSize,
            logoUrl: logoDownloadUrl,
          );
          await mouService.addMou(finalDoc);
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Gagal mengunggah berkas: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpdate = widget.existingMou != null;
    final String pageTitle = isUpdate
        ? (widget.existingMou!.statusMou == 'Menunggu TTD' ? "Unggah TTD Basah" : "Unggah Revisi")
        : "Unggah Dokumen MoU";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        titleText: pageTitle,
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

            if (isUpdate && widget.existingMou!.catatanRevisi != null && widget.existingMou!.statusMou != 'Menunggu TTD') ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.feedback_outlined, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Catatan Revisi Legal",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.existingMou!.catatanRevisi!,
                      style: TextStyle(color: Colors.red.shade900, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (!isUpdate) ...[
              const Text(
                "Informasi Mitra Agent",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _agentNameController,
                decoration: InputDecoration(
                  labelText: "Nama Agent",
                  hintText: "Contoh: Ray White Menteng",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF1F658A), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _principalNameController,
                decoration: InputDecoration(
                  labelText: "Nama Principal",
                  hintText: "Contoh: Budi Santoso",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF1F658A), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Prioritas Form Input
              const Text(
                "Prioritas",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: const [
                  DropdownMenuItem(value: "Normal", child: Text("Normal")),
                  DropdownMenuItem(value: "Urgent", child: Text("Urgent")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedPriority = val;
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Logo Picker
              const Text(
                "Logo Mitra (Opsional)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickLogoImage,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _pickedLogoFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _pickedLogoFile!.bytes != null 
                              ? Image.memory(_pickedLogoFile!.bytes!, fit: BoxFit.cover)
                              : Image.file(io.File(_pickedLogoFile!.path!), fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade400, size: 32),
                            const SizedBox(height: 8),
                            Text("Pilih Logo", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],

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

            // Catatan Text Area (Hanya jika bukan Menunggu TTD)
            if (!(isUpdate && widget.existingMou!.statusMou == 'Menunggu TTD')) ...[
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Tambahkan catatan...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12, height: 1.5),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F658A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(pageTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 60),
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