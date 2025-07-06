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
          .get();

      var notes = snapshot.docs
          .map(
            (doc) => Note.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();

      // Sort in memory instead of using Firestore ordering
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes;
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

      // print('Adding note: $text for user: $userId');
      await _firestore.collection(_collection).add(note.toMap());
      // print('Note added successfully');
    } catch (e) {
      // print('Error adding note: $e');
      throw Exception('Failed to add note: $e');
    }
  }

  // Update an existing note
  Future<void> updateNote(String noteId, String text) async {
    try {
      // print('Updating note: $noteId with text: $text');
      await _firestore.collection(_collection).doc(noteId).update({
        'text': text,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      // print('Note updated successfully');
    } catch (e) {
      // print('Error updating note: $e');
      throw Exception('Failed to update note: $e');
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      // print('Deleting note: $noteId');
      await _firestore.collection(_collection).doc(noteId).delete();
      // print('Note deleted successfully');
    } catch (e) {
      // print('Error deleting note: $e');
      throw Exception('Failed to delete note: $e');
    }
  }

  // Get real-time notes stream
  Stream<List<Note>> getNotesStream(String userId) {
    // print('Starting notes stream for user: $userId');
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          // print('Received ${snapshot.docs.length} notes from stream');
          var notes = snapshot.docs
              .map((doc) => Note.fromMap(doc.data(), doc.id))
              .toList();
          // Sort in memory instead of using Firestore ordering
          notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return notes;
        })
        .handleError((error) {
          // print('Stream error: $error');
          throw Exception('Stream error: $error');
        });
  }
}
