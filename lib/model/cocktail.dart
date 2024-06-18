import 'package:cloud_firestore/cloud_firestore.dart';

class Cocktail {
  final String idDrink;
  final String strDrink;
  final String? strCategory;
  final String? strGlass;
  final String? strDrinkThumb;
  final String? strInstructions;
  final List<String?> ingredients;
  final List<String?> measures;

  Cocktail({
    required this.idDrink,
    required this.strDrink,
    this.strCategory,
    this.strGlass,
    this.strDrinkThumb,
    this.strInstructions,
    required this.ingredients,
    required this.measures,
  });

  factory Cocktail.fromJson(Map<String, dynamic> json) {
    List<String?> ingredients = [];
    List<String?> measures = [];
    for (int i = 1; i <= 15; i++) {
      String? ingredient = json['strIngredient$i'];
      String? measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add(ingredient);
        measures.add(measure);
      }
    }

    return Cocktail(
      idDrink: json['idDrink'],
      strDrink: json['strDrink'],
      strCategory: json['strCategory'],
      strGlass: json['strGlass'],
      strDrinkThumb: json['strDrinkThumb'],
      strInstructions: json['strInstructions'],
      ingredients: ingredients,
      measures: measures,
    );
  }

  String getIngredientsWithMeasures() {
    List<String> result = [];
    for (int i = 0; i < ingredients.length; i++) {
      if (measures[i] != null) {
        result.add('${ingredients[i]} - ${measures[i]}');
      } else {
        result.add('${ingredients[i]}');
      }
    }
    return result.join(', ');
  }

  Map<String, dynamic> toFirestore() {
    return {
      'idDrink': idDrink,
      'strDrink': strDrink,
      'strCategory': strCategory,
      'strGlass': strGlass,
      'strDrinkThumb': strDrinkThumb,
      'strInstructions': strInstructions,
      'ingredients': ingredients,
      'measures': measures,
    };
  }

  factory Cocktail.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Cocktail.fromJson(data);
  }
}
