// screens/coach/my_trainees_screen.dart
// ignore_for_file: deprecated_member_use
import 'package:fit/classes/day_diet.dart';
import 'package:fit/classes/exercise.dart';
import 'package:fit/classes/meal.dart';
import 'package:fit/classes/trainees.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/components/Widgets/header.dart';
import 'package:fit/components/Widgets/input.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:flutter/material.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/styles/colors.dart';

class MyTraineesScreen extends StatefulWidget {
  const MyTraineesScreen({super.key});

  @override
  State<MyTraineesScreen> createState() => _MyTraineesScreenState();
}

class _MyTraineesScreenState extends State<MyTraineesScreen> {
  List<Trainee> _newTrainees = [];
  List<Trainee> _currentTrainees = [];

  String _selectedSubscription = 'all';
  String _selectedStatus = 'all';

  // Assignment state
  bool _isAssignModalOpen = false;
  int _currentStep = 1;
  Trainee? _selectedTrainee;
  String _assignmentType = 'custom';

  // Workout plan
  String _splitType = 'Full Body';
  List<Exercise> _exercises = [];

  // Diet plan
  List<DayDiet> _dietDays = List.generate(5, (index) => DayDiet(meals: []));

  // View modal state
  Trainee? _viewingTrainee;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    _newTrainees = [
      Trainee(
        id: 1,
        name: "John Doe",
        email: "john@email.com",
        level: "Intermediate",
        weight: "82kg",
        subscription: "Gold",
        status: "New",
        avatar:
            "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100&auto=format&fit=crop",
        joinedDate: "2024-03-15",
        paymentStatus: "Paid",
      ),
      Trainee(
        id: 2,
        name: "Sarah Williams",
        email: "sarah@email.com",
        level: "Beginner",
        weight: "68kg",
        subscription: "Free",
        status: "New",
        avatar:
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=100&auto=format&fit=crop",
        joinedDate: "2024-03-10",
        paymentStatus: "Paid",
      ),
      Trainee(
        id: 3,
        name: "Alex Johnson",
        email: "alex@email.com",
        level: "Advanced",
        weight: "95kg",
        subscription: "Platinum",
        status: "New",
        avatar:
            "https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=100&auto=format&fit=crop",
        joinedDate: "2024-03-12",
        paymentStatus: "Paid",
      ),
    ];

    _currentTrainees = [
      Trainee(
        id: 4,
        name: "Emily Davis",
        email: "emily@email.com",
        level: "Intermediate",
        weight: "58kg",
        subscription: "Gold",
        status: "Current",
        avatar:
            "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=100&auto=format&fit=crop",
        startDate: "2024-02-01",
        assignedProgram: "Hypertrophy Master",
      ),
    ];
  }

  List<Trainee> get _filteredNewTrainees {
    return _newTrainees.where((t) {
      if (_selectedSubscription != 'all' &&
          t.subscription != _selectedSubscription) {
        return false;
      }
      if (_selectedStatus != 'all' && _selectedStatus != 'New') return false;
      return true;
    }).toList();
  }

  List<Trainee> get _filteredCurrentTrainees {
    return _currentTrainees.where((t) {
      if (_selectedSubscription != 'all' &&
          t.subscription != _selectedSubscription) {
        return false;
      }
      if (_selectedStatus != 'all' && _selectedStatus != 'Current') {
        return false;
      }
      return true;
    }).toList();
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.red : AppColors.greeen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openAssignModal(Trainee trainee) {
    setState(() {
      _selectedTrainee = trainee;
      _currentStep = 1;
      _assignmentType = 'custom';
      _exercises = [];
      _splitType = 'Full Body';
      _dietDays = List.generate(5, (index) => DayDiet(meals: []));
      _isAssignModalOpen = true;
    });
  }

  void _closeAssignModal() {
    setState(() {
      _isAssignModalOpen = false;
      _selectedTrainee = null;
      _currentStep = 1;
    });
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      _currentStep--;
    });
  }

  void _addExercise() {
    setState(() {
      _exercises.add(Exercise(name: '', sets: '', reps: '', rest: ''));
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _addMeal(int dayIndex) {
    setState(() {
      _dietDays[dayIndex].meals.add(Meal(name: '', calories: '', notes: ''));
    });
  }

  void _removeMeal(int dayIndex, int mealIndex) {
    setState(() {
      _dietDays[dayIndex].meals.removeAt(mealIndex);
    });
  }

  void _saveWorkoutStep() {
    setState(() {
      _currentStep = 3;
    });
  }

  void _activatePlan() {
    if (_selectedTrainee != null) {
      setState(() {
        // Move trainee from new to current
        _newTrainees.removeWhere((t) => t.id == _selectedTrainee!.id);
        _currentTrainees.add(
          Trainee(
            id: _selectedTrainee!.id,
            name: _selectedTrainee!.name,
            email: _selectedTrainee!.email,
            level: _selectedTrainee!.level,
            weight: _selectedTrainee!.weight,
            subscription: _selectedTrainee!.subscription,
            status: 'Current',
            avatar: _selectedTrainee!.avatar,
            startDate: DateTime.now().toIso8601String().split('T')[0],
            assignedProgram: 'Custom Plan',
            paymentStatus: _selectedTrainee!.paymentStatus,
          ),
        );
      });
      _showToast('Program assigned to ${_selectedTrainee!.name}');
      _closeAssignModal();
    }
  }

  void _openViewModal(Trainee trainee) {
    setState(() {
      _viewingTrainee = trainee;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trainee Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', _viewingTrainee?.name ?? ''),
              const SizedBox(height: 12),
              _buildDetailRow('Level', _viewingTrainee?.level ?? ''),
              const SizedBox(height: 12),
              _buildDetailRow('Weight', _viewingTrainee?.weight ?? ''),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Subscription',
                _viewingTrainee?.subscription ?? '',
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Plan Status', 'Assigned'),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Start Date',
                _viewingTrainee?.startDate ?? 'N/A',
              ),
              const Divider(color: AppColors.cardBorder, height: 24),
              const Text(
                'Workout Plan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Split Type: Full Body',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Exercises: Bench Press (4x8-10), Squat (4x6-8), Rows (3x10-12)',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Diet Plan (5 Days)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Breakfast: Oatmeal (550 kcal)',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const Text(
                'Lunch: Chicken & Rice (650 kcal)',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const Text(
                'Dinner: Salmon & Veggies (700 kcal)',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openAssignModal(trainee);
            },
            child: const Text(
              'Edit Plan',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('Message sent to ${trainee.name}');
            },
            child: const Text(
              'Send Message',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'My Trainees'),
      drawer: AppDrawer(selectedIndex: 1, role: 'coach'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                pageHeader(
                  'Manage your athletes and assign personalized programs',
                ),
                const SizedBox(height: 24),

                // Filters
                Row(
                  children: [
                    _buildFilterDropdown(
                      value: _selectedSubscription,
                      items: const ['all', 'Free', 'Gold', 'Platinum'],
                      onChanged: (value) {
                        setState(() {
                          _selectedSubscription = value;
                        });
                      },
                      label: 'All Subscriptions',
                    ),
                    const SizedBox(width: 12),
                    _buildFilterDropdown(
                      value: _selectedStatus,
                      items: const ['all', 'New', 'Current'],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                      label: 'All Status',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // New Trainees Section
                Row(
                  children: [
                    Icon(
                      Icons.person_add_alt,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'New Trainees (Awaiting Program Assignment)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTraineesGrid(_filteredNewTrainees, isNew: true),
                const SizedBox(height: 32),

                // Current Trainees Section
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Current Trainees (Active Plan Assigned)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTraineesGrid(_filteredCurrentTrainees, isNew: false),
              ],
            ),
          ),

          // Assignment Modal
          if (_isAssignModalOpen) _buildAssignmentModal(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required Function(String) onChanged,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item == 'all' ? label : item,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondary,
          ),
          dropdownColor: AppColors.cardBackground,
        ),
      ),
    );
  }

  Widget _buildTraineesGrid(List<Trainee> trainees, {required bool isNew}) {
    if (trainees.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'No trainees found',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trainees.length,
      itemBuilder: (context, index) {
        final trainee = trainees[index];
        return Column(
          children: [
            _buildTraineeCard(trainee, isNew: isNew),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildTraineeCard(Trainee trainee, {required bool isNew}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: const Border(
                bottom: BorderSide(color: AppColors.cardBorder),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(trainee.avatar),
                  backgroundColor: AppColors.cardBorder,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainee.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trainee.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow('Level', trainee.level),
                const SizedBox(height: 8),
                _buildInfoRow('Weight', trainee.weight),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Subscription',
                  trainee.subscription,
                  isBadge: true,
                ),
                if (isNew) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Payment Status',
                    trainee.paymentStatus ?? 'Paid',
                    isBadge: true,
                    badgeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Joined', trainee.joinedDate ?? 'N/A'),
                ] else ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Plan Status',
                    'Assigned',
                    isBadge: true,
                    badgeColor: AppColors.greeen,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Start Date', trainee.startDate ?? 'N/A'),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: isNew
                      ? buildButton(
                          'Assign Program',
                          null,
                          () => _openAssignModal(trainee),
                          true,
                        )
                      : buildButton(
                          'View Details',
                          null,
                          () => _openViewModal(trainee),
                          false,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBadge = false,
    Color? badgeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        if (isBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (badgeColor ?? AppColors.primary).withOpacity(0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badgeColor ?? AppColors.primary,
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildAssignmentModal() {
    return GestureDetector(
      onTap: _closeAssignModal,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _currentStep == 1
                              ? 'Assign Program to ${_selectedTrainee?.name ?? ''}'
                              : _currentStep == 2
                              ? 'Workout Plan Configuration'
                              : 'Diet Plan Configuration (5 Days)',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: _closeAssignModal,
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _currentStep == 1
                          ? _buildStep1Content()
                          : _currentStep == 2
                          ? _buildStep2Content()
                          : _buildStep3Content(),
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_currentStep > 1)
                          TextButton(
                            onPressed: _prevStep,
                            child: const Text(
                              'Back',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        const SizedBox(width: 12),
                        if (_currentStep < 3)
                          ElevatedButton(
                            onPressed: _currentStep == 2
                                ? _saveWorkoutStep
                                : _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Next'),
                          )
                        else
                          ElevatedButton(
                            onPressed: _activatePlan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Save & Activate'),
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

  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1: Select Assignment Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRadioOption(
                value: 'custom',
                groupValue: _assignmentType,
                onChanged: (value) => setState(() => _assignmentType = value),
                label: 'Create Custom Plan',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRadioOption(
                value: 'template',
                groupValue: _assignmentType,
                onChanged: (value) => setState(() => _assignmentType = value),
                label: 'Load Template and Modify',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String groupValue,
    required Function(String) onChanged,
    required String label,
  }) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: value == groupValue
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: value == groupValue
                ? AppColors.primary
                : AppColors.cardBorder,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              value == groupValue
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 16,
              color: value == groupValue
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: value == groupValue
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Split Type
        const Text(
          'Split Type',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _splitType,
              items: const ['Full Body', 'Upper-Lower', 'Bro Split'].map((
                type,
              ) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _splitType = value!),
              dropdownColor: AppColors.cardBackground,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Exercises
        const Text(
          'Exercises',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ..._exercises.asMap().entries.map((entry) {
          int index = entry.key;
          Exercise exercise = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _exercises[index].name = value),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Exercise',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.cardBorder,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _exercises[index].sets = value),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Sets',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.cardBorder,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _exercises[index].reps = value),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Reps',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.cardBorder,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _exercises[index].rest = value),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Rest',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.cardBorder,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeExercise(index),
                  icon: const Icon(Icons.delete_outline, color: AppColors.red),
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: _addExercise,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Exercise'),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildStep3Content() {
    return Column(
      children: List.generate(5, (dayIndex) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day ${dayIndex + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ..._dietDays[dayIndex].meals.asMap().entries.map((mealEntry) {
                int mealIndex = mealEntry.key;
                Meal meal = mealEntry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      buildInput(
                        'Meal Name',
                        null,
                        onChanged: (value) => setState(
                          () =>
                              _dietDays[dayIndex].meals[mealIndex].name = value,
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildInput(
                        'Calories',
                        null,
                        onChanged: (value) => setState(
                          () => _dietDays[dayIndex].meals[mealIndex].calories =
                              value,
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildInput(
                        'Notes',
                        null,
                        onChanged: (value) => setState(
                          () => _dietDays[dayIndex].meals[mealIndex].notes =
                              value,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _removeMeal(dayIndex, mealIndex),
                          child: const Text(
                            'Remove',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () => _addMeal(dayIndex),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Add Meal'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
        );
      }),
    );
  }
}
