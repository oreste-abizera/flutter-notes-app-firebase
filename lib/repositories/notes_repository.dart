import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notes';

  // Fetch all notes for a user
  Future<List<Note>> fetchNotes(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => Note.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  // Add a new note
  Future<void> addNote(String text, String userId) async {
    try {
      final now = DateTime.now();
      final note = Note(
        id: '', // Firestore will generate this
        text: text,
        createdAt: now,
        updatedAt: now,
        userId: userId,
      );

      await _firestore.collection(_collection).add(note.toMap());
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  // Update an existing note
  Future<void> updateNote(String noteId, String text) async {
    try {
      await _firestore.collection(_collection).doc(noteId).update({
        'text': text,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection(_collection).doc(noteId).delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  // Get real-time notes stream
  Stream<List<Note>> getNotesStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Note.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
