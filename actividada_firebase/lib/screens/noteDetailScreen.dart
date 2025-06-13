import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class NoteDetailScreen extends StatefulWidget {
  final String noteId;
  final Map noteData;

  const NoteDetailScreen({
    super.key,
    required this.noteId,
    required this.noteData,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController tituloController;
  late TextEditingController descripcionController;
  late TextEditingController precioController;

  @override
  void initState() {
    super.initState();
    tituloController = TextEditingController(text: widget.noteData['titulo']);
    descripcionController = TextEditingController(text: widget.noteData['descripcion']);
    precioController = TextEditingController(text: widget.noteData['precio']);
  }

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    precioController.dispose();
    super.dispose();
  }

  void actualizarNota() async {
    final user = FirebaseAuth.instance.currentUser!;
    final ref = FirebaseDatabase.instance.ref('notas/${user.uid}/${widget.noteId}');

    await ref.update({
      'titulo': tituloController.text.trim(),
      'descripcion': descripcionController.text.trim(),
      'precio': precioController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nota actualizada')),
    );

    Navigator.pop(context);
  }

  void eliminarNota() async {
    final user = FirebaseAuth.instance.currentUser!;
    final ref = FirebaseDatabase.instance.ref('notas/${user.uid}/${widget.noteId}');

    await ref.remove();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nota eliminada')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Nota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: eliminarNota,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: precioController,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: actualizarNota,
              child: const Text('Actualizar Nota'),
            ),
          ],
        ),
      ),
    );
  }
}
