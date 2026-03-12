class IngredientModel {
  final String ingredientCode;
  final double quantity;
  final String unitOfMeasurement;

  IngredientModel({
    required this.ingredientCode,
    required this.quantity,
    required this.unitOfMeasurement,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      ingredientCode: json['ingredientCode'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitOfMeasurement: json['unitOfMeasurement'] as String,
    );
  }
}
