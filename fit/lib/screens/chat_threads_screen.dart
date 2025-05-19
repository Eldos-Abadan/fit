// lib/screens/chat_threads_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class ChatThreadsScreen extends StatefulWidget {
  final int trainerId;
  const ChatThreadsScreen({Key? key, required this.trainerId}) : super(key: key);

  @override
  State<ChatThreadsScreen> createState() => _ChatThreadsScreenState();
}

class _ChatThreadsScreenState extends State<ChatThreadsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _threads = [];

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    // 1) Бүкіл жаттықтырушыға келген хабарламалар
    final rawMsgs = await ApiService().getMessages(widget.trainerId);
    // 2) Әр хабарламадағы 'user' өрісінен бірегей қолданушыларды шығару
    final Map<int, String> map = {};
    for (var m in rawMsgs) {
      final u = m['user'];
      int userId;
      String userName;

      if (u is int) {
        userId = u;
        userName = 'User $u';
      } else if (u is Map<String, dynamic>) {
        userId = u['id'] as int;
        userName = u['username'] as String? ?? 'User $userId';
      } else {
        continue;
      }

      map[userId] = userName;
    }

    setState(() {
      _threads = map.entries
          .map((e) => {'id': e.key, 'name': e.value})
          .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_threads.isEmpty) {
      return const Center(child: Text('No chat threads'));
    }
    return ListView.separated(
      itemCount: _threads.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final t = _threads[i];
        return ListTile(
          leading: CircleAvatar(child: Text(t['name'][0])),
          title: Text(t['name']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  trainerId: widget.trainerId,
                  trainerName: t['name'], // экранның жоғарғы тақырыбы
                ),
              ),
            );
          },
        );
      },
    );
  }
}
