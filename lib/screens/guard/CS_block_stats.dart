import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_interface.dart';

class CSBlockChart extends StatefulWidget {
  const CSBlockChart({Key? key}) : super(key: key);

  @override
  _CSBlockChartState createState() => _CSBlockChartState();
}

class _CSBlockChartState extends State<CSBlockChart> {
  late Future<Map<String, dynamic>> _usageData;

  @override
  void initState() {
    super.initState();
    _usageData = databaseInterface.getCSBlockDailyUsage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _usageData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white70));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', 
              style: TextStyle(color: Colors.white70));
        } else if (!snapshot.hasData || snapshot.data!['days'] == null) {
          return Text('No data available', 
              style: TextStyle(color: Colors.white70));
        }

        final days = List<Map<String, dynamic>>.from(snapshot.data!['days']);
        days.sort((a, b) => a['date'].compareTo(b['date']));

        return Container(
          padding: const EdgeInsets.only(top: 12, bottom: 12),
          height: 160,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          days[value.toInt()]['day'],
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                    reservedSize: 24,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _calculateInterval(days),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Color.fromARGB(255, 65, 65, 67),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: days.asMap().entries.map((entry) {
                final idx = entry.key;
                final day = entry.value;
                return BarChartGroupData(
                  x: idx,
                  barRods: [
                    BarChartRodData(
                      toY: day['student_count'].toDouble(),
                      gradient: LinearGradient(
                        colors: [
                          // const Color.fromARGB(255, 31, 191, 231).withOpacity(0.8),
                          // const Color.fromARGB(255, 56, 100, 121).withOpacity(0.6),
                          Color(0xFFE6F4FF), // Very light blue (inner color)
                Color.fromARGB(255, 53, 147, 254),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: _calculateMaxY(days).toDouble(),
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  double _calculateMaxY(List<Map<String, dynamic>> days) {
    final maxCount = days.fold(0, (prev, day) => 
        day['student_count'] > prev ? day['student_count'] : prev);
    return maxCount * 1.2; // Add 20% padding
  }

  double _calculateInterval(List<Map<String, dynamic>> days) {
    final maxY = _calculateMaxY(days);
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    if (maxY <= 50) return 10;
    return 20;
  }
}