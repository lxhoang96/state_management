import 'package:flutter/material.dart';

extension DateTimeParsing on String {
  /// Convert String format 'dd/MM/yyyy' to DateTime
  DateTime parseDateTimeDDMMYYYY() {
    final date = int.tryParse(substring(0, 2));
    final month = int.tryParse(substring(3, 5));
    final year = int.tryParse(substring(6, 10));
    assert(date == null || month == null || year == null, "Invalid date");
    if (date == null || month == null || year == null) {
      throw const FormatException("Invalid date");
    }
    return DateTime(year, month, date);
  }

  /// Convert String format 'yyyyMMddHHmm' to DateTime

  DateTime convertDateTimeTypeString() {
    int year = int.parse(substring(0, 4));
    int month = int.parse(substring(4, 6));
    int date = int.parse(substring(6, 8));
    int hour = int.parse(substring(8, 10));
    int min = int.parse(substring(10, 12));
    return DateTime(year, month, date, hour, min);
  }
}

extension DateTimeParsingDouble on double {
  /// Convert String format 'yyyyMMdd' to DateTime

  DateTime convertDateTimeTypeDouble() {
    String stringValue = toInt().toString();
    int year = int.parse(stringValue.substring(0, 4));
    int month = int.parse(stringValue.substring(4, 6));
    int date = int.parse(stringValue.substring(6, 8));

    return DateTime(year, month, date);
  }
}

extension StringParsing on DateTime {
  /// Convert DateTime to String format 'dd/MM'
  String formatDateDDMM() {
    return '$day/$month';
  }

  /// Convert DateTime to String format 'yyyyMMdd'

  String convertDatetoYYYYMMDD() {
    // String day = this.day.toString().padLeft(2, '0');
    // String month = this.month.toString().padLeft(2, '0');
    // int year = this.year;
    return '$year$month$day';
  }

  /// Convert DateTime to String format 'dd/MM/yyyy'

  String formatDateDDMMYYYY() {
    return '$day/$month/$year';
  }
}

extension StringParsingDouble on double {
  String convertStringTypeDouble() {
    String stringValue = toInt().toString();
    String year = stringValue.substring(0, 4);
    String month = stringValue.substring(4, 6);
    String date = stringValue.substring(6, 8);

    return "$year/$month/$date";
  }
}

extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (hour < other.hour) return -1;
    if (hour > other.hour) return 1;
    if (minute < other.minute) return -1;
    if (minute > other.minute) return 1;
    return 0;
  }
}
