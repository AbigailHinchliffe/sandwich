import 'dart:convert';
import 'package:flutter/services.dart';

enum BreadType { white, wheat, multigrain, sourdough, wholemeal }

enum SandwichType {
  veggieDelight,
  chickenTeriyaki,
  tunaMelt,
  meatballMarinara,
}

class Sandwich {
  final SandwichType type;
  final bool isFootlong;
  final BreadType breadType;

  final String? id;
  final String? displayName;
  final String? description;
  final bool available;

  Sandwich({
    required this.type,
    required this.isFootlong,
    required this.breadType,
    this.id,
    this.displayName,
    this.description,
    this.available = true,
  });

  String get name {
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    switch (type) {
      case SandwichType.veggieDelight:
        return 'Veggie Delight';
      case SandwichType.chickenTeriyaki:
        return 'Chicken Teriyaki';
      case SandwichType.tunaMelt:
        return 'Tuna Melt';
      case SandwichType.meatballMarinara:
        return 'Meatball Marinara';
    }
  }

  String get image {
    final candidates = imageCandidates();
    return candidates.isNotEmpty ? candidates.first : 'assets/images/logo.png';
  }


  List<String> imageCandidates() {
    final String camel = type.name; // e.g. veggieDelight or chickenTeriyaki
    final String snake = _snakeCase(type.name); // e.g. veggie_delight
    final bool foot = isFootlong;

    final exts = ['.jpg', '.png', '.webp'];

    final List<String> candidates = [];

    if (foot) {
      for (final ext in exts) {
        candidates.add('assets/images/${camel}_footlong$ext');
      }
      for (final ext in exts) {
        candidates.add('assets/images/${camel}_footlong$ext');
      }
      for (final ext in exts) {
        candidates.add('assets/images/${snake}_footlong$ext');
      }
      for (final ext in exts) {
        candidates.add('assets/images/${camel}Footlong$ext');
      }
    } else {
      for (final ext in exts) {
        candidates.add('assets/images/${camel}SixInch$ext');
      }
      for (final ext in exts) {
        candidates.add('assets/images/${camel}_six_inch$ext');
      }
      for (final ext in exts) {
        candidates.add('assets/images/${snake}_six_inch$ext');
      }
      for (final ext in exts) {
        candidates.add('assets/images/${camel}_SixInch$ext');
      }
    }

    if (type == SandwichType.tunaMelt) {
      if (foot) {
        candidates.insertAll(
            0,
            [
              'assets/images/tuneMelt_footlong.webp',
              'assets/images/tuneMelt_footlong.jpg',
              'assets/images/tuneMelt_footlong.png',
            ]);
      } else {
        candidates.insertAll(
            0,
            [
              'assets/images/tuneMeltSixInch.webp',
              'assets/images/tuneMeltSixInch.jpg',
              'assets/images/tuneMeltSixInch.png',
            ]);
      }
    }

    final seen = <String>{};
    final unique = <String>[];
    for (final c in candidates) {
      if (!seen.contains(c)) {
        seen.add(c);
        unique.add(c);
      }
    }
    return unique;
  }

  factory Sandwich.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String? ?? '';
    final String name = json['name'] as String? ?? '';
    final String description = json['description'] as String? ?? '';
    final bool available = json['available'] as bool? ?? true;

    final SandwichType type = _typeFromId(id);

    return Sandwich(
      type: type,
      isFootlong: true,
      breadType: BreadType.white,
      id: id,
      displayName: name,
      description: description,
      available: available,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? type.name,
      'name': displayName ?? name,
      'description': description ?? '',
      'available': available,
    };
  }

  static Future<List<Sandwich>> loadFromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> parsed =
        json.decode(jsonString) as Map<String, dynamic>;
    final list = parsed['sandwiches'] as List<dynamic>? ?? [];
    return list
        .map((e) => Sandwich.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static SandwichType _typeFromId(String id) {
    switch (id) {
      case 'veggie_delight':
        return SandwichType.veggieDelight;
      case 'chicken_teriyaki':
        return SandwichType.chickenTeriyaki;
      case 'tuna_melt':
        return SandwichType.tunaMelt;
      case 'meatball_marinara':
        return SandwichType.meatballMarinara;
      default:
        for (final t in SandwichType.values) {
          if (t.name == id || _snakeCase(t.name) == id) return t;
        }
        return SandwichType.veggieDelight;
    }
  }

  static String _snakeCase(String input) {
    return input.replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}').toLowerCase();
  }
}