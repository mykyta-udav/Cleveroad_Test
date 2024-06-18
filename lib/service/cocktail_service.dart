import 'dart:convert';
import 'package:cleveroadtest/model/cocktail.dart';
import 'package:http/http.dart' as http;

class CocktailService {
  static const String _baseUrl = 'https://www.thecocktaildb.com/api/json/v1/1';

  static Future<List<Cocktail>> searchCocktails(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/search.php?s=$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['drinks'] != null) {
        return (data['drinks'] as List)
            .map((e) => Cocktail.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load cocktails');
    }
  }

  static Future<List<Cocktail>> getCocktailsByLetter(String letter) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/search.php?f=$letter'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['drinks'] != null) {
        return (data['drinks'] as List)
            .map((e) => Cocktail.fromJson(e))
            .toList();
      } else {
        // Return empty list if no drinks found
        return [];
      }
    } else {
      throw Exception('Failed to load cocktails');
    }
  }

  Future<List<Cocktail>> fetchCocktailsByIngredient(String ingredient) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/filter.php?i=$ingredient'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> drinks = jsonResponse['drinks'];
      return drinks.map((drink) => Cocktail.fromJson(drink)).toList();
    } else {
      throw Exception('Failed to load cocktails by ingredient');
    }
  }

  Future<Cocktail> fetchCocktailDetails(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['drinks'] != null && data['drinks'].isNotEmpty) {
        return Cocktail.fromJson(data['drinks'][0]);
      } else {
        throw Exception('Cocktail not found');
      }
    } else {
      throw Exception('Failed to load cocktail details');
    }
  }

  static Future<Cocktail> fetchRandomCocktail() async {
    final response = await http.get(Uri.parse('$_baseUrl/random.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Cocktail.fromJson(data['drinks'][0]);
    } else {
      throw Exception('Failed to load random cocktail');
    }
  }
}
