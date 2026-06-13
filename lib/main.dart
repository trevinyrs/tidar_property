import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tidar_property/widgets/auth_wrapper.dart';

import 'core/providers/user_provider.dart';
import 'core/providers/favorite_provider.dart';
import 'core/services/auth_service.dart';
import 'core/services/property_service.dart';
import 'core/services/mou_service.dart';
import 'core/services/project_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi Supabase gratis untuk File Storage
  await Supabase.initialize(
    url: 'https://ffjgpskqedslkcdsfvbb.supabase.co',
    publishableKey: 'sb_publishable_aHtRnQD4fpdtqGtZYbMAOw_1LcQSXMQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<PropertyService>(
          create: (_) => PropertyService(),
        ),
        Provider<MouService>(
          create: (_) => MouService(),
        ),
        Provider<ProjectService>(
          create: (_) => ProjectService(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider()..startUserListener(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Tidar Property',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1F658A),
            primary: const Color(0xFF1F658A),
            secondary: const Color(0xFF96D3FD),
          ),
          primaryColor: const Color(0xFF1F658A),
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