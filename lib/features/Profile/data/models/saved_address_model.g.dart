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
      firstName: fields[7] as String,
      lastName: fields[8] as String,
      company: fields[9] as String,
      addressLine1: fields[10] as String,
      addressLine2: fields[11] as String,
      city: fields[12] as String,
      stateProvince: fields[13] as String,
      postalCode: fields[14] as String,
      countryCode: fields[15] as String,
      phoneNumber: fields[16] as String,
      deliveryInstructions: fields[17] as String,
      isDefaultShipping: fields[18] as bool,
      isDefaultBilling: fields[19] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SavedAddressModel obj) {
    writer
      ..writeByte(20)
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
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.firstName)
      ..writeByte(8)
      ..write(obj.lastName)
      ..writeByte(9)
      ..write(obj.company)
      ..writeByte(10)
      ..write(obj.addressLine1)
      ..writeByte(11)
      ..write(obj.addressLine2)
      ..writeByte(12)
      ..write(obj.city)
      ..writeByte(13)
      ..write(obj.stateProvince)
      ..writeByte(14)
      ..write(obj.postalCode)
      ..writeByte(15)
      ..write(obj.countryCode)
      ..writeByte(16)
      ..write(obj.phoneNumber)
      ..writeByte(17)
      ..write(obj.deliveryInstructions)
      ..writeByte(18)
      ..write(obj.isDefaultShipping)
      ..writeByte(19)
      ..write(obj.isDefaultBilling);
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
