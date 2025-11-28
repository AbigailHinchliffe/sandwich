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
  // core selection-related fields (used throughout the UI)
  final SandwichType type;
  final bool isFootlong;
  final BreadType breadType;

  // additional data loaded from JSON / menu
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

  // keep existing name logic but prefer the provided displayName when available
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

  /// Preferred default image path (a likely match for your current files).
  /// This returns the first candidate (so existing code using Sandwich.image
  /// will get a useful default). For robust loading, prefer using
  /// Sandwich.imageCandidates() + rootBundle.load() in the UI to pick the
  /// first actually existing asset.
  String get image {
    final candidates = imageCandidates();
    return candidates.isNotEmpty ? candidates.first : 'assets/images/logo.png';
  }

  /// Returns a list of candidate asset paths to try (ordered preference).
  /// Covers camelCase and snake_case filenames, common extensions, and the
  /// SixInch / _footlong naming variants present in your assets folder.
  List<String> imageCandidates() {
    final String camel = type.name; // e.g. veggieDelight or chickenTeriyaki
    final String snake = _snakeCase(type.name); // e.g. veggie_delight
    final bool foot = isFootlong;

    final exts = ['.jpg', '.png', '.webp'];

    final List<String> candidates = [];

    if (foot) {
      // common: camelCase_footlong.jpg (matches your screenshot)
      for (final ext in exts) {
        candidates.add('assets/images/${camel}_footlong$ext');
      }
      // some files might be camelCase_footlong.png etc.
      for (final ext in exts) {
        candidates.add('assets/images/${camel}_footlong$ext');
      }
      // snake_case_footlong
      for (final ext in exts) {
        candidates.add('assets/images/${snake}_footlong$ext');
      }
      // fallback: camelCaseFootlong (no underscore)
      for (final ext in exts) {
        candidates.add('assets/images/${camel}Footlong$ext');
      }
    } else {
      // six-inch variants in your folder: camelCaseSixInch.jpg
      for (final ext in exts) {
        candidates.add('assets/images/${camel}SixInch$ext');
      }
      // alternate: camelCase_six_inch
      for (final ext in exts) {
        candidates.add('assets/images/${camel}_six_inch$ext');
      }
      // snake_case_six_inch
      for (final ext in exts) {
        candidates.add('assets/images/${snake}_six_inch$ext');
      }
      // fallback: camelCaseSixInch with underscore before size
      for (final ext in exts) {
        candidates.add('assets/images/${camel}_SixInch$ext');
      }
    }

    // Special-case: your tuna images use "tuneMelt" in filenames per screenshot.
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

    // Deduplicate while preserving order
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

  // factory to create a Sandwich menu item from JSON
  factory Sandwich.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String? ?? '';
    final String name = json['name'] as String? ?? '';
    final String description = json['description'] as String? ?? '';
    final bool available = json['available'] as bool? ?? true;

    final SandwichType type = _typeFromId(id);

    // create a Sandwich with defaults for selection-specific fields
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

  // load a list of Sandwich objects from a JSON asset (e.g. assets/sandwiches.json)
  static Future<List<Sandwich>> loadFromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> parsed =
        json.decode(jsonString) as Map<String, dynamic>;
    final list = parsed['sandwiches'] as List<dynamic>? ?? [];
    return list
        .map((e) => Sandwich.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // helper: map id strings from JSON to enum values
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
        // fallback: try to parse camelCase enum name or return default
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