// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_preferences_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SellerPreferencesModelAdapter
    extends TypeAdapter<SellerPreferencesModel> {
  @override
  final int typeId = 2;

  @override
  SellerPreferencesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SellerPreferencesModel(
      timestamp: fields[0] as DateTime?,
      isSynced: fields[1] as bool,
      priceCategory: fields[2] as String?,
      customerReachMethod: fields[3] as String?,
      bestOfferTime: fields[4] as String?,
      targetAudience: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SellerPreferencesModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.isSynced)
      ..writeByte(2)
      ..write(obj.priceCategory)
      ..writeByte(3)
      ..write(obj.customerReachMethod)
      ..writeByte(4)
      ..write(obj.bestOfferTime)
      ..writeByte(5)
      ..write(obj.targetAudience);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SellerPreferencesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
