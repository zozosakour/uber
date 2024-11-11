import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/Screens/ForgetPassword.dart';
import 'package:uber/Screens/ToWhere.dart';
import 'package:uber/Screens/Varification.dart';
import 'package:uber/Screens/signup.dart';
import 'package:uber/Screens/theApp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isHidden = true;

  void togglePasswordVisibility() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  // دالة لعرض مؤشر التحميل
  Future<void> _showLoadingIndicator() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.orange, // لون المؤشر البرتقالي
          ),
        );
      },
    );
  }

  // دالة لإخفاء مؤشر التحميل
  Future<void> _hideLoadingIndicator() async {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange, // اللون البرتقالي
        title: const Text('تسجيل الدخول'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.orange), // تغيير لون الأيقونة
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.orange), // تغيير لون الحدود عند التركيز
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: isHidden,
                  decoration: InputDecoration(
                    labelText: 'كلمة السر',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.orange), // تغيير لون الأيقونة
                    suffixIcon: IconButton(
                      onPressed: togglePasswordVisibility,
                      icon: Icon(
                        isHidden ? Icons.visibility : Icons.visibility_off,
                        color: Colors.orange, // تغيير لون الأيقونة
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.orange), // تغيير لون الحدود عند التركيز
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _showLoadingIndicator();
                    try {
                      final userCredential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      if (userCredential.user != null) {
                        if (userCredential.user!.emailVerified) {
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>TheApp()), (dynamic route) => false);
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => VerificationScreen()));
                        }
                      }
                    } catch (e) {
                      print(e);
                    } finally {
                      await _hideLoadingIndicator();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    primary: Colors.orange, // اللون البرتقالي
                  ),
                  child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ForgetP()));
                  },
                  child: Text(
                    'هل نسيت كلمة السر ؟',
                    style: TextStyle(color: Colors.orange), // تغيير لون النص
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => Signup()));
                  },
                  child: Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(color: Colors.orange), // تغيير لون النص
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
