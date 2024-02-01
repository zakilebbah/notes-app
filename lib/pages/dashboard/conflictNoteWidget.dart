import 'package:flutter/material.dart';

import '../../models/note.dart';

class ConflictNoteWidget extends StatelessWidget {
  final Note note;
  const ConflictNoteWidget({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          "Your local note “${note.TITLE!}” has changes that conflict with the version on the server. Before syncing, we need you to decide how to resolve this."),
      content: const Text(
        "It's important to choose carefully to ensure you don't lose any critical information.",
        style: TextStyle(color: Colors.red),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red)),
              onPressed: () {
                Navigator.pop(context, "LOCAL");
              },
              child: const Text(
                'Keep Local',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.greenAccent.shade700)),
              onPressed: () {
                Navigator.pop(context, "SERVER");
              },
              child: const Text(
                'Use Server',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        )
      ],
    );
  }
}
