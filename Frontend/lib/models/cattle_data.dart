
class CattleData {
  final String cattleName;
  final String healthStatus;
  final String status;
  final String foodTypeMorning;
  final double feedingAmountKgMorning;
  final int scoreMorning;
  final String foodTypeNoon;
  final double feedingAmountKgNoon;
  final int scoreNoon;
  final String foodTypeEvening;
  final double feedingAmountKgEvening;
  final int scoreEvening;
  final String feedPlatform;
  final double travelDistancePerDayKm;
  final String farmerName;
  final String feedDate;
  final String id;

  CattleData({
    required this.cattleName,
    required this.healthStatus,
    required this.status,
    required this.foodTypeMorning,
    required this.feedingAmountKgMorning,
    required this.scoreMorning,
    required this.foodTypeNoon,
    required this.feedingAmountKgNoon,
    required this.scoreNoon,
    required this.foodTypeEvening,
    required this.feedingAmountKgEvening,
    required this.scoreEvening,
    required this.feedPlatform,
    required this.travelDistancePerDayKm,
    required this.farmerName,
    required this.feedDate,
    required this.id
  });

  factory CattleData.fromJson(Map<String, dynamic> json) {
    return CattleData(
      cattleName: json['cattle_name'],
      healthStatus: json['health_status'],
      status: json['status'],
      foodTypeMorning: json['food_type_morning'],
      feedingAmountKgMorning: json['feeding_amount_KG_morning'].toDouble(),
      scoreMorning: json['score_morning'],
      foodTypeNoon: json['food_type_noon'],
      feedingAmountKgNoon: json['feeding_amount_KG_noon'].toDouble(),
      scoreNoon: json['score_noon'],
      foodTypeEvening: json['food_type_evening'],
      feedingAmountKgEvening: json['feeding_amount_KG_evening'].toDouble(),
      scoreEvening: json['score_evening'],
      feedPlatform: json['feed_platform'],
      travelDistancePerDayKm: json['travel_distance_per_day_KM'].toDouble(),
      farmerName: json['farmer_name'],
      feedDate: json['feed_date'],
      id: json['id']
    );
  }
}