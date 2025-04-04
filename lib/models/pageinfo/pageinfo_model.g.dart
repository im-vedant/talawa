// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pageinfo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PageInfoAdapter extends TypeAdapter<PageInfo> {
  @override
  final int typeId = 15;

  @override
  PageInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PageInfo(
      endCursor: fields[0] as String?,
      hasNextPage: fields[1] as bool,
      hasPreviousPage: fields[2] as bool,
      startCursor: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PageInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.endCursor)
      ..writeByte(1)
      ..write(obj.hasNextPage)
      ..writeByte(2)
      ..write(obj.hasPreviousPage)
      ..writeByte(3)
      ..write(obj.startCursor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
