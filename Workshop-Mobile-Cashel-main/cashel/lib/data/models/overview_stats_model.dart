import 'package:flutter/material.dart';

class OverviewStatsModel {
  final String title;
  final String value;
  final String percentage;
  final bool isPositive;
  final IconData icon;

  OverviewStatsModel({
    required this.title,
    required this.value,
    required this.percentage,
    required this.isPositive,
    required this.icon,
  });
}