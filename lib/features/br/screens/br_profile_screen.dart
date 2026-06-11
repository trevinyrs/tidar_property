import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../models/user_model.dart';

class BrProfileScreen extends StatelessWidget {
  const BrProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil BR"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Avatar
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.person, size: 70, color: Colors.blue),
            ),

            const SizedBox(height: 16),
            Text(
              user?.name ?? "Nama BR",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? "",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Chip(
              label: const Text("Business Relation"),
              backgroundColor: Colors.orange[50],
              labelStyle: const TextStyle(color: Colors.orange),
            ),

            const SizedBox(height: 40),

            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Edit Profil"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {},
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Riwayat Approval"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {},
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Pengaturan"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {},
            ),
            const Divider(),

            const Spacer(),

            // ================== TOMBOL LOGOUT ==================
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Keluar Akun",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Keluar?"),
                    content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Keluar", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await userProvider.logout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}