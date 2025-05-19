// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // 1) Private named constructor
  ApiService._internal();

  // 2) Single static instance
  static final ApiService _instance = ApiService._internal();

  // 3) Factory returns the same instance every time
  factory ApiService() => _instance;

  // Base URL for your Django API
  static const _baseUrl = 'http://127.0.0.1:8000/api';

  // Secure storage for JWT
  final _storage = const FlutterSecureStorage();

  // Holds the current user ID once fetched
  int? _currentUserId;
  int get currentUserId {
    if (_currentUserId == null) {
      throw Exception('currentUserId әлі орнатылмаған!');
    }
    return _currentUserId!;
  }

  // Common headers for HTTP requests
  Map<String, String> _headers([String? token]) {
    final m = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      m['Authorization'] = 'Bearer $token';
    }
    return m;
  }

  /// Логин: жібереді username/password, сақтайды токен, жүктейді профиль
  Future<bool> login(String username, String password) async {
  final res = await http.post(
    Uri.parse('$_baseUrl/auth/login/'),
    headers: _headers(),
    body: jsonEncode({
      'username': username,
      'password': password,
    }),
  );

  if (res.statusCode == 200) {
    final body = jsonDecode(res.body);
    // токенді сақтаймыз
    await _storage.write(key: 'jwt', value: body['access']);
    // профильді жүктеп, сонда currentUserId орнатылады
    await getProfile();
    return true;
  }
  return false;
}

  /// Регистрация
  Future<bool> register(Map<String, String> data) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/register/'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    return res.statusCode == 201;
  }

  /// Логаут: өшіреді токенді
  Future<bool> logout() async {
    await _storage.delete(key: 'jwt');
    _currentUserId = null;
    return true;
  }

  /// Профиль: жүктейді және орнатады currentUserId
  Future<Map<String, dynamic>?> getProfile() async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) return null;
    final res = await http.get(
      Uri.parse('$_baseUrl/profile/'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      _currentUserId = (body['user']['id'] as num).toInt();
      return body;
    }
    return null;
  }

  /// Барлық жаттықтырушылар
  Future<List<dynamic>> getTrainers() async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.get(
      Uri.parse('$_baseUrl/trainers/'),
      headers: _headers(token),
    );
    return res.statusCode == 200 ? jsonDecode(res.body) : [];
  }

  /// Ұпай бойынша жаттықтырушының толық мәліметі
  Future<Map<String, dynamic>?> getTrainerDetail(int id) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.get(
      Uri.parse('$_baseUrl/trainers/$id/'),
      headers: _headers(token),
    );
    return res.statusCode == 200 ? jsonDecode(res.body) : null;
  }

  /// Чат хабарларын алу
  Future<List<dynamic>> getMessages(int trainerId) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.get(
      Uri.parse('$_baseUrl/trainers/$trainerId/chat/'),
      headers: _headers(token),
    );
    return res.statusCode == 200 ? jsonDecode(res.body) : [];
  }

  /// Чатқа хабар жіберу
  Future<bool> sendMessage(int trainerId, String content) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.post(
      Uri.parse('$_baseUrl/trainers/$trainerId/chat/'),
      headers: _headers(token),
      body: jsonEncode({'content': content}),
    );
    return res.statusCode == 201;
  }

  /// Барлық мақсаттарды алу
  Future<List<dynamic>> getGoals() async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.get(
      Uri.parse('$_baseUrl/profile/goals/'),
      headers: _headers(token),
    );
    return res.statusCode == 200 ? jsonDecode(res.body) : [];
  }

  /// Жаңа мақсат қосу
  Future<bool> addGoal(String text) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.post(
      Uri.parse('$_baseUrl/profile/goals/'),
      headers: _headers(token),
      body: jsonEncode({'text': text}),
    );
    return res.statusCode == 201;
  }

  /// Мақсатты жою
  Future<bool> deleteGoal(int id) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.delete(
      Uri.parse('$_baseUrl/profile/goals/$id/'),
      headers: _headers(token),
    );
    return res.statusCode == 204;
  }

    /// Тренерге келген барлық хаттарды жүктеп, sender бойынша бірегей тізім қайтарады
  Future<List<Map<String, dynamic>>> getChatThreads(int trainerId) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.get(
      Uri.parse('$_baseUrl/trainers/$trainerId/chat/'),
      headers: _headers(token),
    );
    if (res.statusCode != 200) return [];

    final List raw = jsonDecode(res.body);
    // топтаймыз — әр user_id бір рет шығады, бірақ соңғы контент пен уақыты сақталады
    final Map<int, Map<String, dynamic>> map = {};
    for (var m in raw) {
      final uid = m['user_id'] as int;
      // жаңадан шыққан болса жазады, болмаса overwrite соңғы месседжге
      map[uid] = {
        'user_id': uid,
        'user_name': m['user_name'],
        'last': m['content'],
        'timestamp': m['timestamp'],
      };
    }
    return map.values.toList();
  }

  Future<List<Map<String, dynamic>>> getWorkoutPlans() async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.get(
      Uri.parse('$_baseUrl/workouts/'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) {
      return List<Map<String,dynamic>>.from(jsonDecode(res.body));
    }
    return [];
  }

  Future<bool> addWorkoutPlan(String title, String details) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.post(
      Uri.parse('$_baseUrl/workouts/'),
      headers: _headers(token),
      body: jsonEncode({'title': title, 'details': details}),
    );
    if (res.statusCode != 201) {
      print('ADD PLAN FAILED: ${res.statusCode} ${res.body}');
      return false;
    }
    return true;
  }

  Future<bool> updateWorkoutPlan(int id, String title, String details) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.put(
      Uri.parse('$_baseUrl/workouts/$id/'),
      headers: _headers(token),
      body: jsonEncode({'title': title, 'details': details}),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteWorkoutPlan(int id) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.delete(
      Uri.parse('$_baseUrl/workouts/$id/'),
      headers: _headers(token),
    );
    return res.statusCode == 204;
  }


  Future<bool> uploadWorkoutVideoPlan({
  required String title,
  required File video,
}) async {
  final token = await _storage.read(key: 'jwt');
  final uri = Uri.parse('$_baseUrl/workouts/');
  final request = http.MultipartRequest('POST', uri)
    ..headers.addAll(_headers(token))
    ..fields['title'] = title
    ..files.add(await http.MultipartFile.fromPath('video', video.path));
  final streamed = await request.send();
  return streamed.statusCode == 201;
}
}


