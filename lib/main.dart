import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uber/Screens/login.dart';
import 'package:uber/Screens/Varification.dart'; // شاشة تأكيد البريد الإلكتروني
import 'package:uber/Screens/profileName.dart';
import 'package:uber/Screens/theApp.dart';
import 'Screens/ToWhere.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(Home());
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthChecker(), // التحقق من حالة المستخدم
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          // المستخدم مسجل دخوله
          User? user = snapshot.data;
          if (user != null && user.emailVerified) {
            // البريد الإلكتروني مؤكد
            return TheApp(); // توجيه إلى الشاشة المطلوبة بعد تسجيل الدخول والتأكيد
          } else {
            // البريد الإلكتروني غير مؤكد
            return VerificationScreen(); // توجيه المستخدم إلى شاشة تأكيد البريد الإلكتروني
          }
        } else {
          // المستخدم غير مسجل دخوله
          return LoginScreen(); // توجيه المستخدم إلى شاشة تسجيل الدخول
        }
      },
    );
  }
}
