import 'package:cleveroadtest/model/cocktail.dart';
import 'package:cleveroadtest/screen/cocktails_screen.dart';
import 'package:cleveroadtest/screen/favorites_screen.dart';
import 'package:cleveroadtest/screen/random_cocktail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Cocktail> _favoriteCocktails = [];

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      CocktailsScreen(),
      RandomCocktailScreen(),
      FavoritesScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleFavorite(Cocktail cocktail) {
    setState(() {
      if (_favoriteCocktails.contains(cocktail)) {
        _favoriteCocktails.remove(cocktail);
      } else {
        _favoriteCocktails.add(cocktail);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cocktail App'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.local_bar),
            label: 'Cocktails',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shuffle),
            label: 'Random Cocktail',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
