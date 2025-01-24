// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_table.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GuestTableAdapter extends TypeAdapter<GuestTable> {
  @override
  final int typeId = 1;

  @override
  GuestTable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GuestTable(
      id: fields[0] as String,
      maxGuests: fields[1] as int,
      assignedGuests: (fields[2] as List).cast<Guest>(),
    );
  }

  @override
  void write(BinaryWriter writer, GuestTable obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.maxGuests)
      ..writeByte(2)
      ..write(obj.assignedGuests);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestTableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
