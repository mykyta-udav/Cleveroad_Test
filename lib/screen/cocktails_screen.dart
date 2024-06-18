import 'package:cleveroadtest/model/cocktail.dart';
import 'package:cleveroadtest/screen/cocktail_details_screen.dart';
import 'package:cleveroadtest/service/cocktail_service.dart';
import 'package:cleveroadtest/service/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CocktailsScreen extends StatefulWidget {
  @override
  _CocktailsScreenState createState() => _CocktailsScreenState();
}

class _CocktailsScreenState extends State<CocktailsScreen> {
  List<Cocktail> _cocktails = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  final FirestoreService firestoreService = FirestoreService();
  late User user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
  }

  void _getCocktailsByLetter(String letter) async {
    setState(() {
      _isLoading = true;
    });
    List<Cocktail> cocktails =
        await CocktailService.getCocktailsByLetter(letter);
    setState(() {
      _cocktails = cocktails;
      _isLoading = false;
    });
  }

  void _searchCocktails(String query) async {
    setState(() {
      _isLoading = true;
    });
    List<Cocktail> cocktails = await CocktailService.searchCocktails(query);
    setState(() {
      _cocktails = cocktails;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(Cocktail cocktail, bool isFavorite) async {
    if (isFavorite) {
      await firestoreService.removeFavorite(user.uid, cocktail.idDrink);
    } else {
      await firestoreService.addFavorite(user.uid, cocktail);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cocktails'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Cocktails',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchCocktails(_searchController.text);
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
                    .split('')
                    .map((letter) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _getCocktailsByLetter(letter);
                      },
                      child: Text(letter),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: _cocktails.isEmpty
                        ? Center(child: Text('На даний момент коктейлів немає'))
                        : ListView.builder(
                            itemCount: _cocktails.length,
                            itemBuilder: (context, index) {
                              final cocktail = _cocktails[index];
                              return ListTile(
                                leading: cocktail.strDrinkThumb != null
                                    ? Image.network(cocktail.strDrinkThumb!)
                                    : null,
                                title: Text(cocktail.strDrink),
                                trailing: StreamBuilder<List<Cocktail>>(
                                  stream:
                                      firestoreService.getFavorites(user.uid),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Icon(Icons.error);
                                    } else if (!snapshot.hasData) {
                                      return IconButton(
                                        icon: Icon(Icons.favorite_border),
                                        onPressed: () {},
                                      );
                                    } else {
                                      final favorites = snapshot.data!;
                                      bool isFavorite = favorites.any(
                                          (c) => c.idDrink == cocktail.idDrink);

                                      return IconButton(
                                        icon: Icon(isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border),
                                        color: isFavorite ? Colors.red : null,
                                        onPressed: () => _toggleFavorite(
                                            cocktail, isFavorite),
                                      );
                                    }
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CocktailDetailsScreen(
                                              cocktailId: cocktail.idDrink),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
