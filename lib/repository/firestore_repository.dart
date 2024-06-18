import 'package:cleveroadtest/model/cocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addFavorite(String userId, Cocktail cocktail) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(cocktail.idDrink)
        .set(cocktail.toFirestore());
  }

  Future<void> removeFavorite(String userId, String cocktailId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(cocktailId)
        .delete();
  }

  Stream<List<Cocktail>> getFavorites(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Cocktail.fromFirestore(doc)).toList());
  }
}
