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

  Sandwich({
    required this.type,
    required this.isFootlong,
    required this.breadType,
  });

  String get name {
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
    switch (type) {
      case SandwichType.veggieDelight:
        return isFootlong
            ? 'assets/images/veggieDelight_footlong.jpg'
            : 'assets/images/veggieDelightSixInch.jpg';
      case SandwichType.chickenTeriyaki:
        return isFootlong
            ? 'assets/images/chickenTeriyaki_footlong.jpg'
            : 'assets/images/chickenTeriyakiSixInch.jpg';
      case SandwichType.tunaMelt:
        return isFootlong
            ? 'assets/images/tuneMelt_footlong.webp'
            : 'assets/images/tuneMeltSixInch.webp';
      case SandwichType.meatballMarinara:
        return isFootlong
            ? 'assets/images/meatballMarinara_footlong.jpg'
            : 'assets/images/meatballMarinaraSixInch.jpg';
    }
  }
}