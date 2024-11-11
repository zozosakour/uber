import 'package:flutter/material.dart';
import 'package:uber/Screens/ToWhere.dart';
import 'package:uber/Screens/TheHomePage.dart';
import 'package:uber/Screens/activityPage.dart';
import 'package:uber/Screens/profileName.dart';

class TheApp extends StatefulWidget {
  @override
  _TheAppState createState() => _TheAppState();
}

class _TheAppState extends State<TheApp> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // إضافة واجهة جديدة إلى قائمة الواجهات
  final List<Widget> _pages = [
    HomePage(),    // واجهة الإعدادات
    Activity(),         // واجهة الرحلات
    UserProfilePage(), // واجهة الملف الشخصي
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'المنزل',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'الرحلات',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
    );
  }
}

// واجهة الملف الشخصي
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TheHomePage();
  }
}

// واجهة الإعدادات
class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NameProfile();
  }
}
class Activity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ActivityPage();
  }
}
