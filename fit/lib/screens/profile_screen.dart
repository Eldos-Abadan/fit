// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  final _ctrl = TextEditingController();
  Map<String, dynamic>? _profile;
  List<dynamic> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadGoals();
  }

  Future<void> _loadProfile() async {
    _profile = await _api.getProfile();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadGoals() async {
    _goals = await _api.getGoals();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _addGoal() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final ok = await _api.addGoal(text);
    if (ok) {
      _ctrl.clear();
      _loadGoals();
    }
  }

  Future<void> _deleteGoal(int id) async {
    final ok = await _api.deleteGoal(id);
    if (ok) _loadGoals();
  }

  Future<void> _logout() async {
    await _api.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _profile == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${_profile!['user']['email']}'),
                  const SizedBox(height: 8),
                  Text('Phone: ${_profile!['phone']}'),
                  const SizedBox(height: 8),
                  Text('Joined: ${_profile!['joined']}'),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter your goal',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _addGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    ),
                    child: const Text('Add Goal'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _goals.length,
                      itemBuilder: (_, i) {
                        final g = _goals[i];
                        return ListTile(
                          leading: const Icon(Icons.check_circle, color: Colors.purple),
                          title: Text(g['text']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () => _deleteGoal(g['id']),
                          ),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Logout', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
