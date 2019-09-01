// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DescribedPhoto _$DescribedPhotoFromJson(Map<String, dynamic> json) {
  return DescribedPhoto(
      name: json['name'] as String,
      url: json['url'] as String,
      descriptions:
          (json['descriptions'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$DescribedPhotoToJson(DescribedPhoto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'descriptions': instance.descriptions
    };
