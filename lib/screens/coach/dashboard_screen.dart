import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Filter options
  String selectedTimeRange = 'Week';
  final List<String> timeRanges = ['Week', 'Month', 'Year'];
  
  // Sample data structure
  List<RevenueData> revenueData = [];
  List<SubscriptionData> subscriptionData = [];
  
  // Stats data
  int totalTrainees = 1248;
  double monthlyRevenue = 12450;
  int activeSubs = 892;
  int totalPrograms = 15;
  
  @override
  void initState() {
    super.initState();
    loadSampleData();
  }
  
  void loadSampleData() {
    DateTime now = DateTime.now();
    
    // Load revenue data for the last 12 months (from current date)
    revenueData = [
      RevenueData(DateTime(now.year, now.month - 11, 15), 8500),
      RevenueData(DateTime(now.year, now.month - 10, 15), 9200),
      RevenueData(DateTime(now.year, now.month - 9, 15), 10100),
      RevenueData(DateTime(now.year, now.month - 8, 15), 10800),
      RevenueData(DateTime(now.year, now.month - 7, 15), 11500),
      RevenueData(DateTime(now.year, now.month - 6, 15), 12450),
      RevenueData(DateTime(now.year, now.month - 5, 15), 13100),
      RevenueData(DateTime(now.year, now.month - 4, 15), 13900),
      RevenueData(DateTime(now.year, now.month - 3, 15), 14500),
      RevenueData(DateTime(now.year, now.month - 2, 15), 15200),
      RevenueData(DateTime(now.year, now.month - 1, 15), 15800),
      RevenueData(DateTime(now.year, now.month, 15), 16500),
    ];
    
    // Load subscription data for the last 12 months
    subscriptionData = [
      SubscriptionData(DateTime(now.year, now.month - 11, 15), 450),
      SubscriptionData(DateTime(now.year, now.month - 10, 15), 480),
      SubscriptionData(DateTime(now.year, now.month - 9, 15), 520),
      SubscriptionData(DateTime(now.year, now.month - 8, 15), 580),
      SubscriptionData(DateTime(now.year, now.month - 7, 15), 640),
      SubscriptionData(DateTime(now.year, now.month - 6, 15), 720),
      SubscriptionData(DateTime(now.year, now.month - 5, 15), 780),
      SubscriptionData(DateTime(now.year, now.month - 4, 15), 810),
      SubscriptionData(DateTime(now.year, now.month - 3, 15), 840),
      SubscriptionData(DateTime(now.year, now.month - 2, 15), 860),
      SubscriptionData(DateTime(now.year, now.month - 1, 15), 880),
      SubscriptionData(DateTime(now.year, now.month, 15), 892),
    ];
  }
  
  // Get filtered data based on selected time range
  List<RevenueData> getFilteredRevenueData() {
    DateTime now = DateTime.now();
    DateTime filterDate;
    
    switch (selectedTimeRange) {
      case 'Week':
        filterDate = now.subtract(Duration(days: 7));
        break;
      case 'Month':
        filterDate = now.subtract(Duration(days: 30));
        break;
      case 'Year':
        filterDate = now.subtract(Duration(days: 365));
        break;
      default:
        filterDate = now.subtract(Duration(days: 30));
    }
    
    return revenueData.where((data) => data.date.isAfter(filterDate)).toList();
  }
  
  List<SubscriptionData> getFilteredSubscriptionData() {
    DateTime now = DateTime.now();
    DateTime filterDate;
    
    switch (selectedTimeRange) {
      case 'Week':
        filterDate = now.subtract(Duration(days: 7));
        break;
      case 'Month':
        filterDate = now.subtract(Duration(days: 30));
        break;
      case 'Year':
        filterDate = now.subtract(Duration(days: 365));
        break;
      default:
        filterDate = now.subtract(Duration(days: 30));
    }
    
    return subscriptionData.where((data) => data.date.isAfter(filterDate)).toList();
  }
  
  // Add new revenue data
  void addRevenueData(double amount) {
    setState(() {
      DateTime now = DateTime.now();
      revenueData.add(RevenueData(now, amount));
      monthlyRevenue = revenueData.last.amount;
      updateStats();
    });
  }
  
  // Add new subscription data
  void addSubscriptionData(int count) {
    setState(() {
      DateTime now = DateTime.now();
      subscriptionData.add(SubscriptionData(now, count));
      activeSubs = subscriptionData.last.count;
      updateStats();
    });
  }
  
  // Update stats based on latest data
  void updateStats() {
    totalTrainees = activeSubs + 356;
    totalPrograms = 15 + (subscriptionData.length - 12);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Coach Dashboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Welcome back, Coach Michael",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  FloatingActionButton.small(
                    onPressed: () => _showAddDataDialog(),
                    child: Icon(Icons.add),
                    backgroundColor: AppColors.primary,
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  statCard("Total Trainees", formatNumber(totalTrainees), getTraineeChange()),
                  statCard("Monthly Revenue", "\$${formatNumber(monthlyRevenue.toInt())}", getRevenueChange()),
                  statCard("Active Subs", formatNumber(activeSubs), getSubChange()),
                  statCard("Programs", formatNumber(totalPrograms), "+${totalPrograms - 12} New"),
                ],
              ),
              
              SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: timeRanges.map((range) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: ChoiceChip(
                            label: Text(range),
                            selected: selectedTimeRange == range,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  selectedTimeRange = range;
                                });
                              }
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.transparent,
                            labelStyle: TextStyle(
                              color: selectedTimeRange == range ? Colors.white : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              chartCard("Revenue Overview", buildLineChart()),
              SizedBox(height: 16),
              chartCard("Subscription Growth", buildBarChart()),
              
              SizedBox(height: 20),
              
              activityCard(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget buildLineChart() {
    List<RevenueData> filteredData = getFilteredRevenueData();
    
    // Show message if no data
    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No data available for selected period",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              "Click + button to add data",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }
    
    double minY = filteredData.map((e) => e.amount).reduce((a, b) => a < b ? a : b) * 0.9;
    double maxY = filteredData.map((e) => e.amount).reduce((a, b) => a > b ? a : b) * 1.1;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < filteredData.length) {
                  String label;
                  if (selectedTimeRange == 'Week') {
                    label = DateFormat('E').format(filteredData[index].date);
                  } else if (selectedTimeRange == 'Month') {
                    label = DateFormat('dd').format(filteredData[index].date);
                  } else {
                    label = DateFormat('MMM').format(filteredData[index].date);
                  }
                  return Text(
                    label,
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  );
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        minX: 0,
        maxX: filteredData.length.toDouble() - 1,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(filteredData.length, (index) {
              return FlSpot(index.toDouble(), filteredData[index].amount);
            }),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget buildBarChart() {
    List<SubscriptionData> filteredData = getFilteredSubscriptionData();
    
    // Show message if no data
    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No data available for selected period",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              "Click + button to add data",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }
    
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < filteredData.length) {
                  String label;
                  if (selectedTimeRange == 'Week') {
                    label = DateFormat('E').format(filteredData[index].date);
                  } else if (selectedTimeRange == 'Month') {
                    label = DateFormat('dd').format(filteredData[index].date);
                  } else {
                    label = DateFormat('MMM').format(filteredData[index].date);
                  }
                  return Text(
                    label,
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  );
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        barGroups: List.generate(filteredData.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: filteredData[index].count.toDouble(),
                color: AppColors.primary,
                width: 30,
                borderRadius: BorderRadius.circular(6),
              )
            ],
          );
        }),
      ),
    );
  }
  
  Widget statCard(String title, String value, String change) {
    bool isPositive = change.startsWith('+');
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
          Spacer(),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(change, 
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget chartCard(String title, Widget chart) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          SizedBox(height: 12),
          SizedBox(height: 250, child: chart),
        ],
      ),
    );
  }
  
  Widget activityCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recent Activity",
              style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          SizedBox(height: 12),
          activityItem("New subscriber joined", "2 hours ago"),
          activityItem("Payment received", "5 hours ago"),
          activityItem("New message from client", "1 day ago"),
          activityItem("Program 'Summer Challenge' reached 100 users", "2 days ago"),
          activityItem("New revenue record: \$16,500", "3 days ago"),
        ],
      ),
    );
  }
  
  Widget activityItem(String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(title, style: TextStyle(color: Colors.white)),
          ),
          Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
  
  void _showAddDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController revenueController = TextEditingController();
        TextEditingController subController = TextEditingController();
        
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text("Add New Data", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: revenueController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Revenue Amount",
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: subController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "New Subscribers",
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (revenueController.text.isNotEmpty) {
                  addRevenueData(double.parse(revenueController.text));
                }
                if (subController.text.isNotEmpty) {
                  addSubscriptionData(int.parse(subController.text));
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }
  
  String formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  
  String getTraineeChange() {
    double change = ((totalTrainees - 1248) / 1248) * 100;
    return change > 0 ? '+${change.toStringAsFixed(1)}%' : '${change.toStringAsFixed(1)}%';
  }
  
  String getRevenueChange() {
    double change = ((monthlyRevenue - 12450) / 12450) * 100;
    return change > 0 ? '+${change.toStringAsFixed(1)}%' : '${change.toStringAsFixed(1)}%';
  }
  
  String getSubChange() {
    int change = activeSubs - 892;
    return change > 0 ? '+$change' : '$change';
  }
}

// Data models
class RevenueData {
  final DateTime date;
  final double amount;
  
  RevenueData(this.date, this.amount);
}

class SubscriptionData {
  final DateTime date;
  final int count;
  
  SubscriptionData(this.date, this.count);
}