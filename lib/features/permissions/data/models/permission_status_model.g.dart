// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_status_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PermissionStatusModelAdapter extends TypeAdapter<PermissionStatusModel> {
  @override
  final int typeId = 3;

  @override
  PermissionStatusModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PermissionStatusModel(
      locationStatus: fields[0] as String?,
      notificationStatus: fields[1] as String?,
      latitude: fields[2] as double?,
      longitude: fields[3] as double?,
      fcmToken: fields[4] as String?,
      timestamp: fields[5] as DateTime?,
      hasCompletedFlow: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PermissionStatusModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.locationStatus)
      ..writeByte(1)
      ..write(obj.notificationStatus)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.fcmToken)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.hasCompletedFlow);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionStatusModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
