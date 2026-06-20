import 'package:fit/models/coach/tier_model.dart';
import 'package:fit/screens/settings/build_text_field.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

Widget buildTierSelector(
  List<TierDetailsData> tiers,
  String selectedTierId,
  Function(String) onSelectTier,
) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.transparent,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: tiers.map((tier) {
        final isActive = selectedTierId == tier.id;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelectTier(tier.id),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF161B19) : Colors.transparent,
                border: Border.all(
                  color: isActive
                      ? tier.color.withOpacity(0.33)
                      : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tier.icon,
                    size: 20,
                    color: isActive ? tier.color : AppColors.cardTextSecondary,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.cardTextSecondary,
                        ),
                      ),
                      Text(
                        tier.subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive
                              ? const Color(0xFFC9D1D9)
                              : const Color(0xFF484F58),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

Widget buildTierActivationCard(
  TierDetailsData selectedTier,
  VoidCallback onTogglePriority,
) {
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
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: selectedTier.color.withOpacity(0.08),
                border: Border.all(color: selectedTier.color.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                selectedTier.icon,
                size: 40,
                color: selectedTier.color,
              ),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${selectedTier.title} Tier',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedTier.active ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 200,
                  child: Text(
                    selectedTier.id == 'gold'
                        ? 'Top priority premium support with the best experience for your most committed clients.'
                        : selectedTier.id == 'silver'
                        ? 'Enhanced priority support for clients who need faster turnarounds and personalized attention.'
                        : 'Essential standard coaching support for your general client base with core features.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.cardTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B19).withOpacity(0.5),
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Chat Priority',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCA8A04).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          selectedTier.chatPriority,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFCA8A04),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        selectedTier.chatDesc,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.cardTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        LucideIcons.alertCircle,
                        size: 12,
                        color: Color(0xFF484F58),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              buildToggleSwitch(
                active: selectedTier.active,
                onToggle: onTogglePriority,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildToggleSwitch({
  required bool active,
  required VoidCallback onToggle,
}) {
  return GestureDetector(
    onTap: onToggle,
    child: Container(
      width: 56,
      height: 28,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: active
            ? AppColors.cardBackground
            : AppColors.cardBackground.withOpacity(0.5),
        border: Border.all(
          color: active
              ? AppColors.primary.withOpacity(0.33)
              : AppColors.cardBorder.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 300),
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.cardTextSecondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}

Widget buildTierConfigurationCard(
  TierDetailsData selectedTier,
  Function(String, String) onConfigChanged,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(32),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.settings,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Tier Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        buildConfigRow(
          '1-on-1 Calls',
          _mapOneOnOneCallToDisplay(selectedTier.oneOnOneCall),
          [
            'No Calls',
            '1 Welcome Call',
            'Monthly Call (30m)',
            'Bi-Weekly Call',
            'Weekly Call',
            'Custom',
          ],
          (value) =>
              onConfigChanged('oneOnOneCall', _mapOneOnOneCallToApi(value)),
        ),

        buildConfigRow(
          'Emergency Adjustments',
          _mapEmergencyToDisplay(selectedTier.emergencyAdjustments),
          [
            'None',
            '1 Adjustment / month',
            '2 Adjustments / month',
            'Unlimited Flexibility',
          ],
          (value) => onConfigChanged(
            'emergencyAdjustments',
            _mapEmergencyToApi(value),
          ),
        ),
      ],
    ),
  );
}

// Mapping helper functions - UPDATED
String _mapOneOnOneCallToDisplay(String apiValue) {
  switch (apiValue) {
    case 'NoCalls':
      return 'No Calls';
    case 'WelcomeCall':
      return '1 Welcome Call';
    case 'Monthly':
      return 'Monthly Call (30m)';
    case 'BiWeekly':
      return 'Bi-Weekly Call';
    case 'Weekly':
      return 'Weekly Call';
    case 'Custom':
      return 'Custom';
    default:
      return 'No Calls';
  }
}

String _mapOneOnOneCallToApi(String displayValue) {
  switch (displayValue) {
    case 'No Calls':
      return 'NoCalls';
    case '1 Welcome Call':
      return 'WelcomeCall';
    case 'Monthly Call (30m)':
      return 'Monthly';
    case 'Bi-Weekly Call':
      return 'BiWeekly';
    case 'Weekly Call':
      return 'Weekly';
    case 'Custom':
      return 'Custom';
    default:
      return 'NoCalls';
  }
}

String _mapEmergencyToDisplay(String apiValue) {
  switch (apiValue) {
    case 'None':
      return 'None';
    case 'OnePerMonth':
      return '1 Adjustment / month';
    case 'TwoPerMonth':
      return '2 Adjustments / month';
    case 'Flexible':
      return 'Unlimited Flexibility';
    default:
      return 'None';
  }
}

String _mapEmergencyToApi(String displayValue) {
  switch (displayValue) {
    case 'None':
      return 'None';
    case '1 Adjustment / month':
      return 'OnePerMonth';
    case '2 Adjustments / month':
      return 'TwoPerMonth';
    case 'Unlimited Flexibility':
      return 'Flexible';
    default:
      return 'None';
  }
}

Widget buildConfigRow(
  String label,
  String value,
  List<String> options,
  Function(String) onChanged,
) {
  final validValue = options.contains(value) ? value : options.first;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.transparent,
      border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure ${label.toLowerCase()} for this tier',
              style: TextStyle(fontSize: 9, color: AppColors.cardTextSecondary),
            ),
          ],
        ),
        DropdownButton<String>(
          value: validValue,
          dropdownColor: AppColors.cardBackground,
          underline: const SizedBox(),
          style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
          items: options.map((opt) {
            return DropdownMenuItem(value: opt, child: Text(opt));
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ],
    ),
  );
}

Widget buildCustomFeaturesCard(
  TierDetailsData selectedTier,
  Function(String) onAddFeature,
  Function(int) onRemoveFeature,
) {
  final TextEditingController featureController = TextEditingController();

  return Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(32),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.plus,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Custom Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '${selectedTier.customFeatures.length} Active',
              style: const TextStyle(fontSize: 12, color: Color(0xFF484F58)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: buildTextField(null, featureController)),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (featureController.text.trim().isNotEmpty) {
                  onAddFeature(featureController.text.trim());
                  featureController.clear();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.07),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.plus,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (selectedTier.customFeatures.isEmpty)
          Text(
            'No custom features added yet. Use the field above to add unique perks for this tier.',
            style: TextStyle(fontSize: 12, color: AppColors.cardTextSecondary),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.builder(
              itemCount: selectedTier.customFeatures.length,
              itemBuilder: (context, index) {
                final feature = selectedTier.customFeatures[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.3),
                    border: Border.all(
                      color: AppColors.cardBorder.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.cardTextSecondary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onRemoveFeature(index),
                        child: Icon(
                          LucideIcons.trash2,
                          size: 16,
                          color: AppColors.cardTextSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    ),
  );
}
