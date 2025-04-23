import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_gate_app/database/database_interface.dart';

class LabStatsPage extends StatefulWidget {
  const LabStatsPage({super.key});

  @override
  State<LabStatsPage> createState() => _LabStatsPageState();
}

class _LabStatsPageState extends State<LabStatsPage> {
  List<Map<String, dynamic>> labUtilization = [];
  String selectedFilter = 'today';
  bool showPieChart = true;
  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> currentSessions = [];
  List<Map<String, dynamic>> batchStats = [];
  bool isLoadingBatch = false;
  String selectedLab = 'Lab 101';
  final List<String> labNames = ['Lab 101', 'Lab 102', 'Lab 202', 'Lab 203'];

  final blueShades = [
    Color(0xFF4F8DFD),
    Color(0xFF73A9FF),
    Color(0xFFA7C6FF),
    Color(0xFFCFE0FF),
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadCurrentSessions();
    _loadBatchStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final utilization =
          await databaseInterface.fetchLabUtilizationStats(selectedFilter);
      setState(() {
        labUtilization = utilization
            .where((lab) =>
                (lab['utilization_seconds'] != null) && (lab['lab'] != null))
            .toList();
      });
    } catch (e) {
      setState(() {
        errorMessage =
            "Failed to load data: ${e.toString().replaceAll('Exception: ', '')}";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentSessions() async {
    try {
      final sessions = await databaseInterface.LabSessionStats();
      setState(() {
        currentSessions = sessions;
      });
    } catch (e) {
      debugPrint("Failed to load current session data: $e");
    }
  }

  Future<void> _loadBatchStats() async {
    setState(() {
      isLoadingBatch = true;
    });
    try {
      final stats = await databaseInterface.fetchLabUtilPerBatch(selectedLab);
      setState(() {
        batchStats = stats;
      });
    } catch (e) {
      debugPrint("Failed to load batch stats: $e");
    } finally {
      setState(() {
        isLoadingBatch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Lab Utilization Monitor',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              showPieChart ? Icons.bar_chart : Icons.pie_chart,
              color: Colors.black87,
            ),
            onPressed: () {
              setState(() {
                showPieChart = !showPieChart;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Live usage statistics for all labs',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            _buildTopCards(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lab Utilization',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Colors.black87),
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.black87),
                    dropdownColor: Colors.white,
                    items: [
                      'today',
                      'last_week',
                      'last_month',
                      'last_year',
                      'all',
                    ].map((filter) {
                      return DropdownMenuItem<String>(
                        value: filter,
                        child: Text(filter.replaceAll('_', ' ').toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedFilter = value;
                        });
                        _loadStats();
                      }
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildContent(),
            ),
            const SizedBox(height: 32),
            const Text(
              'Batch Utilization',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedLab,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.black87),
                dropdownColor: Colors.white,
                items: [
                  "Lab 101",
                  "Lab 102",
                  "Lab 202",
                  "Lab 203",
                ].map((lab) {
                  //print(lab);
                  return DropdownMenuItem<String>(
                    value: lab,
                    child: Text(lab),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedLab = value;
                    });
                    _loadBatchStats();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildBatchChart(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCards() {
    final icons = [
      Icons.laptop_chromebook,
      Icons.laptop_mac,
      Icons.laptop_rounded,
      Icons.laptop_windows_sharp,
    ];
    _loadCurrentSessions();
    if (currentSessions.isEmpty) {
      return const Center(
        child: Text('No active students currently in labs'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        currentSessions.length.clamp(0, 4),
        (index) {
          final session = currentSessions[index];
          final labName = session['location_name'] ?? 'Lab ${index + 1}';
          final students = session['session_count'] ?? 0;

          return Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 1,
              color: const Color.fromARGB(255, 0, 13, 70),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  children: [
                    Icon(icons[index], size: 28, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      labName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$students students',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (labUtilization.isEmpty) {
      return const Center(
        child: Text(
          'No utilization data available',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: showPieChart ? _buildPieChart() : _buildBarChart(),
              ),
              const SizedBox(height: 16),
              _buildColorLegend(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    final totalSeconds = labUtilization.fold<double>(
        0, (sum, lab) => sum + (lab['utilization_seconds'] ?? 0).toDouble());

    return PieChart(
      PieChartData(
        sections: List.generate(labUtilization.length, (i) {
          final lab = labUtilization[i];
          final seconds = (lab['utilization_seconds'] ?? 0).toDouble();
          final percentage =
              totalSeconds > 0 ? (seconds / totalSeconds * 100) : 0;

          return PieChartSectionData(
            value: seconds,
            color: blueShades[i % blueShades.length],
            title: '${percentage.toStringAsFixed(0)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontStyle: FontStyle.italic,
            ),
          );
        }),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < labUtilization.length) {
                  final lab = labUtilization[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      lab['lab']?.toString() ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                return Text('${value.toInt()}h');
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: labUtilization.asMap().entries.map((entry) {
          final index = entry.key;
          final lab = entry.value;
          final hours = ((lab['utilization_hours'] ?? 0) as num).toDouble();

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: hours,
                color: blueShades[index % blueShades.length],
                width: 22,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBatchChart() {
    if (isLoadingBatch) {
      return const Center(child: CircularProgressIndicator());
    }
    if (batchStats.isEmpty) {
      return const Center(
        child: Text('No batch data available for selected lab'),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // Increased reserved space for vertical text
              getTitlesWidget: (value, meta) {
                if (value.toInt() < batchStats.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: RotatedBox(
                      quarterTurns: 3, // Rotate text 270 degrees (vertical)
                      child: Text(
                        batchStats[value.toInt()]['batch'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: batchStats.asMap().entries.map((entry) {
          final index = entry.key;
          final batch = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (batch['count'] ?? 0).toDouble(),
                color: blueShades[index % blueShades.length],
                width: 22,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorLegend() {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(labUtilization.length, (index) {
        final lab = labUtilization[index];
        final color = blueShades[index % blueShades.length];
        final labName = lab['lab'] ?? 'Lab ${index + 1}';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              labName.toString(),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        );
      }),
    );
  }
}
