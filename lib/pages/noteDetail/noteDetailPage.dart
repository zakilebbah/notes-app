import 'package:flutter/material.dart';
import 'package:notesapp/utils/utilFunctions.dart';

import '../../models/note.dart';
import '../../utils/dataServiceLocal.dart';

class NoteDetailPage extends StatefulWidget {
  final Note? note;
  const NoteDetailPage({super.key, required this.note});

  @override
  State<NoteDetailPage> createState() => NoteDetailPageState();
}

class NoteDetailPageState extends State<NoteDetailPage> {
  Note _currentNote = Note();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final LocalData _localData = LocalData();
  // Initialization of the TextEditingControllers with the widget parameter
  void initNote() {
    if (widget.note != null && widget.note!.NOTEID != null) {
      _currentNote = widget.note!;
      _contentController.text = _currentNote.CONTENT!;
      _titleController.text = _currentNote.TITLE!;
    }
  }

  // Insert or update a note into the local NoSQl database
  Future<void> _createNote() async {
    try {
      if (widget.note!.NOTEID == null) {
        _currentNote.DATECREATED = DateTime.now();
        _currentNote.NOTEID = await _localData.getNewNoteID();
        _currentNote.VERSION = 1;
        _currentNote.SYNCSTATUS = "Unsynced";
      } else {
        _currentNote.VERSION = _currentNote.VERSION! + 1;
      }
      _currentNote.DATEMODIFIED = DateTime.now();
      _currentNote.CONTENT = _contentController.text;
      _currentNote.TITLE = _titleController.text;
      if (_currentNote.SYNCSTATUS == "Synced") {
        _currentNote.SYNCSTATUS = "Unsynced";
      }
      await _localData.insertNote(_currentNote);
      MyFunct.showMessage("${_currentNote.TITLE} is saved", context);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      MyFunct.showErrorMessage(e.toString(), context);
    }
  }

  // Delete a note locally
  Future<void> _deleteNote() async {
    if (widget.note!.NOTEID != null) {
      _currentNote.ISDELETED = true;
      await _localData.insertNote(_currentNote);
      if (mounted) Navigator.pop(context);
    }
  }

  // Show delete note dialog
  Future<void> _showDeleteDialog() async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 60, 40, 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(bottom: 35),
                        alignment: Alignment.center,
                        child: const Text(
                          'Are your sure you want delete the note?',
                          style: TextStyle(
                            color: Color.fromRGBO(12, 12, 12, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10)),
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromRGBO(255, 0, 0, 1))),
                          onPressed: () async {
                            await _deleteNote();
                            if (mounted) Navigator.pop(context);
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10)),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.greenAccent.shade700)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ));
  }

  @override
  void initState() {
    super.initState();
    initNote();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        // Remove the keyboard on click outside of the keyboard
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 64,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.only(left: 26, top: 12),
              child: ElevatedButton(
                style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(10)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    )),
                    backgroundColor: MaterialStateProperty.all(
                        (Theme.of(context).primaryColor))),
                onPressed: () => {Navigator.pop(context)},
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 32, color: Colors.white),
              ),
            ),
            actions: [
              (widget.note != null && widget.note!.NOTEID != null)
                  ? Container(
                      width: 52,
                      height: 52,
                      margin: const EdgeInsets.only(right: 10, top: 12),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(10)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            )),
                            backgroundColor: MaterialStateProperty.all(
                                (const Color.fromRGBO(255, 0, 0, 1)))),
                        onPressed: () => _showDeleteDialog(),
                        child: const Icon(Icons.delete,
                            size: 32, color: Colors.white),
                      ),
                    )
                  : const SizedBox(),
              Container(
                width: 52,
                height: 52,
                margin: const EdgeInsets.only(right: 40, top: 12),
                child: ElevatedButton(
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(10)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(
                          (const Color.fromRGBO(59, 59, 59, 1)))),
                  onPressed: () => _createNote(),
                  child: const Icon(Icons.save, size: 32, color: Colors.white),
                ),
              )
            ],
          ),
          body: Container(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: TextFormField(
                      controller: _titleController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 30,
                        color: Color.fromRGBO(59, 59, 59, 1),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Title",
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(59, 59, 59, 1),
                              fontWeight: FontWeight.w500,
                              fontSize: 32) // labelText: 'Enter your username',
                          ),
                    )),
                Expanded(
                    child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: TextFormField(
                    controller: _contentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color.fromRGBO(59, 59, 59, 1),
                      fontWeight: FontWeight.w300,
                    ),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type something...',
                        hintStyle: TextStyle(
                            color: Color.fromRGBO(59, 59, 59, 1),
                            fontWeight: FontWeight.w300,
                            fontSize: 20) //
                        ),
                  ),
                ))
              ],
            ),
          ),
        ));
  }
}
