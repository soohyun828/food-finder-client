import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'home.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  // 위치 권한 요청
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();

    // 위치 권한이 허용된 경우
    if (status.isGranted) {
      // 일정 시간 후에 메인 화면으로 이동
      Future.delayed(const Duration(seconds: 1), () {
        _navigateToHome();
      });
    } else {
      // 위치 권한이 거부된 경우
      _showLocationPermissionDialog();
    }
  }

  // 위치 권한 알림 창 표시
  Future<void> _showLocationPermissionDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('위치 권한 요청'),
          content: const Text('앱을 사용하기 위해서는 위치 권한이 필요합니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // 사용자가 동의한 경우
                Navigator.of(context).pop();
                _navigateToHome();
              },
              child: const Text('동의'),
            ),
            TextButton(
              onPressed: () {
                // 사용자가 거부한 경우
                Navigator.of(context).pop();
                _exitApp();
              },
              child: const Text('거부'),
            ),
          ],
        );
      },
    );
  }

  // Home 페이지로 이동
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  // 앱 종료
  void _exitApp() {
    // 여기서는 간단하게 앱 종료
    // 실제 앱에서는 더 적절한 종료 방식을 사용해야 할 수 있습니다.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지
            Image.asset(
              'assets/launch_screen.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            // 텍스트
            const Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'Food Finder',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
