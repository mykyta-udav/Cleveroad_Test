import 'dart:async';

import 'package:cleveroadtest/model/cocktail.dart';
import 'package:cleveroadtest/screen/ingridient_cocktails_screen.dart';
import 'package:cleveroadtest/service/cocktail_service.dart';
import 'package:cleveroadtest/service/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RandomCocktailScreen extends StatefulWidget {
  @override
  _RandomCocktailScreenState createState() => _RandomCocktailScreenState();
}

class _RandomCocktailScreenState extends State<RandomCocktailScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final User user = FirebaseAuth.instance.currentUser!;
  Cocktail? _randomCocktail;
  bool _isLoading = true;
  Timer? _timer;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchRandomCocktail();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchRandomCocktail();
    });
  }

  void _fetchRandomCocktail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Cocktail cocktail = await CocktailService.fetchRandomCocktail();
      bool isFavorite = await _checkIfFavorite(cocktail);
      setState(() {
        _randomCocktail = cocktail;
        _isFavorite = isFavorite;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // handle error
    }
  }

  Future<bool> _checkIfFavorite(Cocktail cocktail) async {
    final snapshot = await firestoreService
        .getFavorites(user.uid)
        .first; // Get the first value of the stream
    return snapshot.any((c) => c.idDrink == cocktail.idDrink);
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await firestoreService.removeFavorite(user.uid, _randomCocktail!.idDrink);
    } else {
      await firestoreService.addFavorite(user.uid, _randomCocktail!);
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Cocktail'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _randomCocktail == null
              ? Center(child: Text('Failed to load cocktail'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_randomCocktail?.strDrinkThumb != null)
                        Image.network(_randomCocktail!.strDrinkThumb!),
                      SizedBox(height: 16.0),
                      Text(
                        _randomCocktail!.strDrink,
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      if (_randomCocktail?.strCategory != null)
                        Text(
                          'Category: ${_randomCocktail?.strCategory}',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      if (_randomCocktail?.strGlass != null)
                        Text(
                          'Glass: ${_randomCocktail?.strGlass}',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      SizedBox(height: 16.0),
                      Text(
                        _randomCocktail?.strInstructions ??
                            'No instructions provided.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Ingredients:',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      ..._randomCocktail!.ingredients.map((ingredient) {
                        int index =
                            _randomCocktail!.ingredients.indexOf(ingredient);
                        String measure = _randomCocktail?.measures[index] ?? '';
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
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : null,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ],
                  ),
                ),
    );
  }
}
