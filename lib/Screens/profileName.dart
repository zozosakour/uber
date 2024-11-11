import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class NameProfile extends StatefulWidget {
  @override
  _NameProfileState createState() => _NameProfileState();
}

class _NameProfileState extends State<NameProfile> {
  String? userName = "اسم غير متوفر";
  String? userImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.data()?['name'] ?? 'اسم غير متوفر';
          userImage = userDoc.data()?['image'];
        });
      } else {
        print("No user data found in Firestore.");
      }
    }
  }

  Future<void> _updateUserImage() async {
    final user = FirebaseAuth.instance.currentUser;
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && user != null) {
      try {
        // الحصول على المسار المحلي للصورة
        final imagePath = pickedFile.path;

        // رفع الصورة إلى Firebase Storage
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${user.email}.jpg');

        await ref.putFile(File(imagePath));
        final imageUrl = await ref.getDownloadURL();

        // تحديث الصورة في Firestore باستخدام رابط الصورة
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .update({'image': imageUrl});

        setState(() {
          userImage = imageUrl;
        });
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  Future<void> _updateUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (context) {
        String newName = "";
        return AlertDialog(
          title: Text('تغيير الاسم'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: "ادخل اسمك الجديد"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("إلغاء", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newName.isNotEmpty && user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.email)
                      .update({'name': newName});

                  setState(() {
                    userName = newName;
                  });

                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
              child: Text("حفظ"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الشخصي'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // استخدام Container لجعل الخلفية برتقالية
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange, // اللون البرتقالي للخلفية
                    shape: BoxShape.circle, // شكل دائري
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: userImage != null
                        ? NetworkImage(userImage!)
                        : AssetImage('assets/default_user_image.png') as ImageProvider,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  userName!,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _updateUserImage,
                      icon: Icon(Icons.camera_alt),
                      label: Text('تغيير الصورة'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.orange,
                        onPrimary: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _updateUserName,
                      icon: Icon(Icons.edit),
                      label: Text('تغيير الاسم'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.orange,
                        onPrimary: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
