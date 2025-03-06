import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  final List<OrdinalSales> data;
  final bool? animate;

  const SimpleBarChart(this.data, {super.key, this.animate});

  /// Creates a Bar Chart with sample data
  factory SimpleBarChart.withSampleData(var data) {
    return SimpleBarChart(
      _createSampleData(data),
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.0,
      child: BarChart(
        BarChartData(
          barGroups: _getBarGroups(),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    data[value.toInt()].year,
                    style: const TextStyle(fontSize: 12),
                  );
                },
                reservedSize: 30,
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          barTouchData: BarTouchData(enabled: true),
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index].sales.toDouble(),
            color: Colors.blue,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  static List<OrdinalSales> _createSampleData(var data) {
    return List<OrdinalSales>.from(
        data.map((d) => OrdinalSales(d['year'], d['sales'])));
  }
}

class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
