import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String mediaUrl;
  final String imageUrl;
  final String tag;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.audioUrl = '',
    this.mediaUrl = '',
    this.imageUrl = '',
    required this.tag,
  });

  factory Song.fromFirestore(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? {};

    return Song(
      id: document.id,
      title: data['title']?.toString() ?? 'Tanpa Judul',
      artist: data['artist']?.toString() ?? 'Unknown Artist',
      audioUrl: data['audioUrl']?.toString() ?? '',
      mediaUrl: data['mediaUrl']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      tag: data['tag']?.toString() ?? 'Other',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'artist': artist,
      'audioUrl': audioUrl,
      'mediaUrl': mediaUrl,
      'imageUrl': imageUrl,
      'tag': tag,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Song && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

const List<String> categories = [
  'All',
  'Trending',
  'Popular',
  'Relax',
  'Synthwave',
];