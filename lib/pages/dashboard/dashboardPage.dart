import 'dart:async';

import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notesapp/utils/utilFunctions.dart';

import '../../models/note.dart';
import '../../utils/dataServiceLocal.dart';
import '../../utils/dataServiceRemote.dart';
import '../noteDetail/noteDetailPage.dart';
import 'conflictNoteWidget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<List<Note>> _futureNotes = Future.value([]);
  final LocalData _localData = LocalData();
  final RemoteData _remoteData = RemoteData();
  String _lastSync = "";
  bool _isOnline = true;
  bool _allSyncLoading = false;
  String _appName = "";
  Cron cron = Cron();
  // Function to go to the NoteDetailPage to add a new note by providing an empty note as a parameter
  void _addNote() {
    try {
      // Check if synchronization is done
      if (!_allSyncLoading) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NoteDetailPage(
                    note: Note(),
                  )),
        ).then((value) => _getAllNotes());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Please wait until synchronization is complete",
          ),
        ));
      }
    } catch (e) {
      MyFunct.showErrorMessage(e.toString(), context);
    }
  }

  // Function that gets triggered on note title click, it goes to the NoteDetailPage
  // to update or delete a note by providing the chosen note
  void _onNoteClick(Note note0) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NoteDetailPage(
                note: note0,
              )),
    ).then((value) => _getAllNotes());
  }

  // Function that gets triggered on app title click, it shows a dialog to modify the app name
  Future<void> _changeAppName() async {
    TextEditingController titleController0 = TextEditingController();
    titleController0.text = _appName;
    String? newTitle0 = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Change application name',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    Container(
                      margin: const EdgeInsets.all(13),
                      // width: 180,
                      child: TextField(
                        controller: titleController0,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red)),
                          onPressed: () {
                            Navigator.pop(context, "");
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.greenAccent.shade700)),
                          onPressed: () {
                            Navigator.pop(context, titleController0.text);
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ));
    if (newTitle0 != null && newTitle0 != '') {
      await _localData.saveAppTitle(newTitle0);
      await _getAppName();
    }
  }

  // Function that gets the stored app name in local storage
  Future<void> _getAppName() async {
    String name0 = await _localData.getAppTitle();
    if (mounted) {
      setState(() {
        _appName = name0;
      });
    }
  }

  // Function that fetches all the notes from the NoSql database (Hive)
  void _getAllNotes() {
    if (mounted) {
      setState(() {
        _futureNotes = _localData.getAllNotes();
      });
    }
  }

  // Function that Changes the loading status of the synchronization to show a linear loading bar at the top
  void _changeLoadingStatus(bool status) {
    if (mounted) {
      setState(() {
        _allSyncLoading = status;
      });
    }
  }

  // Function that syncs all or a specified note
  Future<void> _syncNote(List<Note> notes0) async {
    try {
      _changeLoadingStatus(true);
      for (int i = 0; i < notes0.length; i++) {
        Note note0 = notes0[i];
        if (note0.SYNCSTATUS != "Conflict") {
          Map res = await _remoteData.syncNote(note0);
          if (res['SYNCSTATUS'] != "Conflict") {
            note0.SYNCSTATUS = res['SYNCSTATUS'];
            note0.VERSION = res['VERSION'];
            await _localData.insertNote(note0);
          } else {
            await _showConflitDialogue(note0);
          }
        } else {
          await _showConflitDialogue(note0);
        }
      }
      _saveLastSyncDate();
      _changeLoadingStatus(false);
      _getAllNotes();
      MyFunct.showMessage("Synchronization is complete !", context);
    } catch (e) {
      _changeLoadingStatus(false);
      MyFunct.showErrorMessage(e.toString(), context);
    }
  }

  // Function that handles sync conflict
  Future<void> _showConflitDialogue(Note note0) async {
    String? res = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => ConflictNoteWidget(
              note: note0,
            ));
    if (res != null) {
      Map res1 = await _remoteData.resloveNoteConflict(note0, res);

      if (res1['DATASOURCE'] == "SERVER" && res1['NOTE'] != null) {
        note0 = Note.fromJson(res1['NOTE']);
      }
      note0.SYNCSTATUS = "Synced";
      await _localData.insertNote(note0);
    } else {
      note0.SYNCSTATUS = "Conflict";
      await _localData.insertNote(note0);
    }
  }

  // Function that saves the current dateTime as that last sync date
  void _saveLastSyncDate() async {
    String date0 = DateFormat("MM/dd/yyyy h:mm a").format(DateTime.now());
    await _localData.saveSyncDate(date0);
    if (mounted) {
      setState(() {
        _lastSync = date0.toString();
      });
    }
  }

  // Function that gets the last sync date from local storage
  void _getLastSyncDate() async {
    String date0 = await _localData.getLastSync();
    if (mounted) {
      setState(() {
        _lastSync = date0.toString();
      });
    }
  }

  // Function that checks the connection status with the REST API every 10 seconds
  void _checkIsOnline() {
    cron.schedule(Schedule.parse('*/10 * * * * *'), () async {
      _remoteData.isOnline().then((value) {
        if (mounted) {
          setState(() {
            _isOnline = value;
          });
        }
      });
    });
  }

  // Function that gets triggered on the sync all button to sync all the notes
  void _syncAllNotes() async {
    List<Note> notes0 = await _futureNotes;
    if (notes0.isNotEmpty) {
      await _syncNote(notes0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "No Notes to synchronize",
        ),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _getAllNotes();
    _getAppName();
    _checkIsOnline();
    _getLastSyncDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 64,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Container(
                margin: const EdgeInsets.fromLTRB(26, 26, 12, 26),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: <Widget>[
                          // Max Size Widget
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle),
                          ),

                          Positioned(
                            top: 0,
                            left: 13,
                            child: Container(
                              height: 52,
                              width: 8,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              "Elastic Team",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )),
                        GestureDetector(
                            onTap: () => _changeAppName(),
                            child: Text(
                              _appName,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  overflow: TextOverflow.ellipsis),
                            ))
                      ],
                    ))
                  ],
                )),
            actions: [
              Container(
                  margin: const EdgeInsets.only(right: 26),
                  child: _isOnline
                      ? Icon(
                          Icons.wifi,
                          color: Colors.greenAccent.shade700,
                          size: 36,
                        )
                      : Icon(
                          Icons.wifi_off_outlined,
                          color: Colors.redAccent.shade700,
                          size: 36,
                        )),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(10),
              child: _allSyncLoading
                  ? LinearProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    )
                  : const SizedBox(),
            )),
        body: Container(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  // Show last sync date only if there is a stored date
                  mainAxisAlignment: _lastSync != ''
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _lastSync != ''
                        ? Flexible(
                            child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "Last Sync: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(_lastSync)
                            ],
                          ))
                        : const SizedBox(),
                    IconButton(
                        onPressed: () => _syncAllNotes(),
                        icon: Icon(
                          Icons.sync,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ))
                  ],
                ),
                Expanded(
                    child: FutureBuilder<List<Note>>(
                        future: _futureNotes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (BuildContext context, int i) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                        color: Color.fromRGBO(253, 255, 182, 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(14))),
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.fromLTRB(
                                        24, 26, 24, 26),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                            child: GestureDetector(
                                                onTap: () => _onNoteClick(
                                                    snapshot.data![i]),
                                                child: Text(
                                                  snapshot.data![i].TITLE!,
                                                  style: const TextStyle(
                                                      fontSize: 22,
                                                      color: Colors.black),
                                                ))),
                                        IconButton(
                                          onPressed: () =>
                                              _syncNote([snapshot.data![i]]),
                                          icon: snapshot.data![i].SYNCSTATUS ==
                                                  "Unsynced"
                                              ? const Icon(
                                                  Icons.cloud_off_rounded,
                                                  size: 22,
                                                  color: Color.fromRGBO(
                                                      255, 0, 0, 1),
                                                )
                                              : snapshot.data![i].SYNCSTATUS ==
                                                      "Synced"
                                                  ? Icon(
                                                      Icons.cloud_done_rounded,
                                                      size: 22,
                                                      color: Colors
                                                          .greenAccent.shade400,
                                                    )
                                                  : const Icon(
                                                      Icons.cloud,
                                                      size: 22,
                                                      color: Colors.grey,
                                                    ),
                                        )
                                      ],
                                    ),
                                  );
                                });
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          return Center(
                              child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ));
                        }))
              ],
            )),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(right: 20, bottom: 20),
          width: 68,
          height: 68,
          child: FittedBox(
            child: FloatingActionButton(
              elevation: 0,
              onPressed: () => _addNote(),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
        ));
  }
}
