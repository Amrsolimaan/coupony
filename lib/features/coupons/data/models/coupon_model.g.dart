// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CouponModelAdapter extends TypeAdapter<CouponModel> {
  @override
  final int typeId = 3;

  @override
  CouponModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CouponModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      discountPercentage: fields[3] as double,
      originalPrice: fields[4] as double?,
      discountedPrice: fields[5] as double?,
      storeName: fields[6] as String,
      storeId: fields[7] as String,
      categoryId: fields[8] as String,
      imageUrl: fields[9] as String,
      expiryDate: fields[10] as DateTime,
      isActive: fields[11] as bool,
      isFavorited: fields[12] as bool,
      usageCount: fields[13] as int,
      maxUsage: fields[14] as int?,
      couponCode: fields[15] as String?,
      termsAndConditions: fields[16] as String?,
      createdAt: fields[17] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CouponModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.discountPercentage)
      ..writeByte(4)
      ..write(obj.originalPrice)
      ..writeByte(5)
      ..write(obj.discountedPrice)
      ..writeByte(6)
      ..write(obj.storeName)
      ..writeByte(7)
      ..write(obj.storeId)
      ..writeByte(8)
      ..write(obj.categoryId)
      ..writeByte(9)
      ..write(obj.imageUrl)
      ..writeByte(10)
      ..write(obj.expiryDate)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.isFavorited)
      ..writeByte(13)
      ..write(obj.usageCount)
      ..writeByte(14)
      ..write(obj.maxUsage)
      ..writeByte(15)
      ..write(obj.couponCode)
      ..writeByte(16)
      ..write(obj.termsAndConditions)
      ..writeByte(17)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CouponModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
