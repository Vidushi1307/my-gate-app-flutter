import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonutPieChart extends StatelessWidget {
  final List<LinearSales> seriesList;
  final bool? animate;

  const DonutPieChart(this.seriesList, {super.key, this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory DonutPieChart.withSampleData(List<LinearSales> data) {
    return DonutPieChart(data, animate: true);
  }

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: _createSampleData(seriesList),
        centerSpaceRadius: 50, // Donut hole size
        sectionsSpace: 0,
        startDegreeOffset: 0,
      ),
      swapAnimationDuration: const Duration(seconds: 2),
    );
  }

  static List<PieChartSectionData> _createSampleData(List<LinearSales> data) {
    return data.map((LinearSales sales) {
      return PieChartSectionData(
        value: sales.sales.toDouble(),
        title: '${sales.sales}', // Label inside the chart
        color: sales.colorval,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontFamily: 'Georgia',
        ),
      );
    }).toList();
  }
}

class LinearSales {
  final String sector_name;
  final int sales;
  final Color colorval;

  LinearSales(this.sector_name, this.sales, this.colorval);
}
