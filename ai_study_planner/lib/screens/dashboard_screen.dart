import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/greeting_section.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_section.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Ensure signed-in user (anonymous fallback)
  Future<String> _ensureUid() async {
    final auth = FirebaseAuth.instance;
    User? u = auth.currentUser;
    if (u == null) {
      final cred = await auth.signInAnonymously();
      u = cred.user;
    }
    return u!.uid;
  }

  // users/{uid}/quizzes -> { score: num, createdAt: Timestamp }
  Stream<QuerySnapshot<Map<String, dynamic>>> _quizzesStream() async* {
    final uid = await _ensureUid();
    yield* FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // users/{uid}/tasks for today
  Stream<QuerySnapshot<Map<String, dynamic>>> _todayTasksStream() async* {
    final uid = await _ensureUid();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    yield* FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots();
  }

  // Upcoming: from today forward (no isCompleted filter on server → no composite index needed)
  Stream<QuerySnapshot<Map<String, dynamic>>> _upcomingRawStream() async* {
    final uid = await _ensureUid();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    yield* FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .orderBy('date') // single-field index only
        .limit(20)       // pull a reasonable window; we'll filter client-side
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // TOP
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const GreetingSection(),
                          const SizedBox(height: 20),

                          // ===== Average Quiz Score =====
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: _quizzesStream(),
                            builder: (context, snap) {
                              double avg = 0.0;
                              int taken = 0;

                              if (snap.hasData) {
                                final docs = snap.data!.docs;
                                taken = docs.length;
                                if (taken > 0) {
                                  final sum = docs.fold<double>(
                                    0.0,
                                    (acc, d) {
                                      final raw = d.data()['score'];
                                      final val =
                                          (raw is num) ? raw.toDouble() : 0.0;
                                      return acc + val;
                                    },
                                  );
                                  avg = sum / taken;
                                }
                              }

                              return StatCard(
                                title: "Your Average Score",
                                value: avg.toStringAsFixed(0),
                                subtitle: "Quizzes taken: $taken",
                                percentage: (avg.clamp(0, 100)) / 100.0,
                                percentageText: "${avg.toStringAsFixed(1)}%",
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // ===== Today's Tasks =====
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: _todayTasksStream(),
                            builder: (context, snap) {
                              int total = 0;
                              int completed = 0;

                              if (snap.hasData) {
                                final docs = snap.data!.docs;
                                total = docs.length;
                                completed = docs
                                    .where((d) =>
                                        (d.data()['isCompleted'] == true))
                                    .length;
                              }

                              final pct = total == 0 ? 0.0 : completed / total;

                              return StatCard(
                                title: "Today's Tasks",
                                value: "$completed",
                                subtitle: "out of $total",
                                percentage: pct,
                                percentageText:
                                    "${(pct * 100).toStringAsFixed(1)}%",
                              );
                            },
                          ),

                          const SizedBox(height: 30),

                          // ===== Upcoming (client-filtered incomplete) =====
                          _UpcomingSectionFB(stream: _upcomingRawStream),
                          const SizedBox(height: 30),
                        ],
                      ),

                      // BOTTOM
                      const QuickActionSection(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Firestore-backed Upcoming Section (filters incomplete on client)
class _UpcomingSectionFB extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> Function() stream;
  const _UpcomingSectionFB({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _UpcomingSkeleton();
        }
        if (snap.hasError) {
          return _errorBox('Failed to load upcoming: ${snap.error}');
        }

        final docs = (snap.data?.docs ?? [])
            .where((d) => d.data()['isCompleted'] != true)
            .toList();
        docs.sort((a, b) {
          final ta = a.data()['date'] as Timestamp?;
          final tb = b.data()['date'] as Timestamp?;
          final da = ta?.toDate() ?? DateTime(2100);
          final db = tb?.toDate() ?? DateTime(2100);
          return da.compareTo(db);
        });

        final items = docs.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upcoming",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              _infoBox("Nothing coming up. Enjoy the day!")
            else
              Column(
                children: items.map((d) {
                  final data = d.data();
                  final title = (data['title'] ?? '').toString();
                  final desc = (data['description'] ?? '').toString();
                  final ts = data['date'] as Timestamp?;
                  final dt = ts?.toDate();

                  final when = dt == null
                      ? ''
                      : "${_weekday(dt.weekday)}, ${dt.day}/${dt.month} • ${_hhmm(dt)}";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: _box(),
                    child: Row(
                      children: [
                        const Icon(Icons.event_note, color: Colors.deepPurple),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              if (desc.isNotEmpty)
                                Text(desc,
                                    style: TextStyle(
                                        color: Colors.grey.shade700)),
                              if (when.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    when,
                                    style: TextStyle(
                                        color: Colors.grey.shade600),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  static Widget _infoBox(String msg) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _box(),
        child: Text(msg),
      );

  static Widget _errorBox(String msg) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _box(),
        child: Text(msg, style: const TextStyle(color: Colors.red)),
      );

  static BoxDecoration _box() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      );

  static String _weekday(int w) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][(w + 6) % 7];

  static String _hhmm(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }
}

class _UpcomingSkeleton extends StatelessWidget {
  const _UpcomingSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget skel() => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upcoming",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        skel(),
        skel(),
        skel(),
      ],
    );
  }
}
