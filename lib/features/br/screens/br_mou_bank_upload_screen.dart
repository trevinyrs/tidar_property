import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../models/mou_model.dart';
import 'br_mou_bank_detail_screen.dart';
import '../../../core/services/mou_service.dart';
import '../../../widgets/custom_app_bar.dart';

class BrMouBankUploadScreen extends StatefulWidget {
  final String bankName;
  final MouDocument? existingMou;

  const BrMouBankUploadScreen({
    super.key, 
    required this.bankName,
    this.existingMou,
  });

  @override
  State<BrMouBankUploadScreen> createState() => _BrMouBankUploadScreenState();
}

class _BrMouBankUploadScreenState extends State<BrMouBankUploadScreen> {
  final _bankNameController = TextEditingController();
  String _selectedPriority = "Normal";
  final _notesController = TextEditingController();
  List<MouDocument> _tempUploadedFiles = [];
  List<PlatformFile> _pickedFiles = [];
  PlatformFile? _pickedLogoFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bankNameController.text = widget.bankName;
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    if (_isLoading) return;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            _pickedFiles.add(file);
            final mou = MouDocument(
              idMou: 'temp_${DateTime.now().millisecondsSinceEpoch}_${file.name}',
              idBank: _bankNameController.text,
              jenisMou: 'Bank',
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
            content: Text("✅ Dokumen ditambahkan ke antrean"),
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

  Future<void> _deleteFile(int index) async {
    if (_isLoading) return;
    setState(() {
      _tempUploadedFiles.removeAt(index);
      _pickedFiles.removeAt(index);
    });
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

  Future<void> _ajukanUntukTinjauan() async {
    if (_isLoading) return;
    final mouService = Provider.of<MouService>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final bankName = _bankNameController.text.trim();

    if (bankName.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Nama Bank wajib diisi"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_tempUploadedFiles.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Wajib mengunggah minimal 1 dokumen MoU"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? logoDownloadUrl;
      if (widget.existingMou == null && _pickedLogoFile != null) {
        logoDownloadUrl = await mouService.uploadMouFile(
          fileName: "logo_${DateTime.now().millisecondsSinceEpoch}_${_pickedLogoFile!.name}",
          jenisMou: 'Bank',
          fileBytes: _pickedLogoFile!.bytes,
          filePath: _pickedLogoFile!.path,
        );
      }

      // Simpan semua file ke Storage dan Firestore secara berurutan
      for (int i = 0; i < _tempUploadedFiles.length; i++) {
        final file = _tempUploadedFiles[i];
        final pickedFile = _pickedFiles[i];

        final downloadUrl = await mouService.uploadMouFile(
          fileName: pickedFile.name,
          jenisMou: 'Bank',
          fileBytes: pickedFile.bytes,
          filePath: pickedFile.path,
        );

        if (downloadUrl == null) {
          throw Exception("Gagal mengunggah berkas ${pickedFile.name} ke Storage");
        }

        MouDocument docToPass;

        if (i == 0 && widget.existingMou != null) {
          await mouService.deleteMouFile(widget.existingMou!.fileMou);

          final newStatus = widget.existingMou!.statusMou == 'Menunggu TTD' ? 'Aktif' : 'Draf';
          docToPass = widget.existingMou!.copyWith(
            fileMou: downloadUrl,
            statusMou: newStatus,
            fileName: pickedFile.name,
            fileSize: file.fileSize,
            tanggalUpload: DateTime.now(),
            catatanRevisi: newStatus == 'Draf' ? null : widget.existingMou!.catatanRevisi,
          );
          await mouService.updateMou(docToPass);
        } else {
          final finalDoc = MouDocument(
            idMou: '',
            idBank: bankName,
            jenisMou: 'Bank',
            fileMou: downloadUrl,
            tanggalUpload: DateTime.now(),
            statusMou: 'Draf',
            catatan: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
            createdAt: DateTime.now(),
            title: file.title,
            fileName: file.fileName,
            fileSize: file.fileSize,
            logoUrl: logoDownloadUrl,
          );
          final newId = await mouService.addMou(finalDoc);
          docToPass = finalDoc.copyWith(idMou: newId ?? '');
        }

        if (i == _tempUploadedFiles.length - 1 && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BrMouBankDetailScreen(mou: docToPass),
            ),
          );
        }
      }
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
        : "Unggah Dokumen";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        titleText: pageTitle,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Unggah Memorandum of Understanding (MoU) Anda dengan aman untuk tinjauan dokumen. Format yang didukung: PDF, DOCX.",
              style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 13),
            ),
            const SizedBox(height: 24),

            if (isUpdate && widget.existingMou!.catatanRevisi != null) ...[
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

            // Hanya tampilkan form bank dan prioritas jika bukan upload TTD Basah
            if (!(isUpdate && widget.existingMou!.statusMou == 'Menunggu TTD')) ...[
              // Nama Bank Form Input
              const Text(
                "Nama Bank",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bankNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFEDF1F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  hintText: "Masukkan nama bank...",
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
                initialValue: _selectedPriority,
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
                  fillColor: const Color(0xFFEDF1F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Logo Picker
              const Text(
                "Logo Mitra (Opsional)",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickLogoImage,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF1F4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: _pickedLogoFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: _pickedLogoFile!.bytes != null 
                              ? Image.memory(_pickedLogoFile!.bytes!, fit: BoxFit.cover)
                              : Image.file(io.File(_pickedLogoFile!.path!), fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade500, size: 32),
                            const SizedBox(height: 8),
                            Text("Pilih Logo", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],

            // Area Picker File
            GestureDetector(
              onTap: _pickAndUploadFile,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF96D3FD).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_upload,
                          size: 32,
                          color: Color(0xFF1F658A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Pilih file Anda di sini",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "atau tarik dan lepas dokumen MoU Anda",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dokumen Terunggah",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  "${_tempUploadedFiles.length} FILE",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List File Terunggah
            _tempUploadedFiles.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Belum ada file dipilih", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                : Column(
                    children: List.generate(_tempUploadedFiles.length, (index) {
                      final file = _tempUploadedFiles[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.picture_as_pdf, color: Colors.red.shade700, size: 24),
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
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${file.fileSize} • Diunggah baru saja",
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.grey, size: 20),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => _deleteFile(index),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

            const SizedBox(height: 16),

            // Info Banner Pengiriman Aman
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF1F4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: Color(0xFF1F658A), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Pengiriman Aman\nDokumen Anda dienkripsi dan hanya dapat diakses oleh personel hukum yang berwenang.",
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Catatan Text Area (Hanya jika bukan Menunggu TTD)
            if (!(isUpdate && widget.existingMou!.statusMou == 'Menunggu TTD')) ...[
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Tambahkan catatan...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12, height: 1.5),
                  filled: true,
                  fillColor: const Color(0xFFEDF1F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Ajukan Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _ajukanUntukTinjauan,
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
          ],
        ),
      ),
    );
  }
}
