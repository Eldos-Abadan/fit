import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';
import 'trainer_details_screen.dart';

class TrainerListScreen extends StatefulWidget {
  const TrainerListScreen({Key? key}) : super(key: key);

  @override
  State<TrainerListScreen> createState() => _TrainerListScreenState();
}

class _TrainerListScreenState extends State<TrainerListScreen> {
  late Future<List<Map<String, dynamic>>> _futureTrainers;

  @override
  void initState() {
    super.initState();
    _futureTrainers = ApiService()
      .getTrainers()
      .then((list) => List<Map<String, dynamic>>.from(list))
      .catchError((e) {
        // Жүктеу қателігін консольге шығарамыз
        debugPrint('getTrainers error: $e');
        return <Map<String,dynamic>>[];
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainers'),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureTrainers,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error loading trainers: ${snap.error}'));
          }

          final trainers = snap.data ?? [];
          if (trainers.isEmpty) {
            return const Center(child: Text('No trainers found'));
          }

          return ListView.separated(
            itemCount: trainers.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final t = trainers[i];
              final id    = t['id']    as int;
              final name  = t['name']  as String;
              final email = t['email'] as String;

              return ListTile(
                leading: CircleAvatar(child: Text(name[0])),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(email),
                trailing: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChatScreen(
                        trainerId:   id,
                        trainerName: name,
                      )),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TrainerDetailsScreen(id: id)),
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
