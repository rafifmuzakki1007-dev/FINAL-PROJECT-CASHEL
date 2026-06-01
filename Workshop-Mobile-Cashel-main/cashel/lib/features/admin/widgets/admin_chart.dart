import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/beranda_model.dart';

class AdminChart extends StatelessWidget {
  final List<ChartData> chartData;

  const AdminChart({super.key, required this.chartData});

  // Helper: format Rupiah singkat (contoh: 150000 → 150rb, 1500000 → 1,5jt)
  String _formatTooltip(double value) {
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}jt';
    } else if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp ${value.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const Center(
        child: Text('Belum ada data aktivitas', style: TextStyle(color: Colors.grey)),
      );
    }

    // Konversi ke FlSpot — satu titik per bulan (data sudah di-GROUP BY dari PHP)
    List<FlSpot> spots = chartData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    // Buat list label unik berdasarkan index — karena PHP sudah GROUP BY bulan,
    // setiap index pasti merupakan bulan yang berbeda
    // Kita hitung interval agar label tidak tumpang tindih
    final int labelInterval = chartData.length > 6 ? 2 : 1;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (chartData.length - 1).toDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1, // fl_chart akan panggil setiap integer
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                // Tampilkan hanya index yang valid dan sesuai interval
                if (value != value.toInt().toDouble()) return const SizedBox();
                if (index < 0 || index >= chartData.length) return const SizedBox();
                if (index % labelInterval != 0) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    chartData[index].month,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.black,
            barWidth: 2,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [Colors.blue.withOpacity(0.2), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final int index = spot.x.toInt();
                final String bulan = (index >= 0 && index < chartData.length)
                    ? chartData[index].month
                    : '';
                return LineTooltipItem(
                  '$bulan\n${_formatTooltip(spot.y)}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}