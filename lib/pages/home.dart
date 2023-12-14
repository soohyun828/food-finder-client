import 'package:flutter/material.dart';
import 'users/login.dart';
import 'users/signup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Position? userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      // 위치 권한 요청
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 거부된 권한 처리
        _showPermissionDialog(context);
        return;
      }

      // 위치 정보 가져오기 중 로딩 표시
      _showLoadingDialog(context);

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 위치 정보 가져오기 완료 시 로딩 다이얼로그 닫기
      Navigator.of(
        context, 
        rootNavigator: true
        ).pop();

      setState(() {
        userLocation = position;
      });

      _saveLocationToSharedPreferences(position);

    } catch (e) {
      print("Error fetching user location: $e");
    }
  }


  void _saveLocationToSharedPreferences(Position position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', position.latitude);
    prefs.setDouble('longitude', position.longitude);
  }

  void _showPermissionDialog(BuildContext context) {
    // 위치 권한이 거부된 경우 사용자에게 알림
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 권한이 거부되었습니다.'),
        content: const Text('앱을 사용하려면 위치 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    // 위치 정보를 가져오는 동안 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('위치 정보 가져오는 중'),
        content: Text('잠시만 기다려주세요...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: 
            MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: AssetImage('assets/launch_screen.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 20),  // 여백 조절
                    // const Text(
                    //   'Food Finder',
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 28,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                // 위치 정보가 있을 때만 버튼 활성화
                onPressed: userLocation != null
                    ? () 
                    {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                    );
                  }: null,
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                // 위치 정보가 있을 때만 버튼 활성화
                onPressed: userLocation != null
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Signup(),
                    ),
                  );
                }: null,
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}