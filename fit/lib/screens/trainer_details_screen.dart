// lib/screens/trainer_details_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class TrainerDetailsScreen extends StatefulWidget {
  final int id;
  const TrainerDetailsScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<TrainerDetailsScreen> createState() => _TrainerDetailsScreenState();
}

class _TrainerDetailsScreenState extends State<TrainerDetailsScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _trainer;

  @override
  void initState() {
    super.initState();
    _loadTrainer();
  }

  Future<void> _loadTrainer() async {
    final data = await _api.getTrainerDetail(widget.id);
    if (!mounted) return;
    setState(() => _trainer = data);
  }

  @override
  Widget build(BuildContext context) {
    if (_trainer == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final t = _trainer!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 16),
            decoration: const BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Text(
                  t['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(t['image_url']),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Email: ${t['email']}'),
                  const SizedBox(height: 8),
                  Text('Phone: ${t['contact_number']}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Working Days:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text((t['available_days'] as List<dynamic>).join(', ')),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              trainerId: widget.id,
                              trainerName: t['name'],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Chat with Trainer',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
