import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';
import 'admin_page.dart';
import 'reception_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lcxeftiwuqdhcqrtipao.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxjeGVmdGl3dXFkaGNxcnRpcGFvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwNzY4NTUsImV4cCI6MjA5MzY1Mjg1NX0.khsMZR0hwKhx_cR42zUkcTQ_hLkJqtnaiEMFQvNWpCo',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final supabase = Supabase.instance.client;

  String? role;
  bool loadingRole = false;

  @override
  void initState() {
    super.initState();

    // listen auth changes
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;

      if (session == null) {
        setState(() {
          role = null;
        });
      } else {
        fetchRole(session.user.id);
      }
    });

    // initial session check
    final session = supabase.auth.currentSession;
    if (session != null) {
      fetchRole(session.user.id);
    }
  }

  Future<void> fetchRole(String userId) async {
    if (loadingRole) return;

    setState(() {
      loadingRole = true;
    });

    try {
      final data = await supabase
          .from('users_profile')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      setState(() {
        role = data?['role'];
      });
    } catch (e) {
      setState(() {
        role = null;
      });
    }

    setState(() {
      loadingRole = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = supabase.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Builder(
        builder: (context) {
          // 🔴 NOT LOGGED IN
          if (session == null) {
            return const LoginPage();
          }

          // ⏳ LOADING ROLE
          if (loadingRole || role == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 🔵 ROLE ROUTING
          if (role == 'admin') {
            return const AdminPage();
          }

          return const ReceptionDashboard();
        },
      ),
    );
  }
}