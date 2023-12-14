import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_navi/kakao_flutter_sdk_navi.dart';

import '../../widgets/navigation_bar.dart' as custom_navigation_bar;


// String serverURL = "http://127.0.0.1:5000"; // 그냥 컴에서 돌릴때
// String serverURL = "http://10.0.2.2:5000"; // 가상 에뮬레이터
String serverURL = "http://192.168.35.96:5000"; // 실제 기기


class BookmarkPage extends StatefulWidget {
  final String username;

  BookmarkPage({required this.username});

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {

  List<dynamic> bookmarkedRestaurants = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchBookmarks();
  }


  Future<void> fetchBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? "default_username";

    final response = await http.get(Uri.parse('$serverURL/bookmark/$username'));

    if (response.statusCode == 200) {

      final jsonData = json.decode(response.body);

      if (jsonData['success'] != null && jsonData['success']) {
        setState(() {

          bookmarkedRestaurants = jsonData['result'];
          loading = false;

        });
      } else {
        // Handle the case where there are no bookmarks
        showErrorSnackbar('북마크가 없습니다.');
      }
    } else {
      // Handle errors
      showErrorSnackbar('북마크를 불러오는 도중 오류가 발생했습니다.');
    }
  }

  Future<void> deleteBookmark(int resnum) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? "default_username";

    
    try {
      final response = await http.post(Uri.parse('$serverURL/bookmark/$username/$resnum'));

      if (response.statusCode == 200) {

        final jsonData = json.decode(response.body);

        if (jsonData['success']) {
          // Remove the deleted bookmark from the list
          setState(() {
            bookmarkedRestaurants.removeWhere(
              (restaurant) => restaurant['resnum'] == resnum
              );
            loading = false;
          });
        } else {
          // Handle the case where bookmark deletion failed
          showErrorSnackbar('북마크 삭제에 실패했습니다.');
        }
      } else {
        // Handle errors
        showErrorSnackbar('북마크를 삭제하는 도중 오류가 발생했습니다.');
      }
    } catch (error) {
      // Exception handling (e.g., network issues)
      showErrorSnackbar('북마크를 삭제하는 도중 예외가 발생했습니다.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('북마크'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : bookmarkedRestaurants.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border, 
                        size: 48,
                        color: Colors.grey,
                        ),
                      SizedBox(height: 16),
                      Text(
                        '북마크된 음식점이 없습니다.', 
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          )
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: bookmarkedRestaurants.length * 2,
                  itemBuilder: (context, index) {
                    var restaurantIndex = index ~/ 2;
                    if (index.isEven) {
                      // index가 짝수인 경우 (아이템을 추가해야 하는 경우)
                      var restaurant = bookmarkedRestaurants[restaurantIndex];
                      return GestureDetector(
                        onTap: () {
                          openKakaoNavi(restaurant['lat'], restaurant['lon']);
                        },
                        child: ListTile(
                          leading: Image.network(
                            restaurant['imageURL'],
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            ),
                          title: Text(
                            restaurant['resname'],
                            ),
                          subtitle: Text(
                            _getCategoryText(restaurant['category']),
                            ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete
                              ),
                            onPressed: () {
                              // Delete the bookmark when the delete icon is pressed
                              deleteBookmark(restaurant['resnum']);
                            },
                          ),
                        ),
                      );
                    } else {
                      // index가 홀수인 경우 (구분선을 추가해야 하는 경우)
                      return const Divider(
                        color: Colors.grey,
                        thickness: 0.3,
                      );
                    }
                  },
                ),
                bottomNavigationBar: const custom_navigation_bar.NavigationBar(),
    );
  }


  String _getCategoryText(String category) {
    switch (category) {
      case 'korean':
        return '한식';
      case 'japanese':
        return '일식';
      case 'chinese':
        return '중식';
      case 'american':
        return '양식';
      case 'fastfood':
        return '패스트푸드';
        case 'italian':
        return '이탈리안';
        case 'mexican':
        return '멕시칸';
      default:
        return category; // 기본적으로는 원래의 카테고리 문자열을 반환
    }
  }


  void openKakaoNavi(String latitude, String longitude) async {
    
    double parsedLat = double.parse(latitude);
    double parsedLon = double.parse(longitude);
    
    bool result = await NaviApi.instance.isKakaoNaviInstalled();
    if (result) {
      print('카카오내비 앱으로 길안내 가능 : $parsedLat, $parsedLon');

      await NaviApi.instance.navigate(
        destination: Location(name: '음식점', x: '$parsedLon', y: '$parsedLat'),
        option: NaviOption(coordType: CoordType.wgs84),
      );
    } else {
      print('카카오내비 미설치');
      // 카카오내비 설치 페이지로 이동
      launchBrowserTab(Uri.parse(NaviApi.webNaviInstall));
    }
  }


  Future<void> showErrorSnackbar(String errorMessage) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
      ),
    );
  }
}