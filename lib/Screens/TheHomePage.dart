import 'package:flutter/material.dart';
import 'package:uber/Screens/ToWhere.dart';

class TheHomePage extends StatefulWidget {
  const TheHomePage({super.key});

  @override
  State<TheHomePage> createState() => _TheHomePageState();
}

class _TheHomePageState extends State<TheHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الصفحة الرئيسية',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // إضافة خلفية متدرجة اللون
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.deepOrangeAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center( // مركز العناصر في وسط الشاشة
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // جعل العناصر في منتصف العمود
              children: [
                // إضافة شعار أو صورة في الأعلى
                Icon(
                  Icons.location_on,
                  size: 100,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 20),
                const Text(
                  'مرحباً بك في تطبيق واصل كاب',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'انطلق الآن واكتشف وجهتك القادمة',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // زر "إلى أين؟" محسن
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ToWhere()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // لون الخلفية الأبيض للزر
                    onPrimary: Colors.orange, // لون النص البرتقالي
                    shadowColor: Colors.black38, // ظل للزر
                    elevation: 10, // ارتفاع الظل
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'إلى أين؟',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
