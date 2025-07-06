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

      _notesSubscription = _notesRepository
          .getNotesStream(userId)
          .listen(
            (notes) {
              _notes = notes;
              _setLoading(false);
              notifyListeners();
            },
            onError: (error) {
              // print('Notes stream error: $error');
              _setError('Failed to load notes: $error');
              _setLoading(false);

              // Fallback to manual fetch if stream fails
              _fallbackToManualFetch(userId);
            },
          );
    } catch (e) {
      // print('Error starting notes stream: $e');
      _setError('Failed to start listening to notes: $e');
      _setLoading(false);

      // Fallback to manual fetch if stream setup fails
      _fallbackToManualFetch(userId);
    }
  }

  // Fallback method to fetch notes manually if stream fails
  void _fallbackToManualFetch(String userId) {
    // print('Falling back to manual fetch');
    fetchNotes(userId);
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
      // print('NotesProvider: Adding note "$text" for user $userId');

      await _notesRepository.addNote(text, userId);
      // print('NotesProvider: Note added successfully');

      // If stream is not working, manually refresh
      if (_notesSubscription == null || _notesSubscription!.isPaused) {
        // print('NotesProvider: Stream not active, manually refreshing');
        await fetchNotes(userId);
      }
      return true;
    } catch (e) {
      // print('NotesProvider: Error adding note: $e');
      _setError(e.toString());
      return false;
    }
  }

  // Update an existing note
  Future<bool> updateNote(String noteId, String text, String userId) async {
    try {
      clearError();
      // print('NotesProvider: Updating note $noteId with text "$text"');

      await _notesRepository.updateNote(noteId, text);
      // print('NotesProvider: Note updated successfully');

      // If stream is not working, manually refresh
      if (_notesSubscription == null || _notesSubscription!.isPaused) {
        // print('NotesProvider: Stream not active, manually refreshing');
        await fetchNotes(userId);
      }
      return true;
    } catch (e) {
      // print('NotesProvider: Error updating note: $e');
      _setError(e.toString());
      return false;
    }
  }

  // Delete a note
  Future<bool> deleteNote(String noteId, String userId) async {
    try {
      clearError();
      // print('NotesProvider: Deleting note $noteId');

      await _notesRepository.deleteNote(noteId);
      // print('NotesProvider: Note deleted successfully');

      // If stream is not working, manually refresh
      if (_notesSubscription == null || _notesSubscription!.isPaused) {
        // print('NotesProvider: Stream not active, manually refreshing');
        await fetchNotes(userId);
      }
      return true;
    } catch (e) {
      // print('NotesProvider: Error deleting note: $e');
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
