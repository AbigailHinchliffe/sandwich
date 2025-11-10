class PricingRepository {
  double calculatePrice({required int quantity, required bool isFootlong}) {
    final double pricePerItem = isFootlong ? 11.00 : 7.00;
    return quantity * pricePerItem;
  }
}