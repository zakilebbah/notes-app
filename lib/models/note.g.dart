// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      NOTEID: fields[0] as int?,
      TITLE: fields[1] as String?,
      CONTENT: fields[2] as String?,
      DATECREATED: fields[3] as DateTime?,
      DATEMODIFIED: fields[4] as DateTime?,
      SYNCSTATUS: fields[5] as String?,
      VERSION: fields[6] as int?,
      ISDELETED: fields[7] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.NOTEID)
      ..writeByte(1)
      ..write(obj.TITLE)
      ..writeByte(2)
      ..write(obj.CONTENT)
      ..writeByte(3)
      ..write(obj.DATECREATED)
      ..writeByte(4)
      ..write(obj.DATEMODIFIED)
      ..writeByte(5)
      ..write(obj.SYNCSTATUS)
      ..writeByte(6)
      ..write(obj.VERSION)
      ..writeByte(7)
      ..write(obj.ISDELETED);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
