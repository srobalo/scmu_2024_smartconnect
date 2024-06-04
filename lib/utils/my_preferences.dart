import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum DataType { String, Int, Double, Bool }

class MyPreferences {
  static Future<void> saveData<T>(String key, T value) async {
    String v = value.toString();
    print("Preferences: Saving KeyValue: $key $v");
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
    print("Preferences: Loading Key $key");
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
        final value = prefs.getString(key);
        print("Preferences: Key = $key, Value = $value");
        return value as T?;
      case DataType.Int:
        final value = prefs.getInt(key);
        print("Preferences: Key = $key, Value = $value");
        return value as T?;
      case DataType.Double:
        final value = prefs.getDouble(key);
        print("Preferences: Key = $key, Value = $value");
        return value as T?;
      case DataType.Bool:
        final value = prefs.getBool(key);
        print("Preferences: Key = $key, Value = $value");
        return value as T?;
    }
  }

  static Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("Cleared all preferences");
  }

  static Future<void> clearData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    print("Removed value of key $key from preferences");
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