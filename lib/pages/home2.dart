import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'category/korean.dart';
import 'category/american.dart';
import 'category/chinese.dart';
import 'category/japanese.dart';
import 'category/italian.dart';
import 'category/fastfood.dart';
import 'category/mexican.dart';



class DropDownItemModel {
  String category;
  DropDownItemModel(this.category);
}


class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  Home2State createState() => Home2State();
}


class Home2State extends State<Home2> {
  final List<DropDownItemModel> category = [
    DropDownItemModel('한식'),
    DropDownItemModel('양식'),
    DropDownItemModel('일식'),
    DropDownItemModel('중식'),
    DropDownItemModel('패스트푸드'),
    DropDownItemModel('이탈리안'),
    DropDownItemModel('멕시칸'),
  ];

  DropDownItemModel? selectedCategory;
  late Position userLocation;

  @override
  void initState() {
    super.initState();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/launch_screen.png',
                    fit: BoxFit.contain,
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20),  // 아래 여백 조절
                      // child: Text(
                      //   'Food Finder',
                      //   style: TextStyle(
                      //     fontSize: 50,
                      //     color: Colors.black,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '오늘은',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 20),
                DropdownButton<DropDownItemModel>(
                  value: selectedCategory ?? category[0],
                  onChanged: (DropDownItemModel? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  items: category.map((category) {
                    return DropdownMenuItem<DropDownItemModel>(
                      value: category,
                      child: Text(category.category),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedCategory != null) {
                  navigateToCategoryPage(context, selectedCategory!);
                }
              },
              child: const Text(
                '음식점 찾기',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToCategoryPage(BuildContext context, DropDownItemModel selectedCategory) {
    // 각 카테고리에 따른 페이지로 이동
    switch (selectedCategory.category) {
      case '한식':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KoreanPage()),
        );
        break;

      case '양식':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AmericanPage()),
        );
        break;

      case '일식':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JapanesePage()),
        );
        break;

      case '중식':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChinesePage()),
        );
        break;

      case '패스트푸드':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FastfoodPage()),
        );
        break;

      case '이탈리안':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ItalianPage()),
        );
        break;

      case '멕시칸':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MexicanPage()),
        );
        break;

      default:
        // 선택된 카테고리에 대한 특별한 동작이 없을 경우, 예외처리 또는 기본 동작 추가
        print('선택된 카테고리에 대한 동작이 정의되지 않았습니다.');
    }
  }

  // Future<void> _saveUserLocation(double latitude, double longitude) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setDouble('latitude', latitude);
  //   prefs.setDouble('longitude', longitude);
  //   print('latitude : ${latitude}');
  //   print('longitude : ${longitude}');
  // }
}
