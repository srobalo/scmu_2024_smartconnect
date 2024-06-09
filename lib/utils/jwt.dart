import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

final String SECRET = "SHASM-2024";

String generateJwt({required Map<String, dynamic> payload}) {
  // Create a JWT
  final jwt = JWT(payload);

  // Sign the JWT with a secret key
  final token = jwt.sign(SecretKey(SECRET));

  return token;
}

Map<String, dynamic>? parseJwt(String token) {
  try {
    // Verify the token and decode its payload
    final jwt = JWT.verify(token, SecretKey(SECRET));

    // Return the payload
    return jwt.payload as Map<String, dynamic>;
  } on JWTExpiredException {
    print('jwt expired');
  } on JWTException catch (ex) {
    print('Error verifying JWT: $ex');
  }
  return null;
}

bool checkIsOwner(String token) {
  Map<String, dynamic>? map = parseJwt(token);
  if (map != null) {
    return map['owner'] == map['id'];
  }
  return false;
}

bool hasPermission(String token,String command) {
  Map<String, dynamic>? map = parseJwt(token);
  if (map != null) {
    List<String> commands = map['cap'];
    if (map['owner'] == map['id'] ) {
      return true;
    } else if(commands.contains(command)) {
      return true;
    } else {
      return false;
    }

  }
  return false;
}
