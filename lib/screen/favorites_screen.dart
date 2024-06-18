import 'package:cleveroadtest/model/cocktail.dart';
import 'package:cleveroadtest/screen/cocktail_details_screen.dart';
import 'package:cleveroadtest/service/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();
  final User user = FirebaseAuth.instance.currentUser!;

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
        title: Text('Favorites'),
      ),
      body: StreamBuilder<List<Cocktail>>(
        stream: firestoreService.getFavorites(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No favorites found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final cocktail = snapshot.data![index];
                return ListTile(
                  leading: cocktail.strDrinkThumb != null
                      ? Image.network(cocktail.strDrinkThumb!)
                      : null,
                  title: Text(cocktail.strDrink),
                  trailing: IconButton(
                    icon: Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => _toggleFavorite(cocktail, true),
                  ),
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
