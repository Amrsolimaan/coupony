// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_address_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedAddressModelAdapter extends TypeAdapter<SavedAddressModel> {
  @override
  final int typeId = 4;

  @override
  SavedAddressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedAddressModel(
      id: fields[0] as String,
      label: fields[1] as String,
      address: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      isDefault: fields[5] as bool,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedAddressModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.isDefault)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedAddressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
