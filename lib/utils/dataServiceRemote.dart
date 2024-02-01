import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/note.dart';

class RemoteData {
  String url = "http://mahalates.com:3002";
  // Post request to sync a note
  Future<Map> syncNote(Note note0) async {
    Uri uri = Uri.parse('$url/sync-note');
    final response = await http.post(uri, body: note0.toJson());
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  // Post request to resolve a conflict between 2 notes
  Future<Map> resloveNoteConflict(Note note0, String dataSource0) async {
    Uri uri = Uri.parse('$url/resolve-note-conflict');
    Map map0 = note0.toJson();
    map0['DATASOURCE'] = dataSource0;
    final response = await http.post(uri, body: map0);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  // Check the connection status with the Nodejs server
  Future<bool> isOnline() async {
    Uri uri = Uri.parse('$url/is-online');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
