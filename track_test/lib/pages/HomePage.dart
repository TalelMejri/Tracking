import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:track_test/model/MenuModel.dart';
import 'package:track_test/pages/AddBike.dart';
import 'package:track_test/pages/Auth/LoginUser.dart';
import 'package:track_test/pages/ListBikes.dart';
import 'package:track_test/services/AuthServices.dart';
import 'package:track_test/services/BikeServices.dart';
import 'package:track_test/widgets/buildDashboardCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectIndex = 0;

  final BikeSrvice _bikeSrvice = BikeSrvice();
  MenuModel menu = new MenuModel(bikesReserved: 0, bikesNotReserved: 0);
  var loading = true;
  String name = "";
  late AuthService _authService = AuthService();
  @override
  void initState() {
    super.initState();
    getMenu();
    initializeData();
  }

  Future<void> initializeData() async {
    await _authService.getUserFromStorage();
    setState(() {
      name = _authService.isAuth ? _authService.user.Nom : "Guest";
    });
  }

  Future<void> getMenu() async {
    MenuModel bikes_menu = await _bikeSrvice.getMenuBikes();
    setState(() {
      menu = bikes_menu;
      loading = false;
    });
    print(menu);
  }

  void changeSelectedIndex(int index) {
    setState(() {
      _selectIndex = index;
    });
    getMenu();
  }

  @override
  void dispose() {
    super.dispose();
    getMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BikeGo'),
        backgroundColor: const Color(0xFF50586C),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginUser(message: '')),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFDCE2F0),
      bottomNavigationBar: CurvedNavigationBar(
        color: const Color(0xFF50586C),
        buttonBackgroundColor: const Color(0xFF50586C),
        backgroundColor: const Color(0xFFDCE2F0),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 500),
        onTap: changeSelectedIndex,
        index: _selectIndex,
        items: const [
          Icon(Icons.dashboard, color: Colors.white, size: 30),
          Icon(Icons.pedal_bike_sharp, color: Colors.white, size: 30),
        ],
      ),
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _selectIndex == 0
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'images/logo.png',
                        height: 250,
                        width: 250,
                      ),
                      const Center(
                        child: Text(
                          "Welcome to BikeGo",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "$name",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SizedBox(
                            height: 400,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: 2,
                              itemBuilder: (context, index) {
                                final cardColors = [
                                  Colors.black,
                                  Colors.indigo
                                ];
                                final icons = [Icons.lock, Icons.lock_open];
                                final titles = ["Reserved", "Not Reserved"];
                                final values = [
                                  menu.bikesReserved,
                                  menu.bikesNotReserved
                                ];
                                return BuildDashboardCard(
                                  color: cardColors[index],
                                  icon: icons[index],
                                  title: titles[index],
                                  value: values[index].toString(),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddBike()));
                          },
                          icon: Icon(
                            Icons.electric_bike,
                            size: 30,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Add New Bike",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.indigo,
                            onPrimary: Colors.black,
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const LisetBikes()),
    );
  }
}
