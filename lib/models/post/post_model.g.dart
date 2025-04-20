// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostAdapter extends TypeAdapter<Post> {
  @override
  final int typeId = 6;

  @override
  Post read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Post(
      sId: fields[0] as String,
      caption: fields[1] as String?,
      createdAt: fields[2] as DateTime?,
      creator: fields[3] as User?,
      organization: fields[4] as OrgInfo?,
      attachments: (fields[5] as List?)?.cast<PostAttachment>(),
      updater: fields[6] as User?,
      commentsCount: fields[7] as int?,
      downVotesCount: fields[8] as int?,
      upVotesCount: fields[9] as int?,
      pinnedAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
      comments: fields[14] as PostCommentsConnection?,
      downVoters: fields[12] as PostDownVotersConnection?,
      upVoters: fields[13] as PostUpVotersConnection?,
    );
  }

  @override
  void write(BinaryWriter writer, Post obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.sId)
      ..writeByte(1)
      ..write(obj.caption)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.creator)
      ..writeByte(4)
      ..write(obj.organization)
      ..writeByte(5)
      ..write(obj.attachments)
      ..writeByte(6)
      ..write(obj.updater)
      ..writeByte(7)
      ..write(obj.commentsCount)
      ..writeByte(8)
      ..write(obj.downVotesCount)
      ..writeByte(9)
      ..write(obj.upVotesCount)
      ..writeByte(10)
      ..write(obj.pinnedAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.downVoters)
      ..writeByte(13)
      ..write(obj.upVoters)
      ..writeByte(14)
      ..write(obj.comments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostDownVotersConnectionAdapter
    extends TypeAdapter<PostDownVotersConnection> {
  @override
  final int typeId = 8;

  @override
  PostDownVotersConnection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostDownVotersConnection(
      pageInfo: fields[1] as PageInfo,
      edges: (fields[0] as List?)?.cast<PostDownVotersConnectionEdge>(),
    );
  }

  @override
  void write(BinaryWriter writer, PostDownVotersConnection obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.edges)
      ..writeByte(1)
      ..write(obj.pageInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostDownVotersConnectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostDownVotersConnectionEdgeAdapter
    extends TypeAdapter<PostDownVotersConnectionEdge> {
  @override
  final int typeId = 18;

  @override
  PostDownVotersConnectionEdge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostDownVotersConnectionEdge(
      cursor: fields[0] as String,
      node: fields[1] as User,
    );
  }

  @override
  void write(BinaryWriter writer, PostDownVotersConnectionEdge obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.cursor)
      ..writeByte(1)
      ..write(obj.node);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostDownVotersConnectionEdgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostUpVotersConnectionAdapter
    extends TypeAdapter<PostUpVotersConnection> {
  @override
  final int typeId = 17;

  @override
  PostUpVotersConnection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostUpVotersConnection(
      pageInfo: fields[1] as PageInfo,
      edges: (fields[0] as List).cast<PostUpVotersConnectionEdge>(),
    );
  }

  @override
  void write(BinaryWriter writer, PostUpVotersConnection obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.edges)
      ..writeByte(1)
      ..write(obj.pageInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostUpVotersConnectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostUpVotersConnectionEdgeAdapter
    extends TypeAdapter<PostUpVotersConnectionEdge> {
  @override
  final int typeId = 13;

  @override
  PostUpVotersConnectionEdge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostUpVotersConnectionEdge(
      cursor: fields[0] as String,
      node: fields[1] as User,
    );
  }

  @override
  void write(BinaryWriter writer, PostUpVotersConnectionEdge obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.cursor)
      ..writeByte(1)
      ..write(obj.node);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostUpVotersConnectionEdgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostCommentsConnectionAdapter
    extends TypeAdapter<PostCommentsConnection> {
  @override
  final int typeId = 14;

  @override
  PostCommentsConnection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostCommentsConnection(
      pageInfo: fields[1] as PageInfo,
      edges: (fields[0] as List?)?.cast<PostCommentsConnectionEdge>(),
    );
  }

  @override
  void write(BinaryWriter writer, PostCommentsConnection obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.edges)
      ..writeByte(1)
      ..write(obj.pageInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostCommentsConnectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostCommentsConnectionEdgeAdapter
    extends TypeAdapter<PostCommentsConnectionEdge> {
  @override
  final int typeId = 15;

  @override
  PostCommentsConnectionEdge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostCommentsConnectionEdge(
      cursor: fields[0] as String,
      node: fields[1] as Comment,
    );
  }

  @override
  void write(BinaryWriter writer, PostCommentsConnectionEdge obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.cursor)
      ..writeByte(1)
      ..write(obj.node);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostCommentsConnectionEdgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostAttachmentAdapter extends TypeAdapter<PostAttachment> {
  @override
  final int typeId = 9;

  @override
  PostAttachment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostAttachment(
      fileHash: fields[0] as String,
      id: fields[1] as String,
      mimeType: fields[2] as String?,
      name: fields[3] as String,
      objectName: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PostAttachment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.fileHash)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.mimeType)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.objectName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostAttachmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
