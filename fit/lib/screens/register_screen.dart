// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _username = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = false;
  final _api = ApiService();

  Future<void> _submit() async {
    setState(() => _loading = true);
    final ok = await _api.register({
      'username': _username.text,
      'first_name': _firstName.text,
      'last_name': _lastName.text,
      'email': _email.text,
      'password': _password.text,
      'phone_number': _phone.text,
    });
    setState(() => _loading = false);
    if (ok) Navigator.pop(context);
    else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Purple Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 60, bottom: 30),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Center(
              child: Text(
                'REGISTER',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: ListView(
                children: [
                  _buildField('Username', _username),
                  _buildField('First Name', _firstName),
                  _buildField('Last Name', _lastName),
                  _buildField('Phone', _phone, keyboard: TextInputType.phone),
                  _buildField('Email', _email, keyboard: TextInputType.emailAddress),
                  _buildField('Password', _password, obscure: true),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: _loading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Register', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {bool obscure = false, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}