import 'package:flutter/material.dart';
import '../pages/navigation/bookmark.dart';
import '../pages/navigation/search.dart';
import 'package:shared_preferences/shared_preferences.dart';


class NavigationBar extends StatefulWidget {
  const NavigationBar({super.key});

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) async {
  setState(() {
    _selectedIndex = index;
  });

  // Navigate to the selected page
  switch (_selectedIndex) {
    case 0:
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SearchPage()));
      break;
    case 1:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home2()));
      break;
    case 2:
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String username = prefs.getString('username') ?? "default_username";
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => BookmarkPage(username: username)
        )
      );
      break;
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: const Color.fromARGB(255, 216, 215, 215),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildButton(0, Icons.search, '메뉴 검색'),
          _buildButton(1, Icons.format_list_bulleted, '리스트'),
          _buildButton(2, Icons.bookmark, '북마크'),
        ],
      ),
    );
  }

  Widget _buildButton(int index, IconData icon, String text) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _getIconColor(index)),
          Text(
            text,
            style: TextStyle(
              color: _getTextColor(index),
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconColor(int index) {
    return _selectedIndex == index ? Colors.deepPurple : const Color.fromARGB(255, 169, 119, 197);
  }

  Color _getTextColor(int index) {
    return _selectedIndex == index ? Colors.deepPurple : const Color.fromARGB(255, 169, 119, 197);
  }
}

// class NavigationBarWidget extends StatefulWidget {
//   const NavigationBarWidget({Key? key}) : super(key: key);
 
//   @override
//   State<NavigationBarWidget> createState() => _NavigationBarState();
// }
 
// class _NavigationBarState extends State<NavigationBarWidget> {
 
//   int _selectedIndex = 0;
  
//   final List<Widget> _widgetOptions = <Widget>[
//     const SearchPage(),
//     const Home2(),
//     const BookmarkPage(),
//   ];
 
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
 
//   // 메인 위젯
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: '메뉴 검색',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: '홈',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.inventory),
//             label: '북마크',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.orange,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
 
//   @override
//   void initState() {
//     //해당 클래스가 호출되었을떄
//     super.initState();
 
//   }
 
//   @override
//   void dispose() {
//     super.dispose();
//   }
    
// }