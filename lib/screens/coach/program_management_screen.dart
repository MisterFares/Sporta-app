// screens/coach/program_management_screen.dart
import 'package:fit/classes/program_template.dart';
import 'package:fit/classes/subs_plan.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/components/Widgets/header.dart';
import 'package:fit/lists/data/program_templates.dart';
import 'package:fit/lists/data/subs_plan.dart';
import 'package:flutter/material.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/styles/colors.dart';

class ProgramManagementScreen extends StatefulWidget {
  const ProgramManagementScreen({super.key});

  @override
  State<ProgramManagementScreen> createState() =>
      _ProgramManagementScreenState();
}

class _ProgramManagementScreenState extends State<ProgramManagementScreen> {
  int _selectedSection = 0; // 0 = Subscription Plans, 1 = Program Templates

  // Plan modal state
  bool _isPlanModalOpen = false;
  bool _isEditingPlan = false;
  int? _editingPlanId;
  final TextEditingController _planNameController = TextEditingController();
  final TextEditingController _planPriceController = TextEditingController();
  final TextEditingController _planDurationController = TextEditingController();
  final TextEditingController _planDescriptionController =
      TextEditingController();
  final List<TextEditingController> _featureControllers = [];

  // Template modal state
  bool _isTemplateModalOpen = false;
  bool _isEditingTemplate = false;
  int? _editingTemplateId;
  final TextEditingController _templateNameController = TextEditingController();
  final TextEditingController _templateDietController = TextEditingController();
  final TextEditingController _templateWorkoutController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
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

  // ========== SUBSCRIPTION PLAN METHODS ==========
  void _openPlanModal({SubscriptionPlan? plan}) {
    _isEditingPlan = plan != null;
    _editingPlanId = plan?.id;

    if (plan != null) {
      _planNameController.text = plan.name;
      _planPriceController.text = plan.price.toString();
      _planDurationController.text = plan.duration;
      _planDescriptionController.text = plan.description;
      _featureControllers.clear();
      for (var feature in plan.features) {
        _featureControllers.add(TextEditingController(text: feature));
      }
    } else {
      _planNameController.text = "Silver";
      _planPriceController.text = "";
      _planDurationController.text = "30 days";
      _planDescriptionController.text = "";
      _featureControllers.clear();
      _featureControllers.add(TextEditingController());
    }

    setState(() {
      _isPlanModalOpen = true;
    });
  }

  void _addFeatureField() {
    setState(() {
      _featureControllers.add(TextEditingController());
    });
  }

  void _removeFeatureField(int index) {
    setState(() {
      _featureControllers.removeAt(index);
    });
  }

  void _savePlan() {
    final name = _planNameController.text.trim();
    final price = double.tryParse(_planPriceController.text.trim());
    final duration = _planDurationController.text.trim();
    final description = _planDescriptionController.text.trim();
    final features = _featureControllers
        .map((c) => c.text.trim())
        .where((f) => f.isNotEmpty)
        .toList();

    if (name.isEmpty || price == null) {
      _showToast('Please fill all required fields', isError: true);
      return;
    }

    if (_isEditingPlan && _editingPlanId != null) {
      final index = subscriptionPlans.indexWhere((p) => p.id == _editingPlanId);
      if (index != -1) {
        subscriptionPlans[index] = SubscriptionPlan(
          id: _editingPlanId!,
          name: name,
          price: price,
          duration: duration,
          description: description,
          features: features,
          createdAt: subscriptionPlans[index].createdAt,
        );
        _showToast('Plan "$name" updated successfully');
      }
    } else {
      final newPlan = SubscriptionPlan(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        price: price,
        duration: duration,
        description: description,
        features: features,
        createdAt: DateTime.now().toIso8601String().split('T')[0],
      );
      subscriptionPlans.add(newPlan);
      _showToast('Plan "$name" created successfully');
    }

    _closePlanModal();
    setState(() {});
  }

  void _deletePlan(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text(
          'Delete Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Are you sure you want to delete this subscription plan?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                subscriptionPlans.removeWhere((p) => p.id == id);
              });
              Navigator.pop(context);
              _showToast('Plan deleted');
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _closePlanModal() {
    setState(() {
      _isPlanModalOpen = false;
      _isEditingPlan = false;
      _editingPlanId = null;
      _planNameController.clear();
      _planPriceController.clear();
      _planDurationController.clear();
      _planDescriptionController.clear();
      _featureControllers.clear();
    });
  }

  // ========== PROGRAM TEMPLATE METHODS ==========
  void _openTemplateModal({ProgramTemplate? template}) {
    _isEditingTemplate = template != null;
    _editingTemplateId = template?.id;

    if (template != null) {
      _templateNameController.text = template.name;
      _templateDietController.text = template.diet;
      _templateWorkoutController.text = template.workout;
    } else {
      _templateNameController.clear();
      _templateDietController.clear();
      _templateWorkoutController.clear();
    }

    setState(() {
      _isTemplateModalOpen = true;
    });
  }

  void _saveTemplate() {
    final name = _templateNameController.text.trim();
    final diet = _templateDietController.text.trim();
    final workout = _templateWorkoutController.text.trim();

    if (name.isEmpty) {
      _showToast('Please enter a template name', isError: true);
      return;
    }

    if (_isEditingTemplate && _editingTemplateId != null) {
      final index = programTemplates.indexWhere(
        (t) => t.id == _editingTemplateId,
      );
      if (index != -1) {
        programTemplates[index] = ProgramTemplate(
          id: _editingTemplateId!,
          name: name,
          diet: diet,
          workout: workout,
          createdAt: programTemplates[index].createdAt,
        );
        _showToast('Template "$name" updated successfully');
      }
    } else {
      final newTemplate = ProgramTemplate(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        diet: diet,
        workout: workout,
        createdAt: DateTime.now().toIso8601String().split('T')[0],
      );
      programTemplates.add(newTemplate);
      _showToast('Template "$name" created successfully');
    }

    _closeTemplateModal();
    setState(() {});
  }

  void _deleteTemplate(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text(
          'Delete Template',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Are you sure you want to delete this template?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                programTemplates.removeWhere((t) => t.id == id);
              });
              Navigator.pop(context);
              _showToast('Template deleted');
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF453A)),
            ),
          ),
        ],
      ),
    );
  }

  void _closeTemplateModal() {
    setState(() {
      _isTemplateModalOpen = false;
      _isEditingTemplate = false;
      _editingTemplateId = null;
      _templateNameController.clear();
      _templateDietController.clear();
      _templateWorkoutController.clear();
    });
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _planPriceController.dispose();
    _planDurationController.dispose();
    _planDescriptionController.dispose();
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    _templateNameController.dispose();
    _templateDietController.dispose();
    _templateWorkoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Program Management'),
      drawer: AppDrawer(selectedIndex: 2, role: 'coach'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                pageHeader(
                  'Manage subscription plans (visible to trainees) and program templates (internal use)',
                ),
                const SizedBox(height: 24),

                // Section Tabs
                _buildSectionTabs(),
                const SizedBox(height: 24),

                // Section Content
                _selectedSection == 0
                    ? _buildSubscriptionPlansSection()
                    : _buildProgramTemplatesSection(),
              ],
            ),
          ),

          // Plan Modal
          if (_isPlanModalOpen) _buildPlanModal(),

          // Template Modal
          if (_isTemplateModalOpen) _buildTemplateModal(),
        ],
      ),
    );
  }

  Widget _buildSectionTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabButton('📋 Subscription Plans', 0),
          const SizedBox(width: 12),
          _buildTabButton('📁 Program Templates', 1),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isActive = _selectedSection == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedSection = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.black : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ========== SUBSCRIPTION PLANS SECTION ==========
  Widget _buildSubscriptionPlansSection() {
    return Column(
      children: [
        // Create Button
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 200,
            child: buildButton(
              'Create Subscription Plan',
              Icon(Icons.add),
              () => _openPlanModal(),
              true,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Plans Grid
        subscriptionPlans.isEmpty
            ? _buildEmptyState(
                icon: Icons.subscriptions_outlined,
                message: 'No subscription plans created yet',
                onPressed: () => _openPlanModal(),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subscriptionPlans.length,
                itemBuilder: (context, index) {
                  final plan = subscriptionPlans[index];
                  return Column(
                    children: [
                      _buildPlanCard(plan),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    Color borderColor;
    switch (plan.name.toLowerCase()) {
      case 'silver':
        borderColor = const Color(0xFFC0C0C0);
        break;
      case 'gold':
        borderColor = const Color(0xFFFFD700);
        break;
      case 'platinum':
        borderColor = const Color(0xFFE5E4E2);
        break;
      default:
        borderColor = AppColors.cardBorder;
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: Border(
                top: BorderSide(color: borderColor),
                bottom: BorderSide(color: borderColor),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '\$${plan.price}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      TextSpan(
                        text: '/${plan.duration}',
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      plan.duration,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  plan.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ...plan.features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openPlanModal(plan: plan),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deletePlan(plan.id),
                    icon: const Icon(Icons.delete_outline, size: 14),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.red, width: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== PROGRAM TEMPLATES SECTION ==========
  Widget _buildProgramTemplatesSection() {
    return Column(
      children: [
        // Create Button
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _openTemplateModal(),
            icon: const Icon(Icons.add, size: 16, color: Colors.black),
            label: const Text(
              'Create Template',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Templates Grid
        programTemplates.isEmpty
            ? _buildEmptyState(
                icon: Icons.folder_outlined,
                message: 'No program templates created yet',
                onPressed: () => _openTemplateModal(),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 20,
                ),
                itemCount: programTemplates.length,
                itemBuilder: (context, index) {
                  final template = programTemplates[index];
                  return _buildTemplateCard(template);
                },
              ),
      ],
    );
  }

  Widget _buildTemplateCard(ProgramTemplate template) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: const Border(
                bottom: BorderSide(color: AppColors.cardBorder),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  template.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'Template',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Diet Structure Preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_outlined,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Diet Structure',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        template.diet.length > 80
                            ? '${template.diet.substring(0, 80)}...'
                            : template.diet,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Workout Structure Preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Workout Structure',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        template.workout.length > 80
                            ? '${template.workout.substring(0, 80)}...'
                            : template.workout,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openTemplateModal(template: template),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteTemplate(template.id),
                    icon: const Icon(Icons.delete_outline, size: 14),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF453A),
                      side: const BorderSide(
                        color: Color(0xFFFF453A),
                        width: 0.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // ========== PLAN MODAL ==========
  Widget _buildPlanModal() {
    return GestureDetector(
      onTap: _closePlanModal,
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
                          _isEditingPlan
                              ? 'Edit Subscription Plan'
                              : 'Create Subscription Plan',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: _closePlanModal,
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
                      child: Column(
                        children: [
                          _buildDropdownField(
                            label: 'Plan Name',
                            value: _planNameController.text,
                            items: const ['Silver', 'Gold', 'Platinum'],
                            onChanged: (value) =>
                                _planNameController.text = value,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _planPriceController,
                            label: 'Price',
                            hint: '49.99',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          _buildDropdownField(
                            label: 'Duration',
                            value: _planDurationController.text,
                            items: const [
                              '30 days',
                              '60 days',
                              '90 days',
                              '1 year',
                            ],
                            onChanged: (value) =>
                                _planDurationController.text = value,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _planDescriptionController,
                            label: 'Description',
                            hint: 'Describe what this plan offers...',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Features',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._featureControllers.asMap().entries.map((entry) {
                            int index = entry.key;
                            TextEditingController controller = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: controller,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Feature (e.g., Weekly check-ins)',
                                        hintStyle: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.background,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.cardBorder,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeFeatureField(index),
                                    icon: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Color(0xFFFF453A),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          TextButton.icon(
                            onPressed: _addFeatureField,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Feature'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
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
                        TextButton(
                          onPressed: _closePlanModal,
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _savePlan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Save Plan'),
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

  // ========== TEMPLATE MODAL ==========
  Widget _buildTemplateModal() {
    return GestureDetector(
      onTap: _closeTemplateModal,
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
                        const Text(
                          'Create Program Template',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: _closeTemplateModal,
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
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _templateNameController,
                            label: 'Template Name',
                            hint: 'e.g., Hypertrophy Master',
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _templateDietController,
                            label: 'Diet Structure',
                            hint: 'Describe the diet plan structure...',
                            maxLines: 4,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _templateWorkoutController,
                            label: 'Workout Structure',
                            hint: 'Describe the workout structure...',
                            maxLines: 4,
                          ),
                        ],
                      ),
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
                        TextButton(
                          onPressed: _closeTemplateModal,
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _saveTemplate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Save Template'),
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

  // ========== FORM HELPER WIDGETS ==========
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
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
              value: value,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) onChanged(newValue);
              },
              dropdownColor: AppColors.cardBackground,
            ),
          ),
        ),
      ],
    );
  }
}
