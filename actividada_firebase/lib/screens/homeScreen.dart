import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:taller_01/screens/noteDetailScreen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DatabaseReference notesRef;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    notesRef = FirebaseDatabase.instance.ref('notas/${user.uid}');
  }

  void agregarNota() {
  print('Botón "+" presionado'); // 👈 Agrega esto

  final nuevaNotaRef = notesRef.push();
  nuevaNotaRef.set({
    'titulo': 'Nuevo gasto',
    'descripcion': '',
    'precio': '',
    'fecha': DateTime.now().toIso8601String(),
  }).then((_) {
    print('Nota guardada correctamente ✅');
  }).catchError((error) {
    print('Error al guardar nota ❌: $error');
  });
}


  void cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gastos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: cerrarSesion,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: notesRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map,
            );
            final notas = data.entries.toList();

            return ListView.builder(
              itemCount: notas.length,
              itemBuilder: (context, index) {
                final id = notas[index].key;
                final nota = Map<String, dynamic>.from(notas[index].value);

                return ListTile(
                  title: Text(nota['titulo'] ?? ''),
                  subtitle: Text("Precio: \$${nota['precio'] ?? ''}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteDetailScreen(noteId: id, noteData: nota),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('No hay notas aún.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: agregarNota,
        child: const Icon(Icons.add),
      ),
    );
  }
}
