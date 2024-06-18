import 'package:cleveroadtest/model/cocktail.dart';
import 'package:cleveroadtest/repository/firestore_repository.dart';

class FirestoreService {
  final FirestoreRepository firestoreRepository = FirestoreRepository();

  Future<void> addFavorite(String userId, Cocktail cocktail) =>
      firestoreRepository.addFavorite(userId, cocktail);

  Future<void> removeFavorite(String userId, String cocktailId) =>
      firestoreRepository.removeFavorite(userId, cocktailId);

  Stream<List<Cocktail>> getFavorites(String userId) =>
      firestoreRepository.getFavorites(userId);
}
