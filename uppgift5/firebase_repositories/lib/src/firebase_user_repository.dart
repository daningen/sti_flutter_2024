import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: implementation_imports
import 'package:shared/src/models/user.dart' as app_models;

class UserRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<app_models.User?> getByAuthId(String authId) async {
    final query = await _firestore
        .collection('users')
        .where('authId', isEqualTo: authId)
        .get();
    if (query.docs.isEmpty) return null;

    return app_models.User.fromJson(query.docs.first.data());
  }

  Future<app_models.User> create(app_models.User user) async {
    await _firestore.collection('users').doc(user.authId).set(user.toJson());
    return user;
  }
}
