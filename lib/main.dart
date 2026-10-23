import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

Future<List<Photo>> fetchPhotos() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/photos'),
  );

  if (response.statusCode != HttpStatus.ok) {
    throw Exception('failed fetch photos');
  }

  return compute(parsePhotos, response.body);
}

List<Photo> parsePhotos(String responseBody) {
  final parsed = (jsonDecode(responseBody) as List<Object>)
      .cast<Map<String, Object>>();

  return parsed.map(Photo.fromJson).toList();
}

class Photo {
  final int identifier;
  final String thumbnailUrl;

  const new({required this.identifier, required this.thumbnailUrl});

  factory fromJson(Map<String, dynamic> json) {
    switch (json) {
      case {'id': int identifier, 'thumbnailUrl': String thumbnailUrl}:
        return Photo(identifier: identifier, thumbnailUrl: thumbnailUrl);

      default:
        throw const FormatException('failed to load photos');
    }
  }
}

class MainApp extends StatefulWidget {
  const new({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<List<Photo>> _photosFuture;

  @override
  void initState() {
    super.initState();

    _photosFuture = fetchPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
          future: _photosFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text(
                'An error has occurred!',
                style: TextStyle(color: Colors.red),
              );
            }

            if (snapshot.hasData) {
              return PhotosGrid(photos: snapshot.data!);
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class PhotosGrid extends StatelessWidget {
  final List<Photo> _photos;

  const new({super.key, required this._photos});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        return Image.network(_photos[index].thumbnailUrl);
      },
    );
  }
}
