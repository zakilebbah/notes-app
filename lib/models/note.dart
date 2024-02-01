import 'package:hive/hive.dart';
part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  // Hive noSQL fields
  @HiveField(0)
  int? NOTEID;
  @HiveField(1)
  String? TITLE;
  @HiveField(2)
  String? CONTENT;
  @HiveField(3)
  DateTime? DATECREATED;
  @HiveField(4)
  DateTime? DATEMODIFIED;
  @HiveField(5)
  String? SYNCSTATUS;
  @HiveField(6)
  int? VERSION;
  @HiveField(7)
  bool? ISDELETED;
  Note(
      {this.NOTEID,
      this.TITLE,
      this.CONTENT,
      this.DATECREATED,
      this.DATEMODIFIED,
      this.SYNCSTATUS,
      this.VERSION,
      this.ISDELETED = false});
  // Transform json to Note format
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      NOTEID: int.parse(json['NOTEID'].toString()),
      TITLE: json['TITLE'],
      CONTENT: json['CONTENT'],
      DATECREATED: DateTime.parse(json['DATECREATED'].toString()),
      DATEMODIFIED: DateTime.parse(json['DATEMODIFIED'].toString()),
      SYNCSTATUS: json['SYNCSTATUS'],
      VERSION: int.parse(json['VERSION'].toString()),
      ISDELETED:
          json['ISDELETED'].toString().toLowerCase() == "true" ? true : false,
    );
  }
  // Transform Note to JSON for making HTTP requests
  Map<String, String> toJson() => {
        'NOTEID': NOTEID.toString(),
        'TITLE': TITLE.toString(),
        'CONTENT': CONTENT.toString(),
        'DATECREATED': DATECREATED!.toIso8601String(),
        'DATEMODIFIED': DATEMODIFIED!.toIso8601String(),
        'SYNCSTATUS': SYNCSTATUS.toString(),
        'VERSION': VERSION.toString(),
        'ISDELETED': ISDELETED.toString(),
      };
}
