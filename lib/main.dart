import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tidar_property/widgets/auth_wrapper.dart';

import 'core/providers/user_provider.dart';
import '../widgets/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Tambahkan ..startUserListener() agar realtime
        ChangeNotifierProvider(
          create: (_) => UserProvider()..startUserListener(),
        ),
      ],
      child: MaterialApp(
        title: 'Tidar Property',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF1E88E5),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}