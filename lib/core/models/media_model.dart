import 'package:hive/hive.dart';

// Manuel TypeAdapter oluşturuyoruz (build_runner çalışamadığı için)
class MediaAdapter extends TypeAdapter<MediaModel> {
  @override
  final int typeId = 0;

  @override
  MediaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaModel(
      id: fields[0] as String,
      path: fields[1] as String,
      type: MediaType.values[fields[2] as int],
      dateAdded: fields[3] as DateTime,
      isEncrypted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MediaModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.type.index)
      ..writeByte(3)
      ..write(obj.dateAdded)
      ..writeByte(4)
      ..write(obj.isEncrypted);
  }
}

enum MediaType { image, video }

class MediaModel extends HiveObject {
  final String id;
  final String path;
  final MediaType type;
  final DateTime dateAdded;
  final bool isEncrypted;

  MediaModel({
    required this.id,
    required this.path,
    required this.type,
    required this.dateAdded,
    this.isEncrypted = true,
  });
}
