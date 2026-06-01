import 'package:flutter/material.dart';
import '../models/overview_stats_model.dart';

class OverviewServices {
  static List<OverviewStatsModel> getOverviewStats() {
    return [
      OverviewStatsModel(
        title: "Tayangan",
        value: "7,265",
        percentage: "+12,08%",
        isPositive: true,
        icon: Icons.trending_up,
      ),
      OverviewStatsModel(
        title: "Pengunjung",
        value: "3,451",
        percentage: "-0,83%",
        isPositive: false,
        icon: Icons.person_outline,
      ),
      OverviewStatsModel(
        title: "Pengguna Baru",
        value: "251",
        percentage: "+17,52%",
        isPositive: true,
        icon: Icons.group_add_outlined,
      ),
      OverviewStatsModel(
        title: "Pengguna Aktif",
        value: "7,265",
        percentage: "+23,12%",
        isPositive: true,
        icon: Icons.bolt,
      ),
    ];
  }
}