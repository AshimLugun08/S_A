import 'dart:convert';

// 1. This is the Wrapper (The whole JSON)
class ScheduleResponse {
  bool? status;
  List<ScheduleItem>? data;

  ScheduleResponse({this.status, this.data});

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleResponse(
      status: json['status'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => ScheduleItem.fromJson(v)).toList()
          : null,
    );
  }
}

// 2. This is the individual Schedule Item
class ScheduleItem {
  int? id;
  String? day;
  List<String>? timeSlots;

  ScheduleItem({this.id, this.day, this.timeSlots});

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    var rawSlots = json['time_slots'];
    List<String> parsedSlots = [];

    // Ranchi Server Fix: Handles stringified JSON inside the list
    if (rawSlots != null && rawSlots is List && rawSlots.isNotEmpty) {
      String firstElement = rawSlots[0].toString().trim();
      if (firstElement.startsWith('[')) {
        try {
          var decoded = jsonDecode(firstElement);
          parsedSlots = List<String>.from(decoded);
        } catch (e) {
          parsedSlots = [firstElement];
        }
      } else {
        parsedSlots = List<String>.from(rawSlots.map((e) => e.toString()));
      }
    }

    return ScheduleItem(
      id: json['id'],
      day: json['day'],
      timeSlots: parsedSlots,
    );
  }
}