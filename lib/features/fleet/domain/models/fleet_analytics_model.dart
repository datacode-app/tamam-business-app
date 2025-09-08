class FleetAnalyticsModel {
  int? activeDrivers;
  int? totalOrdersToday;
  int? totalOrdersThisWeek;
  int? totalOrdersThisMonth;
  double? totalDistanceTraveled;
  double? avgDeliveryTime;
  String? fuelConsumption;
  String? onTimeDeliveryRate;

  FleetAnalyticsModel({
    this.activeDrivers,
    this.totalOrdersToday,
    this.totalOrdersThisWeek,
    this.totalOrdersThisMonth,
    this.totalDistanceTraveled,
    this.avgDeliveryTime,
    this.fuelConsumption,
    this.onTimeDeliveryRate,
  });

  factory FleetAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return FleetAnalyticsModel(
      activeDrivers: json['active_drivers'],
      totalOrdersToday: json['total_orders_today'],
      totalOrdersThisWeek: json['total_orders_this_week'],
      totalOrdersThisMonth: json['total_orders_this_month'],
      totalDistanceTraveled: json['total_distance_traveled']?.toDouble(),
      avgDeliveryTime: json['avg_delivery_time']?.toDouble(),
      fuelConsumption: json['fuel_consumption'],
      onTimeDeliveryRate: json['on_time_delivery_rate'],
    );
  }
}
