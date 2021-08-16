import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage();

class DeleteAll {

  void deleteAllTokens() async {
    await _storage.deleteAll();
  }

}