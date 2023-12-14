import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'signup.dart';
import 'loginSuccess.dart';


// String serverURL = "http://127.0.0.1:5000"; // 그냥 컴에서 돌릴때
// String serverURL = "http://10.0.2.2:5000"; // 가상 에뮬레이터
String serverURL = "http://192.168.35.96:5000"; // 실제 기기


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  Future<void> loginUser(String id, String pw) async {
    
    final url = Uri.parse('$serverURL/home/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': id,
        'password': pw,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        // 로그인 성공
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginSuccess(username: data['username']),
          ),
        );
      } else {
        // 로그인 실패
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${data['message']}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      // 서버 오류
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('서버 오류: ${response.statusCode}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                filled: true,
                labelText: '사용자 이름',
                icon:Icon(Icons.person),
                ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pwController,
              decoration: const InputDecoration(
                filled: true,
                labelText: '비밀번호',
                icon:Icon(Icons.lock),
                ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                loginUser(_idController.text, _pwController.text);
              },
              child: const Text(
                '로그인',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Text("아직 계정이 없으신가요?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Signup(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color.fromARGB(255, 132, 29, 201),
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}
