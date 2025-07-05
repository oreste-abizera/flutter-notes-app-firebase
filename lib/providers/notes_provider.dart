import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/note.dart';
import '../repositories/notes_repository.dart';

class NotesProvider with ChangeNotifier {
  final NotesRepository _notesRepository = NotesRepository();
  List<Note> _notes = [];
  bool _isLoading = false;
  String _errorMessage = '';
  StreamSubscription<List<Note>>? _notesSubscription;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasNotes => _notes.isNotEmpty;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Start listening to notes for the current user
  void startListeningToNotes(String userId) {
    try {
      _setLoading(true);
      clearError();

      _notesSubscription?.cancel(); // Cancel any existing subscription

      print('Starting to listen to notes for user: $userId');

      _notesSubscription = _notesRepository
          .getNotesStream(userId)
          .listen(
            (notes) {
              print('Received ${notes.length} notes from stream');
              _notes = notes;
              _setLoading(false);
              notifyListeners();
            },
            onError: (error) {
              print('Stream error: $error');
              _setError(error.toString());
              _setLoading(false);
            },
          );
    } catch (e) {
      print('Error starting stream: $e');
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Fetch all notes for the current user (fallback method)
  Future<void> fetchNotes(String userId) async {
    try {
      _setLoading(true);
      clearError();

      final notes = await _notesRepository.fetchNotes(userId);
      _notes = notes;
      _setLoading(false);
      notifyListeners(); // Notify UI about the changes
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Add a new note
  Future<bool> addNote(String text, String userId) async {
    try {
      clearError();
      print('Adding note: $text for user: $userId');

      await _notesRepository.addNote(text, userId);
      print('Note added successfully');
      // No need to manually refresh - stream will handle it
      return true;
    } catch (e) {
      print('Error adding note: $e');
      _setError(e.toString());
      return false;
    }
  }

  // Update an existing note
  Future<bool> updateNote(String noteId, String text, String userId) async {
    try {
      clearError();
      print('Updating note: $noteId with text: $text');

      await _notesRepository.updateNote(noteId, text);
      print('Note updated successfully');
      // No need to manually refresh - stream will handle it
      return true;
    } catch (e) {
      print('Error updating note: $e');
      _setError(e.toString());
      return false;
    }
  }

  // Delete a note
  Future<bool> deleteNote(String noteId, String userId) async {
    try {
      clearError();
      print('Deleting note: $noteId');

      await _notesRepository.deleteNote(noteId);
      print('Note deleted successfully');
      // No need to manually refresh - stream will handle it
      return true;
    } catch (e) {
      print('Error deleting note: $e');
      _setError(e.toString());
      return false;
    }
  }

  // Clear notes when user logs out
  void clearNotes() {
    _notesSubscription?.cancel();
    _notes = [];
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }
}
