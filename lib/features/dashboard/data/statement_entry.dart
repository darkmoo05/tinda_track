import 'package:flutter/material.dart';

class StatementEntry {
  final String date;
  final DateTime createdAt;
  final String type;
  final String amount;
  final Color amountColor;
  final String? note;

  StatementEntry({
    required this.date,
    required this.createdAt,
    required this.type,
    required this.amount,
    required this.amountColor,
    this.note,
  });
}
