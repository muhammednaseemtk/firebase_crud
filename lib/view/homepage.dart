import 'package:add_user/service/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseServices firebaseServices = FirebaseServices();

  final TextEditingController textController = TextEditingController();

  void openNoteBox({String? docId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(controller: textController),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docId == null) {
                firebaseServices.addNote(textController.text);
              } else {
                firebaseServices.updateNote(docId, textController.text);
              }

              textController.clear();

              Navigator.pop(context);
            },
            child: Text('Add', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        title: Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseServices.getNotesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Not found notes...'));
          }
          List notesList = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notesList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = notesList[index];
              String docId = document.id;

              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String noteText = data['note'];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              noteText,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => openNoteBox(docId: docId),
                            icon: Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            onPressed: () => firebaseServices.deleteNote(docId),
                            icon: Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        child: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: openNoteBox,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
