// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesModelAdapter extends TypeAdapter<UserPreferencesModel> {
  @override
  final int typeId = 1;

  @override
  UserPreferencesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferencesModel(
      selectedCategories: (fields[0] as List).cast<String>(),
      timestamp: fields[1] as DateTime,
      isSynced: fields[2] as bool,
      budgetPreference: fields[3] as String?,
      budgetSliderValue: fields[4] as double?,
      shoppingStyles: (fields[5] as List?)?.cast<String>(),
      categoryScores: (fields[6] as Map).cast<String, int>(),
      seenProductIds: (fields[7] as List).cast<String>(),
      lastDecayDate: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferencesModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.selectedCategories)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.isSynced)
      ..writeByte(3)
      ..write(obj.budgetPreference)
      ..writeByte(4)
      ..write(obj.budgetSliderValue)
      ..writeByte(5)
      ..write(obj.shoppingStyles)
      ..writeByte(6)
      ..write(obj.categoryScores)
      ..writeByte(7)
      ..write(obj.seenProductIds)
      ..writeByte(8)
      ..write(obj.lastDecayDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
