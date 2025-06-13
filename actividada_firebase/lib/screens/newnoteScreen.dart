import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({super.key});

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  final precioController = TextEditingController();

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    precioController.dispose();
    super.dispose();
  }

  void guardarNota() async {
    final user = FirebaseAuth.instance.currentUser!;
    final databaseRef = FirebaseDatabase.instance.ref('notas/${user.uid}');

    final nuevaNota = {
      'titulo': tituloController.text.trim(),
      'descripcion': descripcionController.text.trim(),
      'precio': precioController.text.trim(),
      'fecha': DateTime.now().toIso8601String(),
    };

    if (nuevaNota.values.any((v) => v.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    await databaseRef.push().set(nuevaNota);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nota guardada correctamente')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Nota')),
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
              onPressed: guardarNota,
              child: const Text('Guardar Nota'),
            ),
          ],
        ),
      ),
    );
  }
}
