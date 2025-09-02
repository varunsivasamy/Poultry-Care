import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database_service.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  int? _editingIndex;
  String? _editingNoteId;

  void _addOrEditNote() async {
    if (_controller.text.trim().isNotEmpty) {
      if (_editingIndex == null) {
        // Add new note
        await _databaseService.addNote(_controller.text.trim());
      } else {
        // Update existing note
        if (_editingNoteId != null) {
          await _databaseService.updateNote(
              _editingNoteId!, _controller.text.trim());
        }
        _editingIndex = null;
        _editingNoteId = null;
      }
      _controller.clear();
    }
  }

  void _editNote(String noteId, String content) {
    setState(() {
      _controller.text = content;
      _editingNoteId = noteId;
    });
  }

  void _deleteNote(String noteId) async {
    await _databaseService.deleteNote(noteId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText:
                          _editingIndex == null ? 'Enter note' : 'Edit note',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addOrEditNote,
                  child: Text(_editingIndex == null ? 'Add' : 'Save'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _databaseService.getNotesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No notes yet'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var note = doc.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(note['content'] ?? ''),
                          subtitle: note['createdAt'] != null
                              ? Text(_formatTimestamp(note['createdAt']))
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _editNote(doc.id, note['content']),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteNote(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    }
    return 'Unknown date';
  }
}
