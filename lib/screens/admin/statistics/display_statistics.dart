import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff1976d2),
            bottom: const TabBar(
              indicatorColor: Color(0xff9962D0),
              tabs: [
                Tab(icon: Icon(Icons.bar_chart)),
                Tab(icon: Icon(Icons.pie_chart)),
                Tab(icon: Icon(Icons.show_chart)),
              ],
            ),
            title: const Text('Flutter Charts'),
          ),
          body: TabBarView(
            children: [
              _buildBarChart(),
              _buildPieChart(),
              _buildLineChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(
                x: 0, barRods: [BarChartRodData(toY: 30, color: Colors.red)]),
            BarChartGroupData(
                x: 1, barRods: [BarChartRodData(toY: 40, color: Colors.green)]),
            BarChartGroupData(
                x: 2, barRods: [BarChartRodData(toY: 10, color: Colors.blue)]),
          ],
          titlesData: FlTitlesData(show: true),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 35.8, color: Colors.blue, title: 'Work'),
          PieChartSectionData(value: 8.3, color: Colors.purple, title: 'Eat'),
          PieChartSectionData(
              value: 10.8, color: Colors.green, title: 'Commute'),
          PieChartSectionData(value: 15.6, color: Colors.yellow, title: 'TV'),
          PieChartSectionData(
              value: 19.2, color: Colors.orange, title: 'Sleep'),
          PieChartSectionData(value: 10.3, color: Colors.red, title: 'Other'),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 45),
              const FlSpot(1, 56),
              const FlSpot(2, 55),
              const FlSpot(3, 60),
              const FlSpot(4, 61),
              const FlSpot(5, 70),
            ],
            isCurved: true,
            barWidth: 4,
            isStrokeCapRound: true,
          ),
        ],
        titlesData: FlTitlesData(show: true),
      ),
    );
  }
}
