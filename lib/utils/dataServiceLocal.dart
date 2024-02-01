import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class LocalData {
  // initialize the local NoSql Database (Hive)
  Future<void> initializeHiver() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
  }

  // Insert a note using a key
  Future<void> insertNote(Note note0) async {
    var box = await Hive.openBox<Note>('note');
    await box.put(note0.NOTEID, note0);
    await box.close();
  }

  Future<List<Note>> getAllNotes() async {
    var box = await Hive.openBox<Note>('note');
    return box.values
        .toList()
        .where((element) => element.ISDELETED == false)
        .toList();
  }

  Future<int> getNewNoteID() async {
    var box = await Hive.openBox<Note>('note');
    List<Note> notes0 = box.values.toList();
    notes0.sort((a, b) => a.NOTEID!.compareTo(b.NOTEID!));
    if (notes0.isNotEmpty) {
      return notes0.last.NOTEID! + 1;
      // DateTime.now().millisecondsSinceEpoch + ;
    }
    return 0;
  }

  Future<void> saveAppTitle(String title0) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('title', title0);
  }

  Future<String> getAppTitle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("title")) {
      String? title0 = prefs.getString('title');
      return Future.value(title0);
    }
    return Future.value("Notes App");
  }

  Future<void> saveSyncDate(String date0) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('sync_date', date0);
  }

  Future<String> getLastSync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("sync_date")) {
      String? date0 = prefs.getString('sync_date');
      return Future.value(date0);
    }
    return "";
  }
}
