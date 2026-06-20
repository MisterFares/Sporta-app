import 'dart:convert';
import 'dart:io';

import 'package:fit/models/coach/performance_stats.dart';
import 'package:fit/models/coach/program_model.dart';
import 'package:fit/models/coach/tier_model.dart';
import 'package:fit/screens/coach_programs/program_section.dart';
import 'package:fit/screens/coach_programs/program_tiers.dart';
import 'package:fit/components/Widgets/build_dropdown_filter.dart';
import 'package:fit/components/Widgets/build_glowing_card.dart';
import 'package:fit/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/styles/colors.dart';
import 'package:path_provider/path_provider.dart';

class MyProgramsScreen2 extends StatefulWidget {
  const MyProgramsScreen2({super.key});

  @override
  State<MyProgramsScreen2> createState() => _MyProgramsScreen2State();
}

class _MyProgramsScreen2State extends State<MyProgramsScreen2> {
  String _selectedTierId = "bronze";
  String _chartFilter = 'Past 12 Months';
  List<TierDetailsData> _tiers = [];

  String? _existingImageUrl;

  TierDetailsData? _tierDetails;
  File? _selectedImage;
  bool _isUploading = false;

  bool _isLoadingDetails = false;
  bool _isLoadingTiers = true;
  String _selectedTimeframe = 'Past Week';

  bool _isModalOpen = false;
  String _modalMode = 'add';
  ProgramData? _currentEditProgram;

  PerformanceStats? _performanceStats;
  bool _isLoadingStats = false;
  String _errorMessage = '';

  String _formDescription = '';
  String _formFeatures = '';
  final TextEditingController _formFeaturesController = TextEditingController();

  // Form state
  final _formTitleController = TextEditingController();
  String _formServiceType = 'Workout + Nutrition';
  String _formDuration = '12 Weeks';
  String _formWorkoutDeliverables = '';
  String _formNutritionDeliverables = '';
  int _formBasePrice = 0;
  int _formDiscount = 0;
  String _formDiscountType = 'None';
  String _formExpirationDate = '';
  String _formStatus = 'Published';

  @override
  void initState() {
    super.initState();
    _fetchPerformanceStats();
    _loadTiers();
    _fetchTierDetails(); // Add this
  }

  TierDetailsData get _selectedTier {
    if (_tiers.isEmpty) {
      // Return a default tier while loading
      return TierDetailsData.fromJson({
        'id': _selectedTierId,
        'title': _selectedTierId,
      });
    }
    return _tiers.firstWhere((t) => t.id == _selectedTierId);
  }

  List<ProgramData> get _filteredPrograms {
    if (_tiers.isEmpty) return [];
    return _selectedTier.programs;
  }

  Future<void> _fetchPerformanceStats() async {
    setState(() {
      _isLoadingStats = true;
      _errorMessage = '';
    });

    try {
      final stats =
          await ApiService.getOverallPerformanceStats(); // Your API function
      setState(() {
        _performanceStats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _loadTiers() async {
    setState(() {
      _isLoadingTiers = true;
    });

    try {
      final bronze = await ApiService.getTierDetails('bronze');
      final silver = await ApiService.getTierDetails('silver');
      final gold = await ApiService.getTierDetails('gold');

      setState(() {
        _tiers = [bronze, silver, gold];
        _isLoadingTiers = false;
      });
    } catch (e) {
      print("Error loading tiers: $e");
      setState(() {
        _isLoadingTiers = false;
      });
    }
  }

  Future<void> _fetchTierDetails() async {
    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final details = await ApiService.getTierDetails(
        _selectedTierId,
        timeframe: _selectedTimeframe,
      );

      setState(() {
        _tierDetails = details;
        _isLoadingDetails = false;
      });
    } catch (e) {
      print("Error fetching tier details: $e");
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<File> _urlToFile(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final documentDirectory = await getTemporaryDirectory();
    final file = File('${documentDirectory.path}/temp_image.jpg');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  void _handleTogglePriority() async {
    final bool newActiveState = !_selectedTier.active;
    final String tierName = _selectedTierId;

    // Optimistically update UI
    setState(() {
      final index = _tiers.indexWhere((t) => t.id == tierName);
      if (index != -1) _tiers[index].active = newActiveState;
    });

    try {
      await ApiService.toggleTierActiveStatus(tierName, newActiveState);
      print("✅ Tier $tierName toggled successfully to $newActiveState");

      // Refresh tier data to confirm
      await _refreshCurrentTier();
    } catch (e) {
      print("❌ Failed to toggle tier: $e");

      // Revert UI on error
      setState(() {
        final index = _tiers.indexWhere((t) => t.id == tierName);
        if (index != -1) _tiers[index].active = !newActiveState;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update tier status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleAddFeature(String value) async {
    if (value.trim().isEmpty) return;

    final newFeatures = List<String>.from(_selectedTier.customFeatures)
      ..add(value.trim());

    // Optimistic update
    setState(() {
      final index = _tiers.indexWhere((t) => t.id == _selectedTierId);
      if (index != -1) _tiers[index].customFeatures.add(value.trim());
    });

    try {
      await ApiService.updateTierConfiguration(
        _selectedTierId,
        oneOnOneCallsOption: _mapOneOnOneCallToApi(_selectedTier.oneOnOneCall),
        emergencyAdjustmentsOption: _mapEmergencyToApi(
          _selectedTier.emergencyAdjustments,
        ),
        customFeatures: newFeatures,
      );
      await _refreshCurrentTier();
    } catch (e) {
      // Revert on error
      setState(() {
        final index = _tiers.indexWhere((t) => t.id == _selectedTierId);
        if (index != -1) {
          _tiers[index].customFeatures = newFeatures..removeLast();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add feature: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeFeature(int idx) async {
    final featureToRemove = _selectedTier.customFeatures[idx];
    final newFeatures = List<String>.from(_selectedTier.customFeatures)
      ..removeAt(idx);

    // Optimistic update
    setState(() {
      final index = _tiers.indexWhere((t) => t.id == _selectedTierId);
      if (index != -1) _tiers[index].customFeatures.removeAt(idx);
    });

    try {
      await ApiService.updateTierConfiguration(
        _selectedTierId,
        oneOnOneCallsOption: _mapOneOnOneCallToApi(_selectedTier.oneOnOneCall),
        emergencyAdjustmentsOption: _mapEmergencyToApi(
          _selectedTier.emergencyAdjustments,
        ),
        customFeatures: newFeatures,
      );
      await _refreshCurrentTier();
    } catch (e) {
      // Revert on error
      setState(() {
        final index = _tiers.indexWhere((t) => t.id == _selectedTierId);
        if (index != -1)
          _tiers[index].customFeatures.insert(idx, featureToRemove);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove feature: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openAddModal() {
    _modalMode = 'add';
    _formTitleController.clear();
    _formFeaturesController.clear();
    _formDescription = '';
    _formServiceType = 'Workout + Nutrition';
    _formDuration = '12';
    _formBasePrice = 0;
    _formDiscount = 0;
    _formDiscountType = 'None';
    _formExpirationDate = '';
    _formStatus = 'Published';
    _selectedImage = null;
    setState(() => _isModalOpen = true);
  }

  void _openEditModal(ProgramData prog) {
    _modalMode = 'edit';
    _currentEditProgram = prog;
    _formTitleController.text = prog.title;
    _formDescription = prog.description;
    _formServiceType = prog.serviceType;
    _formDuration = prog.durationInWeeks.toString();
    _formBasePrice = prog.basePrice.toInt();
    _formDiscount = prog.discount.toInt();
    _formDiscountType = prog.discountType ?? 'None';
    _formExpirationDate = prog.discountEndDate ?? '';
    _formStatus = prog.status;
    _selectedImage = null;
    _existingImageUrl = prog.thumbnailImage;

    // Use the decode method here
    _formFeaturesController.text = _decodeFeatures(prog.features);

    setState(() => _isModalOpen = true);
  }

  void _handleSaveProgram() async {
    // Validate required fields
    if (_formTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a program title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedImage == null && _modalMode == 'add') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a thumbnail image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Keep this here - only requires image for NEW programs
    if (_selectedImage == null && _modalMode == 'add') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a thumbnail image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Parse features from the features text field (one per line)
    final List<String> features = _formFeaturesController.text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    // If no features entered, use the old workout/nutrition deliverables
    if (features.isEmpty) {
      if (_formWorkoutDeliverables.isNotEmpty) {
        features.add('Workout: $_formWorkoutDeliverables');
      }
      if (_formNutritionDeliverables.isNotEmpty) {
        features.add('Nutrition: $_formNutritionDeliverables');
      }
    }

    // Format tier ID with proper capitalization
    String tierId;
    switch (_selectedTierId.toLowerCase()) {
      case 'bronze':
        tierId = 'Bronze';
        break;
      case 'silver':
        tierId = 'Silver';
        break;
      case 'gold':
        tierId = 'Gold';
        break;
      default:
        tierId = _selectedTierId;
    }

    // Parse duration to weeks
    int durationInWeeks =
        int.tryParse(_formDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 12;

    try {
      if (_modalMode == 'add') {
        // Create new program
        // Update existing program
        await ApiService.createProgram(
          // Change from updateProgram to createProgram
          tierId: tierId,
          title: _formTitleController.text.trim(),
          description: _formDescription,
          serviceType: _formServiceType,
          durationInWeeks: durationInWeeks,
          features: features,
          status: _formStatus,
          basePrice: _formBasePrice.toDouble(),
          discount: _formDiscount.toDouble(),
          discountType: _formDiscountType,
          discountEndDate:
              _formDiscountType == 'Limited' && _formExpirationDate.isNotEmpty
              ? _formExpirationDate
              : null,
          thumbnailImage: _selectedImage,
        );

        // Refresh programs from API to get the complete list
        await _fetchTierDetails();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Program created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        File? imageToSend = _selectedImage;

        // If no new image selected, download the existing image and send it as a file
        if (imageToSend == null && _existingImageUrl != null) {
          imageToSend = await _urlToFile(_existingImageUrl!);
        }

        await ApiService.updateProgram(
          _currentEditProgram!.id,
          tierId: tierId,
          title: _formTitleController.text.trim(),
          description: _formDescription,
          serviceType: _formServiceType,
          durationInWeeks: durationInWeeks,
          features: features,
          status: _formStatus,
          basePrice: _formBasePrice.toDouble(),
          discount: _formDiscount.toDouble(),
          discountType: _formDiscountType,
          discountEndDate:
              _formDiscountType == 'Limited' && _formExpirationDate.isNotEmpty
              ? _formExpirationDate
              : null,
          thumbnailImage: imageToSend,
        );

        await _fetchTierDetails();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Program updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Close modal and reset form
      setState(() {
        _isModalOpen = false;
        _selectedImage = null;
        _formFeaturesController.clear();
        _formTitleController.clear();
        _formDescription = '';
        _formWorkoutDeliverables = '';
        _formNutritionDeliverables = '';
      });
    } catch (e) {
      print("❌ Error saving program: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save program: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _deleteProgram(String id) async {
    try {
      await ApiService.deleteProgram(id);
      await _fetchTierDetails(); // Refresh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Program deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete program: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshCurrentTier() async {
    try {
      final updatedTier = await ApiService.getTierDetails(_selectedTierId);
      setState(() {
        final index = _tiers.indexWhere((t) => t.id == _selectedTierId);
        if (index != -1) {
          _tiers[index] = updatedTier;
        }
      });
    } catch (e) {
      print("Error refreshing tier: $e");
    }
  }

  String _mapOneOnOneCallToApi(String displayValue) {
    switch (displayValue) {
      case 'No Calls':
        return 'NoCalls';
      case '1 Welcome Call':
        return 'WelcomeCall';
      case 'Monthly Call (30m)':
        return 'MonthlyCall';
      case 'Bi-Weekly Call':
        return 'BiWeeklyCall';
      case 'Weekly Call':
        return 'WeeklyCall';
      default:
        return 'NoCalls';
    }
  }

  String _mapEmergencyToApi(String displayValue) {
    switch (displayValue) {
      case 'None':
        return 'None';
      case '1 Adjustment / month':
        return 'Limited';
      case '2 Adjustments / month':
        return 'Limited2';
      case 'Unlimited Flexibility':
        return 'Unlimited';
      default:
        return 'None';
    }
  }

  String _decodeFeatures(List<String> features) {
    if (features.isEmpty) return '';

    List<String> allFeatures = [];

    for (var feature in features) {
      try {
        // Decode the JSON string
        final decoded = jsonDecode(feature);
        if (decoded is List) {
          allFeatures.addAll(decoded.map((e) => e.toString()));
        } else {
          allFeatures.add(decoded.toString());
        }
      } catch (e) {
        // Not JSON, add as is
        allFeatures.add(feature);
      }
    }

    return allFeatures.join('\n');
  }

  @override
  void dispose() {
    _formTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(drawerIcon: Icons.menu, title: 'My Programs'),
      drawer: AppDrawer(selectedIndex: 2, role: 'trainer'),
      body: _isLoadingTiers
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildStatsRow(),
                      const SizedBox(height: 32),
                      buildTierSelector(_tiers, _selectedTierId, (tierId) {
                        setState(() => _selectedTierId = tierId);
                        _fetchTierDetails(); // Add this
                      }),
                      const SizedBox(height: 32),
                      buildTierActivationCard(
                        _selectedTier,
                        _handleTogglePriority,
                      ),
                      const SizedBox(height: 32),
                      buildTierConfigurationCard(_selectedTier, (
                        key,
                        value,
                      ) async {
                        print(
                          "🔧 Dropdown changed - Key: $key, New Value: $value",
                        );

                        // Store old values
                        final oldOneOnOneCall = _selectedTier.oneOnOneCall;
                        final oldEmergencyAdjustments =
                            _selectedTier.emergencyAdjustments;

                        // Optimistic update - UPDATE THE CORRECT FIELD
                        setState(() {
                          if (key == 'oneOnOneCall') {
                            _selectedTier.oneOnOneCall =
                                value; // value here should be the API value like 'MonthlyCall'
                          } else if (key == 'emergencyAdjustments') {
                            _selectedTier.emergencyAdjustments = value;
                          }
                        });

                        try {
                          // Map values to API format (but value should already be in API format)
                          String oneOnOneCallsOption =
                              _selectedTier.oneOnOneCall;
                          String emergencyAdjustmentsOption =
                              _selectedTier.emergencyAdjustments;

                          print(
                            "📤 Sending to API - oneOnOneCallsOption: $oneOnOneCallsOption",
                          );
                          print(
                            "📤 Sending to API - emergencyAdjustmentsOption: $emergencyAdjustmentsOption",
                          );

                          await ApiService.updateTierConfiguration(
                            _selectedTierId,
                            oneOnOneCallsOption: oneOnOneCallsOption,
                            emergencyAdjustmentsOption:
                                emergencyAdjustmentsOption,
                            customFeatures: _selectedTier.customFeatures,
                          );

                          print("✅ Tier configuration updated successfully");
                          await _refreshCurrentTier();
                        } catch (e) {
                          print("❌ Failed to update tier: $e");
                          // Revert UI on error
                          setState(() {
                            if (key == 'oneOnOneCall') {
                              _selectedTier.oneOnOneCall = oldOneOnOneCall;
                            } else if (key == 'emergencyAdjustments') {
                              _selectedTier.emergencyAdjustments =
                                  oldEmergencyAdjustments;
                            }
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to update configuration: $e',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }),
                      const SizedBox(height: 12),
                      buildCustomFeaturesCard(
                        _selectedTier,
                        (feature) => _handleAddFeature(feature),
                        (index) => _removeFeature(index),
                      ),
                      const SizedBox(height: 32),
                      buildProgramsSection(
                        _filteredPrograms,
                        _openAddModal,
                        (program) => _openEditModal(program),
                        (id) => _deleteProgram(id),
                      ),
                      _buildTierPerformanceCard(),
                      const SizedBox(height: 20),
                      _buildRevenueChartCard(),
                      Center(
                        child: Text(
                          'TrainerOS Premium Dashboard v2.4.1',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.cardTextSecondary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isModalOpen) _buildModal(),
              ],
            ),
    );
  }

  Widget _buildStatsRow() {
    if (_isLoadingStats) {
      return SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Error: $_errorMessage',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: buildGlowingCard(
            icon: LucideIcons.users,
            title: 'Active Clients',
            amount: _performanceStats?.activeClients ?? '0',
            subtitle: _performanceStats?.activeClientsTrend ?? '0%',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: buildGlowingCard(
            icon: LucideIcons.trendingUp,
            title: 'Growth',
            amount: _performanceStats?.growth.toString() ?? '0',
            subtitle: _performanceStats?.growthTrend ?? '0%',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: buildGlowingCard(
            icon: LucideIcons.shield,
            title: 'Retention',
            amount: _performanceStats?.retention ?? '0',
            subtitle: _performanceStats?.retentionTrend ?? '0%',
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTierPerformanceCard() {
    final stats = _tierDetails?.performanceStats;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tier Performance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time analytics for ${_selectedTier.title}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.cardTextSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.trendingUp,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildPerformanceStat(
                'Active Clients',
                stats?.activeClients ?? '0',
                stats?.activeClientsTrend ?? '0%',
                LucideIcons.users,
              ),
              const SizedBox(width: 16),
              _buildPerformanceStat(
                'Growth',
                stats?.growth.toString() ?? '0',
                stats?.growthTrend ?? '0%',
                LucideIcons.dollarSign,
              ),
              const SizedBox(width: 16),
              _buildPerformanceStat(
                'Retention',
                stats?.retention ?? '0',
                stats?.retentionTrend ?? '0%',
                LucideIcons.trendingUp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStat(
    String label,
    String value,
    String trend,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.3),
          border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.cardTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              trend,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChartCard() {
    // Get chart data from tier details
    final chartData = _tierDetails?.chartData ?? [];

    // Find max value for Y-axis
    double maxValue = 0;
    for (var data in chartData) {
      if (data.value > maxValue) maxValue = data.value;
    }
    // Add some padding to the top
    maxValue = maxValue * 1.2;
    if (maxValue == 0) maxValue = 10;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.primary, width: 0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Dynamics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Performance walkthrough',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.cardTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: buildFilterDropdown(
                  _chartFilter,
                  ['Past Week', 'Past Month', 'Past 12 Months'],
                  (v) => setState(() {
                    _chartFilter = v;
                    // Map dropdown value to API timeframe
                    switch (v) {
                      case 'Past Week':
                        _selectedTimeframe = 'Past Week';
                        break;
                      case 'Past Month':
                        _selectedTimeframe = 'Past Month';
                        break;
                      case 'Past 12 Months':
                        _selectedTimeframe = 'Past Year';
                        break;
                    }
                    _fetchTierDetails(); // Refresh when filter changes
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: chartData.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: AppColors.cardTextSecondary),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        drawHorizontalLine: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxValue / 5,
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.cardTextSecondary,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < chartData.length) {
                                return Text(
                                  chartData[value.toInt()].tickLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.cardTextSecondary,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: 0,
                      maxY: maxValue,
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.value);
                          }).toList(),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModal() {
    final finalPrice = (_formBasePrice * (1 - _formDiscount / 100)).round();

    return GestureDetector(
      onTap: () => setState(() => _isModalOpen = false),
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 600,
              constraints: const BoxConstraints(maxHeight: 700),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(32),
              ),
              child: _isUploading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            const SizedBox(height: 16),
                            Text(
                              'Uploading program...',
                              style: TextStyle(
                                color: AppColors.cardTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.cardBorder),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  LucideIcons.plus,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                _modalMode == 'add'
                                    ? 'Add New Program'
                                    : 'Edit Program',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _isModalOpen = false),
                                child: Icon(
                                  LucideIcons.x,
                                  size: 20,
                                  color: AppColors.cardTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Thumbnail Image Picker
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    height: 150,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBackground,
                                      border: Border.all(
                                        color: AppColors.cardBorder,
                                        width: 2,
                                        style: BorderStyle.solid,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: _selectedImage != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            child: Image.file(
                                              _selectedImage!,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : _existingImageUrl != null &&
                                              _modalMode == 'edit'
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            child: Image.network(
                                              _existingImageUrl!,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Icon(
                                                    LucideIcons.image,
                                                    size: 48,
                                                    color: AppColors
                                                        .cardTextSecondary,
                                                  ),
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                LucideIcons.image,
                                                size: 48,
                                                color:
                                                    AppColors.cardTextSecondary,
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                _modalMode == 'add'
                                                    ? 'Tap to select thumbnail image'
                                                    : 'Tap to change thumbnail image',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors
                                                      .cardTextSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              if (_modalMode == 'add')
                                                Text(
                                                  'Required for new programs',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors
                                                        .cardTextSecondary
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                            ],
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Program Title
                                _buildModalTextField(
                                  'Program Title *',
                                  _formTitleController,
                                  hint: 'e.g. 12 Week Shred',
                                ),
                                const SizedBox(height: 16),

                                // Description
                                _buildModalDescriptionField(
                                  'Description',
                                  _formDescription,
                                  (v) => _formDescription = v,
                                  hint: 'Describe what this program offers...',
                                ),
                                const SizedBox(height: 16),

                                // Service Type and Duration Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildModalDropdown(
                                        'Service Type',
                                        _formServiceType,
                                        [
                                          'Workout + Nutrition',
                                          'Workout Only',
                                          'Nutrition Only',
                                        ],
                                        (v) => setState(
                                          () => _formServiceType = v,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildModalTextField(
                                        'Duration (Weeks)',
                                        null,
                                        value: _formDuration,
                                        hint: 'e.g. 12',
                                        onChanged: (v) => _formDuration = v,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Publish Status
                                _buildModalDropdown(
                                  'Publish Status',
                                  _formStatus,
                                  ['Published', 'Draft'],
                                  (v) => setState(() => _formStatus = v),
                                ),
                                const SizedBox(height: 16),

                                // Features (Workout + Nutrition combined)
                                Text(
                                  'Program Features',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.cardTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  maxLines: 3,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                  onChanged: (v) => _formFeatures = v,
                                  controller: _formFeaturesController,
                                  decoration: InputDecoration(
                                    hintText:
                                        'List the key features of this program (one per line)...',
                                    hintStyle: TextStyle(
                                      color: AppColors.cardTextSecondary,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.cardBackground,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF232B28),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Pricing Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildModalNumberField(
                                        'Base Price (\$) *',
                                        _formBasePrice,
                                        (v) => _formBasePrice = v,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildModalNumberField(
                                        'Discount (%)',
                                        _formDiscount,
                                        (v) => _formDiscount = v,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF161B19,
                                          ).withOpacity(0.5),
                                          border: Border.all(
                                            color: AppColors.cardBorder,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Final Price',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    AppColors.cardTextSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '\$$finalPrice',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Discount Type and Expiration Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildModalDropdown(
                                        'Discount Type',
                                        _formDiscountType,
                                        ['None', 'Permanent', 'Limited'],
                                        (v) => setState(
                                          () => _formDiscountType = v,
                                        ),
                                      ),
                                    ),
                                    if (_formDiscountType == 'Limited') ...[
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildModalDateField(
                                          'Expiration Date',
                                          _formExpirationDate,
                                          (v) => _formExpirationDate = v,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0xFF232B28)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isModalOpen = false;
                                    _selectedImage = null;
                                    _existingImageUrl = null;
                                    _formFeaturesController.clear();
                                  });
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.cardTextSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: _handleSaveProgram,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _modalMode == 'add'
                                        ? 'Create Program'
                                        : 'Save Changes',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalDescriptionField(
    String label,
    String value,
    Function(String) onChanged, {
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.cardTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          maxLines: 3,
          style: TextStyle(color: AppColors.textPrimary),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.cardTextSecondary),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF232B28)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModalTextField(
    String label,
    TextEditingController? controller, {
    String? value,
    String? hint,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.cardTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? value : null,
          style: TextStyle(color: AppColors.textPrimary),
          onChanged: onChanged ?? (controller != null ? (v) {} : null),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.cardTextSecondary),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF232B28)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModalNumberField(
    String label,
    int value,
    Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.cardTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value.toString(),
          keyboardType: TextInputType.number,
          style: TextStyle(color: AppColors.textPrimary),
          onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF232B28)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModalDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    // Ensure value is not null and exists in options
    final String validValue = options.contains(value) ? value : options.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.cardTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: validValue, // Use validValue instead of value
          dropdownColor: AppColors.cardBackground,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF232B28)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: options
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }

  Widget _buildModalDateField(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.cardTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          style: TextStyle(color: AppColors.textPrimary),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'YYYY-MM-DD',
            hintStyle: TextStyle(color: AppColors.cardTextSecondary),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF232B28)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
