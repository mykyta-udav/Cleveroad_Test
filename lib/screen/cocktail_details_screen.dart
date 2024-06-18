import 'package:cleveroadtest/model/cocktail.dart';
import 'package:cleveroadtest/screen/ingridient_cocktails_screen.dart';
import 'package:cleveroadtest/service/cocktail_service.dart';
import 'package:cleveroadtest/service/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CocktailDetailsScreen extends StatefulWidget {
  final String cocktailId;

  CocktailDetailsScreen({required this.cocktailId});

  @override
  _CocktailDetailsScreenState createState() => _CocktailDetailsScreenState();
}

class _CocktailDetailsScreenState extends State<CocktailDetailsScreen> {
  final CocktailService cocktailService = CocktailService();
  final FirestoreService firestoreService = FirestoreService();
  late Future<Cocktail> futureCocktail;
  late User user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    futureCocktail = cocktailService.fetchCocktailDetails(widget.cocktailId);
  }

  Future<void> _toggleFavorite(Cocktail cocktail, bool isFavorite) async {
    if (isFavorite) {
      await firestoreService.removeFavorite(user.uid, cocktail.idDrink);
    } else {
      await firestoreService.addFavorite(user.uid, cocktail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cocktail Details'),
      ),
      body: FutureBuilder<Cocktail>(
        future: futureCocktail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Cocktail not found'));
          } else {
            final cocktail = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  if (cocktail.strDrinkThumb != null)
                    Image.network(cocktail.strDrinkThumb!),
                  SizedBox(height: 16.0),
                  Text(
                    cocktail.strDrink,
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  if (cocktail.strCategory != null)
                    Text(
                      'Category: ${cocktail.strCategory}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  if (cocktail.strGlass != null)
                    Text(
                      'Glass: ${cocktail.strGlass}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  SizedBox(height: 16.0),
                  Text(
                    cocktail.strInstructions ?? 'No instructions provided.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Ingredients:',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  ...cocktail.ingredients.map((ingredient) {
                    int index = cocktail.ingredients.indexOf(ingredient);
                    String measure = cocktail.measures[index] ?? '';
                    return ListTile(
                      title: Text('$ingredient - $measure'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IngredientCocktailsScreen(
                                ingredient: ingredient ?? ''),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  StreamBuilder<List<Cocktail>>(
                    stream: firestoreService.getFavorites(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return IconButton(
                          icon: Icon(Icons.favorite_border),
                          onPressed: () {},
                        );
                      } else {
                        final favorites = snapshot.data!;
                        bool isFavorite = favorites
                            .any((c) => c.idDrink == widget.cocktailId);

                        return IconButton(
                          icon: Icon(isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border),
                          color: isFavorite ? Colors.red : null,
                          onPressed: () =>
                              _toggleFavorite(cocktail, isFavorite),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
