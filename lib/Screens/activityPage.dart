import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرحلات'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('نشاطات').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('لا توجد نشاطات مسجلة.'));
          }

          final activities = snapshot.data!.docs;

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text('وقت الرحلة: ${activity['selectedTime']}'),
                subtitle: Text(
                  'نقطة البداية: ${activity['startPoint']['latitude']}, ${activity['startPoint']['longitude']}\n'
                      'نقطة النهاية: ${activity['destinationPoint']['latitude']}, ${activity['destinationPoint']['longitude']}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
