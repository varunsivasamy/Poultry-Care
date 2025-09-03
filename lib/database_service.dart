import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Notes Collection
  CollectionReference get _notesCollection =>
      _firestore.collection('users').doc(currentUserId).collection('notes');

  // Records Collection
  CollectionReference get _recordsCollection =>
      _firestore.collection('users').doc(currentUserId).collection('records');

  // Events Collection
  CollectionReference get _eventsCollection =>
      _firestore.collection('users').doc(currentUserId).collection('events');

  // Diseases Collection
  CollectionReference get _diseasesCollection =>
      _firestore.collection('users').doc(currentUserId).collection('diseases');

  // Products Collection
  CollectionReference get _productsCollection =>
      _firestore.collection('users').doc(currentUserId).collection('products');

  // Vaccinations Collection
  CollectionReference get _vaccinationsCollection => _firestore
      .collection('users')
      .doc(currentUserId)
      .collection('vaccinations');

  // Feed Info Collection
  CollectionReference get _feedInfoCollection =>
      _firestore.collection('users').doc(currentUserId).collection('feedInfo');

  // Add Note
  Future<void> addNote(String note) async {
    if (currentUserId == null) return;

    // Add to notes collection
    await _notesCollection.add({
      'content': note,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Also add to records collection for recent activity
    await _recordsCollection.add({
      'type': 'note',
      'content': 'Added note: $note',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get Notes Stream
  Stream<QuerySnapshot> getNotesStream() {
    if (currentUserId == null) return const Stream.empty();

    return _notesCollection.orderBy('createdAt', descending: true).snapshots();
  }

  // Update Note
  Future<void> updateNote(String noteId, String newContent) async {
    if (currentUserId == null) return;

    await _notesCollection.doc(noteId).update({
      'content': newContent,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete Note
  Future<void> deleteNote(String noteId) async {
    if (currentUserId == null) return;

    // Get the note content before deleting
    final noteDoc = await _notesCollection.doc(noteId).get();
    final noteData = noteDoc.data() as Map<String, dynamic>?;
    final noteContent = noteData?['content'] ?? '';

    // Delete from notes collection
    await _notesCollection.doc(noteId).delete();

    // Add deletion record to recent activity
    await _recordsCollection.add({
      'type': 'note_deleted',
      'content': 'Deleted note: $noteContent',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Add Record
  Future<void> addRecord(Map<String, dynamic> record) async {
    if (currentUserId == null) return;

    await _recordsCollection.add({
      ...record,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update user's total stats
    await _updateUserStats();
  }

  // Get Records Stream
  Stream<QuerySnapshot> getRecordsStream() {
    if (currentUserId == null) return const Stream.empty();

    return _recordsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update Record
  Future<void> updateRecord(
      String recordId, Map<String, dynamic> record) async {
    if (currentUserId == null) return;

    await _recordsCollection.doc(recordId).update({
      ...record,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update user's total stats
    await _updateUserStats();
  }

  // Delete Record
  Future<void> deleteRecord(String recordId) async {
    if (currentUserId == null) return;

    await _recordsCollection.doc(recordId).delete();

    // Update user's total stats
    await _updateUserStats();
  }

  // Add Event
  Future<void> addEvent(Map<String, dynamic> event) async {
    if (currentUserId == null) return;

    // Add to events collection
    await _eventsCollection.add({
      ...event,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Also add to records collection for recent activity
    await _recordsCollection.add({
      'type': 'event',
      'content': 'Created event: ${event['title'] ?? 'Untitled Event'}',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get Events Stream
  Stream<QuerySnapshot> getEventsStream() {
    if (currentUserId == null) return const Stream.empty();

    return _eventsCollection.orderBy('createdAt', descending: true).snapshots();
  }

  // Delete Event
  Future<void> deleteEvent(String eventId) async {
    if (currentUserId == null) return;

    // Get the event title before deleting
    final eventDoc = await _eventsCollection.doc(eventId).get();
    final eventData = eventDoc.data() as Map<String, dynamic>?;
    final eventTitle = eventData?['title'] ?? 'Untitled Event';

    // Delete from events collection
    await _eventsCollection.doc(eventId).delete();

    // Add deletion record to recent activity
    await _recordsCollection.add({
      'type': 'event_deleted',
      'content': 'Deleted event: $eventTitle',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Add Disease
  Future<void> addDisease(Map<String, dynamic> disease) async {
    if (currentUserId == null) return;

    await _diseasesCollection.add({
      ...disease,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add to recent activity
    await _recordsCollection.add({
      'type': 'disease',
      'content': 'Added disease: ${disease['name'] ?? 'Untitled Disease'}',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get Diseases Stream
  Stream<QuerySnapshot> getDiseasesStream() {
    if (currentUserId == null) return const Stream.empty();

    return _diseasesCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update Disease
  Future<void> updateDisease(
      String diseaseId, Map<String, dynamic> disease) async {
    if (currentUserId == null) return;

    await _diseasesCollection.doc(diseaseId).update({
      ...disease,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete Disease
  Future<void> deleteDisease(String diseaseId) async {
    if (currentUserId == null) return;

    await _diseasesCollection.doc(diseaseId).delete();
  }

  // Add Product
  Future<void> addProduct(Map<String, dynamic> product) async {
    if (currentUserId == null) return;

    await _productsCollection.add({
      ...product,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add to recent activity
    await _recordsCollection.add({
      'type': 'product',
      'content': 'Added product: ${product['name'] ?? 'Untitled Product'}',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get Products Stream
  Stream<QuerySnapshot> getProductsStream() {
    if (currentUserId == null) return const Stream.empty();

    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update Product
  Future<void> updateProduct(
      String productId, Map<String, dynamic> product) async {
    if (currentUserId == null) return;

    await _productsCollection.doc(productId).update({
      ...product,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete Product
  Future<void> deleteProduct(String productId) async {
    if (currentUserId == null) return;

    await _productsCollection.doc(productId).delete();
  }

  // Add Vaccination
  Future<void> addVaccination(Map<String, dynamic> vaccination) async {
    if (currentUserId == null) return;

    await _vaccinationsCollection.add({
      ...vaccination,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add to recent activity
    await _recordsCollection.add({
      'type': 'vaccination',
      'content':
          'Added vaccination: ${vaccination['name'] ?? 'Untitled Vaccination'}',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get Vaccinations Stream
  Stream<QuerySnapshot> getVaccinationsStream() {
    if (currentUserId == null) return const Stream.empty();

    return _vaccinationsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update Vaccination
  Future<void> updateVaccination(
      String vaccinationId, Map<String, dynamic> vaccination) async {
    if (currentUserId == null) return;

    await _vaccinationsCollection.doc(vaccinationId).update({
      ...vaccination,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete Vaccination
  Future<void> deleteVaccination(String vaccinationId) async {
    if (currentUserId == null) return;

    await _vaccinationsCollection.doc(vaccinationId).delete();
  }

  // Add Feed Info
  Future<void> addFeedInfo(Map<String, dynamic> feedInfo) async {
    if (currentUserId == null) return;

    await _feedInfoCollection.add({
      ...feedInfo,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add to recent activity
    await _recordsCollection.add({
      'type': 'feed_info',
      'content':
          'Added feed info: ${feedInfo['title'] ?? 'Untitled Feed Info'}',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get Feed Info Stream
  Stream<QuerySnapshot> getFeedInfoStream() {
    if (currentUserId == null) return const Stream.empty();

    return _feedInfoCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update Feed Info
  Future<void> updateFeedInfo(
      String feedInfoId, Map<String, dynamic> feedInfo) async {
    if (currentUserId == null) return;

    await _feedInfoCollection.doc(feedInfoId).update({
      ...feedInfo,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete Feed Info
  Future<void> deleteFeedInfo(String feedInfoId) async {
    if (currentUserId == null) return;

    await _feedInfoCollection.doc(feedInfoId).delete();
  }

  // Update User Stats
  Future<void> _updateUserStats() async {
    if (currentUserId == null) return;

    try {
      // Get all records
      QuerySnapshot recordsSnapshot = await _recordsCollection.get();

      int totalChicks = 0;
      int totalDead = 0;

      for (var doc in recordsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalChicks += int.tryParse(data['chicks']?.toString() ?? '0') ?? 0;
        totalDead += int.tryParse(data['dead']?.toString() ?? '0') ?? 0;
      }

      // Update user document
      await _firestore.collection('users').doc(currentUserId).update({
        'totalChicks': totalChicks,
        'totalDead': totalDead,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user stats: $e');
    }
  }

  // Get User Stats
  Future<Map<String, dynamic>?> getUserStats() async {
    if (currentUserId == null) return null;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUserId).get();

      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      return null;
    }
  }

  // Get Dashboard Summary
  Future<Map<String, dynamic>> getDashboardSummary() async {
    if (currentUserId == null) return {};

    try {
      Map<String, dynamic> summary = {};

      // Get counts for each collection
      final diseasesSnapshot = await _diseasesCollection.get();
      final productsSnapshot = await _productsCollection.get();
      final vaccinationsSnapshot = await _vaccinationsCollection.get();
      final feedInfoSnapshot = await _feedInfoCollection.get();
      final notesSnapshot = await _notesCollection.get();

      summary['diseasesCount'] = diseasesSnapshot.docs.length;
      summary['productsCount'] = productsSnapshot.docs.length;
      summary['vaccinationsCount'] = vaccinationsSnapshot.docs.length;
      summary['feedInfoCount'] = feedInfoSnapshot.docs.length;
      summary['notesCount'] = notesSnapshot.docs.length;

      // Get latest items for each category
      if (diseasesSnapshot.docs.isNotEmpty) {
        summary['latestDisease'] = diseasesSnapshot.docs.first.data();
      }
      if (productsSnapshot.docs.isNotEmpty) {
        summary['latestProduct'] = productsSnapshot.docs.first.data();
      }
      if (vaccinationsSnapshot.docs.isNotEmpty) {
        summary['latestVaccination'] = vaccinationsSnapshot.docs.first.data();
      }
      if (feedInfoSnapshot.docs.isNotEmpty) {
        summary['latestFeedInfo'] = feedInfoSnapshot.docs.first.data();
      }

      return summary;
    } catch (e) {
      debugPrint('Error getting dashboard summary: $e');
      return {};
    }
  }
}
