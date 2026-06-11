import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BrMouAgentAddScreen extends StatefulWidget {
  const BrMouAgentAddScreen({super.key});

  @override
  State<BrMouAgentAddScreen> createState() => _BrMouAgentAddScreenState();
}

class _BrMouAgentAddScreenState extends State<BrMouAgentAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _lastActiveController = TextEditingController(text: "Aktif sejak ${DateTime.now().year}");

  String _selectedStatus = "AKTIF";

  Future<void> _saveAgent() async {
    if (_formKey.currentState!.validate()) {
      final agentData = {
        'name': _nameController.text.trim(),
        'company': _companyController.text.trim(),
        'status': _selectedStatus,
        'lastActive': _lastActiveController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('mou_agents').add(agentData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Agent berhasil ditambahkan"), backgroundColor: Colors.green),
      );

      Navigator.pop(context); // Kembali ke halaman list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Agent MOU")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Nama Agent"),
                  validator: (value) => value!.isEmpty ? "Nama tidak boleh kosong" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(labelText: "Perusahaan / Agency"),
                  validator: (value) => value!.isEmpty ? "Perusahaan tidak boleh kosong" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(labelText: "Status"),
                  items: const [
                    DropdownMenuItem(value: "AKTIF", child: Text("AKTIF")),
                    DropdownMenuItem(value: "PROSES", child: Text("PROSES")),
                    DropdownMenuItem(value: "KADALUARSA", child: Text("KADALUARSA")),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastActiveController,
                  decoration: const InputDecoration(labelText: "Keterangan Aktif"),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveAgent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Simpan Agent", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}