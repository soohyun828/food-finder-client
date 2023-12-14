import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_navi/kakao_flutter_sdk_navi.dart';


import '../../widgets/navigation_bar.dart' as custom_navigation_bar;


// String serverURL = "http://127.0.0.1:5000"; // 그냥 컴에서 돌릴때
String serverURL = "http://10.0.2.2:5000"; // 가상 에뮬레이터
// String serverURL = "http://192.168.140.43:5000"; // 실제 기기


class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);


  @override
  _SearchPageState createState() => _SearchPageState();
}

class Restaurant {
  final int resnum;
  final String resname;
  final String address;
  final String imageURL;
  final String lat;
  final String lon;
  final double distance;
  bool bookmarked;

  Restaurant({
    required this.resnum,
    required this.resname,
    required this.address,
    required this.imageURL,
    required this.lat,
    required this.lon,
    required this.distance,
    required this.bookmarked,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      resnum: json['resnum'],
      resname: json['resname'],
      address: json['address'],
      imageURL: json['imageURL'],
      lat: json['lat'],
      lon: json['lon'],
      distance: json['distance'],
      bookmarked: json['bookmarked'],
    );
  }

  String formattedDistance() {
    if (distance >= 1000) {
      // 1000m 이상일 경우 km 단위로 표시
      double distanceInKm = distance / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      // 1000m 미만일 경우 m 단위로 표시
      return '${distance.round()} m';
    }
  }
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> searchResults = [];
  late Position userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDialog(context);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLocation = position;
      });
    } catch (e) {
      print("Error fetching user location: $e");
    }
  }


  // 북마크 토글 함수
  Future<void> toggleBookmark(int resnum) async {
    try {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String username = prefs.getString('username') ?? "default_username";

      final url = Uri.parse('$serverURL/bookmark/$username/$resnum');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // 북마크 토글 성공
        print('Bookmark toggled successfully');
      } else {
        // 북마크 토글 실패
        print('Failed to toggle bookmark');
      }
    } catch (e) {
      print("Error toggling bookmark: $e");
    }
  }


  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('위치 권한 필요'),
          content: const Text('이 앱을 사용하려면 위치 권한이 필요합니다. 설정으로 이동하여 권한을 활성화해주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Icon(
              Icons.search,
              color: Colors.black12,
            ),
            const SizedBox(
              width: 8,
            ),
            Flexible(
              flex: 1,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  hintText: '검색 키워드를 입력해주세요',
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            TextButton(
              onPressed: () {
                if (_searchController.text.isEmpty) {
                  _showSnackbar('검색어를 입력해주세요');
                } else {
                  _search(_searchController.text);
                }
              },
              child: const Text('검색'),
            ),
          ],
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: const custom_navigation_bar.NavigationBar(),
    );
  }

  Widget _buildBody() {
    if (searchResults.isEmpty) {
      return 
      const Center(
        child: 
        Text('검색 결과가 없습니다.'),
      );
    } else {
      return ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return buildRestaurantItem(searchResults[index]);
        },
      );
    }
  }


  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }


  Widget buildRestaurantItem(Restaurant restaurant) {
    return GestureDetector(
      onTap: () {
        openKakaoNavi(restaurant.lat, restaurant.lon);
      },
      child: Container(
        child: Column(
          children: [
            ListTile(
              leading: Image.network(
                restaurant.imageURL,
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ),
              title: Text(
                restaurant.resname,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontFamily: 'Source Sans Pro',
                  fontWeight: FontWeight.w700,
                  height: 0.07,
                ),
              ),
              subtitle: Text(
                restaurant.formattedDistance(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Source Sans Pro',
                  fontWeight: FontWeight.w400,
                  height: 0.08,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  restaurant.bookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: () {
                  toggleBookmark(restaurant.resnum);
                  setState(() {
                    restaurant.bookmarked = !restaurant.bookmarked;
                  });
                },
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.3,
            ),
          ],
        ),
      ),
    );
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

  Future<void> _search(String menu) async {

    try {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String username = prefs.getString('username') ?? "default_username"; // Replace with a default username
      double latitude = userLocation.latitude;
      double longitude = userLocation.longitude;

      final url = Uri.parse('$serverURL/home/search/$menu/$username/$latitude/$longitude');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          searchResults = responseData
          .map((json) => Restaurant.fromJson(json))
          .toList();
        });
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {
      print("Error fetching restaurants: $e");
      // Handle error fetching restaurants
    }
  }
}
