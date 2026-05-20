import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _cartCol =>
      _db.collection('users').doc(_uid).collection('cart');

  Future<void> addToCart(Product product, {int qty = 1}) async {
    final doc = _cartCol.doc(product.id);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(doc);
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        final currentQty = (data['qty'] ?? 1) as int;
        tx.update(doc, {'qty': currentQty + qty});
      } else {
        tx.set(doc, {
          'productId': product.id,
          'name': product.name,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'category': product.category,
          'qty': qty,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> cartStream() {
    return _cartCol.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> remove(String productId) => _cartCol.doc(productId).delete();

  Future<void> setQty(String productId, int qty) async {
    if (qty <= 0) {
      await remove(productId);
    } else {
      await _cartCol.doc(productId).update({'qty': qty});
    }
  }
}