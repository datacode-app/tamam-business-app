class DeliveryManScheduleModel {
  int? id;
  int? deliveryManId;
  int? day;
  String? startTime;
  String? endTime;

  DeliveryManScheduleModel({
    this.id,
    this.deliveryManId,
    this.day,
    this.startTime,
    this.endTime,
  });

  DeliveryManScheduleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deliveryManId = json['delivery_man_id'];
    day = json['day_of_week'];
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['delivery_man_id'] = deliveryManId;
    data['day_of_week'] = day;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    return data;
  }
}
