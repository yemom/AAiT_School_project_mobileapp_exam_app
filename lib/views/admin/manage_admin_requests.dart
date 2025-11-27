import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:another_exam_app/service/auth.dart' as app_auth;
import 'package:another_exam_app/theme/theme.dart';

class ManageAdminRequestsScreen extends StatelessWidget {
  const ManageAdminRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = app_auth.AuthService();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('adminRequests')
                .where('status', isEqualTo: 'pending')
                .orderBy('requestedAt', descending: true)
                .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('There is no requests'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No pending requests'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>? ?? {};
              final userId = d['userId'] as String? ?? docs[i].id;
              final status = d['status'] as String? ?? 'pending';

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get(),
                builder: (context, userSnap) {
                  if (userSnap.connectionState == ConnectionState.waiting) {
                    return const Card(
                      child: ListTile(
                        title: Text('Loading user...'),
                        subtitle: LinearProgressIndicator(),
                      ),
                    );
                  }

                  final userData = userSnap.data?.data();
                  final name = userData?['name'] as String? ?? 'Unknown user';
                  final email = userData?['email'] as String? ?? 'N/A';

                  return Card(
                    child: ListTile(
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text(email), Text('Status: $status')],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (status == 'pending')
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: AppTheme.successColor,
                              ),
                              onPressed: () async {
                                final msg = await service.approveAdminRequest(
                                  userId: userId,
                                  approvedBy: 'super-admin-uid',
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(msg ?? 'Approved')),
                                );
                              },
                            ),
                          if (status == 'pending')
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppTheme.errorColor,
                              ),
                              onPressed: () async {
                                final msg = await service.rejectAdminRequest(
                                  userId: userId,
                                  approvedBy: 'super-admin-uid',
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(msg ?? 'Rejected')),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
