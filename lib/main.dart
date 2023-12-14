import 'package:flutter/material.dart';
import 'pages/splash.dart';
import 'package:kakao_flutter_sdk_navi/kakao_flutter_sdk_navi.dart';

void main() {
  
  KakaoSdk.init(
    nativeAppKey: '28c36bab1c1905e32c2fe98cbce37046', 
    javaScriptAppKey: 'f99e6f90f3e4f381fc8438cfa901d5d7'
    );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}