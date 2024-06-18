import 'package:cleveroadtest/model/cocktail.dart';
import 'package:cleveroadtest/screen/cocktail_details_screen.dart';
import 'package:cleveroadtest/service/cocktail_service.dart';
import 'package:flutter/material.dart';

class IngredientCocktailsScreen extends StatefulWidget {
  final String ingredient;

  IngredientCocktailsScreen({required this.ingredient});

  @override
  _IngredientCocktailsScreenState createState() =>
      _IngredientCocktailsScreenState();
}

class _IngredientCocktailsScreenState extends State<IngredientCocktailsScreen> {
  final CocktailService cocktailService = CocktailService();
  late Future<List<Cocktail>> futureCocktails;

  @override
  void initState() {
    super.initState();
    futureCocktails =
        cocktailService.fetchCocktailsByIngredient(widget.ingredient);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cocktails with ${widget.ingredient}'),
      ),
      body: FutureBuilder<List<Cocktail>>(
        future: futureCocktails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No cocktails found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final cocktail = snapshot.data![index];
                return ListTile(
                  leading: Image.network(cocktail.strDrinkThumb.toString()),
                  title: Text(cocktail.strDrink),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CocktailDetailsScreen(cocktailId: cocktail.idDrink),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
