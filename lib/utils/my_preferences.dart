import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum DataType { String, Int, Double, Bool }

class MyPreferences {
  static Future<void> saveData<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    final dataType = T == String
        ? DataType.String
        : T == int
        ? DataType.Int
        : T == double
        ? DataType.Double
        : T == bool
        ? DataType.Bool
        : throw Exception('Unsupported data type');

    switch (dataType) {
      case DataType.String:
        prefs.setString(key, value as String);
        break;
      case DataType.Int:
        prefs.setInt(key, value as int);
        break;
      case DataType.Double:
        prefs.setDouble(key, value as double);
        break;
      case DataType.Bool:
        prefs.setBool(key, value as bool);
        break;
    }
  }

  static Future<T?> loadData<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final dataType = T == String
        ? DataType.String
        : T == int
        ? DataType.Int
        : T == double
        ? DataType.Double
        : T == bool
        ? DataType.Bool
        : throw Exception('Unsupported data type');

    switch (dataType) {
      case DataType.String:
        return prefs.getString(key) as T?;
      case DataType.Int:
        return prefs.getInt(key) as T?;
      case DataType.Double:
        return prefs.getDouble(key) as T?;
      case DataType.Bool:
        return prefs.getBool(key) as T?;
    }
  }

  static Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

/*
void main() async {
  // Example usage:
  await MyPreferences.saveData('stringKey', 'Hello, World!');
  await MyPreferences.saveData('intKey', 42);
  await MyPreferences.saveData('doubleKey', 3.14);
  await MyPreferences.saveData('boolKey', true);

  final stringValue = await MyPreferences.loadData<String>('stringKey');
  final intValue = await MyPreferences.loadData<int>('intKey');
  final doubleValue = await MyPreferences.loadData<double>('doubleKey');
  final boolValue = await MyPreferences.loadData<bool>('boolKey');

  print('String Value: $stringValue');
  print('Int Value: $intValue');
  print('Double Value: $doubleValue');
  print('Bool Value: $boolValue');
}
*/