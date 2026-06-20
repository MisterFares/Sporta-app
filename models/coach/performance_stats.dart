class PerformanceStats {
  final String activeClients;
  final String activeClientsTrend;
  final int growth;
  final String growthTrend;
  final String retention;
  final String retentionTrend;

  PerformanceStats({
    required this.activeClients,
    required this.activeClientsTrend,
    required this.growth,
    required this.growthTrend,
    required this.retention,
    required this.retentionTrend,
  });

  factory PerformanceStats.fromJson(Map<String, dynamic> json) {
    return PerformanceStats(
      activeClients: json['activeClients']?.toString() ?? '0',
      activeClientsTrend: json['activeClientsTrend']?.toString() ?? '0%',
      growth: (json['growth'] as num?)?.toInt() ?? 0,
      growthTrend: json['growthTrend']?.toString() ?? '0%',
      retention: json['retention']?.toString() ?? '0',
      retentionTrend: json['retentionTrend']?.toString() ?? '0%',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeClients': activeClients,
      'activeClientsTrend': activeClientsTrend,
      'growth': growth,
      'growthTrend': growthTrend,
      'retention': retention,
      'retentionTrend': retentionTrend,
    };
  }
}