import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/build_dropdown_filter.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/models/coach/coach_stats.dart';
import 'package:fit/models/coach/trainee_subscriptions.dart';
import 'package:fit/models/coach/wallet_model.dart';
import 'package:fit/models/coach/wallet_transaction_model.dart';
import 'package:fit/screens/coach/build_subs_grid.dart';
import 'package:fit/screens/coach/stats_wallet.dart';
import 'package:fit/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fit/styles/colors.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<TraineeSubscription> _subscriptions = [];
  List<WalletTransaction> _transactions = [];
  final int _currentTransactionPage = 1;
  int _totalTransactionPages = 1;
  bool _isLoadingTransactions = false;
  WalletData? _wallet;
  CoachStatsData? _stats;
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNextPage = false;

  String _search = '';
  String _program = 'All Programs';
  String _tierFilter = 'All Tiers';
  String _statusFilter = 'All Status';
  String _reviewFilter = 'All Reviews';
  String _sortFilter = 'Newest First';
  String _transactionTypesFilter = 'All Types';
  String _transactionSortFilter = 'Newest First';
  bool _expiringSoon = false;

  TraineeSubscription? _selectedSub;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadTransactions();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch stats, trainees, and wallet in parallel
      final results = await Future.wait([
        ApiService.getCoachWorkspaceStats(),
        ApiService.getTrainees(
          pageNumber: _currentPage,
          pageSize: 10,
          searchQuery: _search.isEmpty ? null : _search,
          filterPackageTier: _tierFilter == 'All Tiers' ? null : _tierFilter,
          filterProgramType: _program == 'All Programs'
              ? null
              : _program == 'Workout Only'
              ? 'WorkoutOnly'
              : _program == 'Nutrition Only'
              ? 'NutritionOnly'
              : 'WorkoutAndNutrition',
          filterStatus: _statusFilter == 'All Status'
              ? null
              : _statusFilter == 'Active'
              ? 'Active'
              : _statusFilter == 'Pending Upload'
              ? 'PendingAction'
              : null,
          filterReviewStatus: _reviewFilter == 'All Reviews'
              ? null
              : _reviewFilter == 'In Review'
              ? 'In Review'
              : 'Reviewed',
          filterExpiringSoon: _expiringSoon,
          sortByDate: _sortFilter == 'Newest First' ? 'desc' : 'asc',
        ),
        ApiService.getWallet(),
      ]);

      setState(() {
        _stats = results[0] as CoachStatsData;
        final traineesData = results[1] as TraineesData;
        _subscriptions = traineesData.items;
        _totalPages = traineesData.totalPages;
        _hasNextPage = traineesData.hasNextPage;
        _wallet = results[2] as WalletData;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoadingTransactions = true);
    try {
      // Map filter values to API expected values
      String? typeFilter;
      if (_transactionTypesFilter == 'Income Only') {
        typeFilter = 'Income';
      } else if (_transactionTypesFilter == 'Withdrawals') {
        typeFilter = 'Withdrawal';
      } else if (_transactionTypesFilter == 'Refunds') {
        typeFilter = 'Refund';
      } else if (_transactionTypesFilter == 'Fees') {
        typeFilter = 'Fee';
      }

      String? sortBy;
      if (_transactionSortFilter == 'Newest First') {
        sortBy = 'newest';
      } else if (_transactionSortFilter == 'Oldest First') {
        sortBy = 'oldest';
      } else if (_transactionSortFilter == 'Highest Amount') {
        sortBy = 'highest';
      } else if (_transactionSortFilter == 'Lowest Amount') {
        sortBy = 'lowest';
      }

      final transactionsData = await ApiService.getWalletTransactions(
        pageNumber: _currentTransactionPage,
        pageSize: 10,
        type: typeFilter,
        sortBy: sortBy,
      );

      setState(() {
        _transactions = transactionsData.items;
        _totalTransactionPages = transactionsData.totalPages;
        _isLoadingTransactions = false;
      });
    } catch (e) {
      print("Error loading transactions: $e");
      setState(() => _isLoadingTransactions = false);
    }
  }

  // Filter transactions based on selected filter
  List<WalletTransaction> get _filteredTransactions => _transactions;

  List<TraineeSubscription> get _filteredSubscriptions {
    var result = _subscriptions;

    // Search filter
    if (_search.isNotEmpty) {
      result = result
          .where(
            (sub) =>
                sub.traineeName.toLowerCase().contains(_search.toLowerCase()),
          )
          .toList();
    }

    // Tier filter
    if (_tierFilter != 'All Tiers') {
      result = result.where((sub) => sub.tier == _tierFilter).toList();
    }

    // Status filter
    if (_statusFilter != 'All Status') {
      String statusMap;
      switch (_statusFilter) {
        case 'Active':
          statusMap = 'active';
          break;
        case 'Pending Upload':
          statusMap = 'pending';
          break;
        case 'Refund Requested':
          statusMap = 'refund_requested';
          break;
        case 'Expired':
          statusMap = 'expired';
          break;
        default:
          statusMap = '';
      }
      if (statusMap.isNotEmpty) {
        result = result
            .where((sub) => sub.subscriptionStatus == statusMap)
            .toList();
      }
    }

    // Program type filter
    if (_program != 'All Programs') {
      result = result.where((sub) {
        if (_program == 'Workout Only') {
          return sub.hasWorkoutPlan && !sub.hasNutritionPlan;
        } else if (_program == 'Nutrition Only') {
          return sub.hasNutritionPlan && !sub.hasWorkoutPlan;
        } else if (_program == 'Workout & Nutrition') {
          return sub.hasWorkoutPlan && sub.hasNutritionPlan;
        }
        return true;
      }).toList();
    }

    // Review filter
    if (_reviewFilter != 'All Reviews') {
      if (_reviewFilter == 'In Review') {
        result = result.where((sub) => sub.reviewTimer > 0).toList();
      } else if (_reviewFilter == 'Reviewed') {
        result = result
            .where(
              (sub) =>
                  sub.reviewTimer == 0 && sub.subscriptionStatus == 'active',
            )
            .toList();
      }
    }

    // Expiring soon filter
    if (_expiringSoon) {
      result = result
          .where((sub) => sub.daysRemaining > 0 && sub.daysRemaining <= 7)
          .toList();
    }

    // Sort
    if (_sortFilter == 'Newest First') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return result;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
        : Scaffold(
            appBar: MyAppBar(drawerIcon: Icons.menu, title: 'Subscriptions'),
            drawer: AppDrawer(selectedIndex: 1, role: 'trainer'),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildWalletSection(_stats!),
                  SizedBox(height: 20),
                  buildOperationalStatsRow(_subscriptions, _stats!),
                  SizedBox(height: 20),
                  _buildFilterToolbar(),
                  SizedBox(height: 20),
                  buildSubscriptionsGrid(
                    context,
                    _filteredSubscriptions, // Now uses TraineeSubscription
                    (subscription) {
                      setState(() {
                        _selectedSub = subscription;
                      });
                      _showUploadModal();
                    },
                  ),
                  SizedBox(height: 10),
                  _buildBottomSection(),
                  // Upload Modal
                ],
              ),
            ),
          );
  }

  Widget _buildFilterToolbar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          TextField(
            style: TextStyle(color: AppColors.cardBackground),
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search trainee by name...',
              hintStyle: TextStyle(color: AppColors.cardTextSecondary),
              prefixIcon: Icon(
                Icons.search,
                size: 18,
                color: AppColors.cardTextSecondary,
              ),
              filled: true,
              fillColor: AppColors.cardBackground,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ),
          SizedBox(height: 8),
          _buildExpiringSoonToggle(),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: buildFilterDropdown(_tierFilter, [
                  'All Tiers',
                  'Bronze',
                  'Silver',
                  'Gold',
                ], (v) => setState(() => _tierFilter = v)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: buildFilterDropdown(_program, [
                  'All Programs',
                  'Workout Only',
                  'Nutrition Only',
                  'Workout & Nutrition',
                ], (v) => setState(() => _program = v)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: buildFilterDropdown(_statusFilter, [
                  'All Status',
                  'Active',
                  'Pending Upload',
                  'Refund Requested',
                  'Expired',
                ], (v) => setState(() => _statusFilter = v)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: buildFilterDropdown(_reviewFilter, [
                  'All Reviews',
                  'In Review',
                  'Reviewed',
                ], (v) => setState(() => _reviewFilter = v)),
              ),
            ],
          ),
          SizedBox(height: 8),
          buildFilterDropdown(_sortFilter, [
            'Newest First',
            'Oldest First',
          ], (v) => setState(() => _sortFilter = v)),
        ],
      ),
    );
  }

  Widget _buildExpiringSoonToggle() {
    return GestureDetector(
      onTap: () => setState(() => _expiringSoon = !_expiringSoon),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _expiringSoon
              ? AppColors.primary.withOpacity(0.15)
              : Colors.transparent,
          border: Border.all(
            color: _expiringSoon ? AppColors.primary : AppColors.cardBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.clock,
              color: _expiringSoon ? AppColors.primary : AppColors.textPrimary,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Expiring Soon',
              style: TextStyle(
                color: _expiringSoon
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        // Withdrawal section (keep as is, but use _wallet instead of _stats)
        Container(
          padding: EdgeInsets.all(24),
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
                  Icon(LucideIcons.arrowDownLeft, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Withdrawal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.75),
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Balance',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.cardTextSecondary,
                        ),
                      ),
                      Text(
                        '\$${_wallet?.availableBalance.toStringAsFixed(2) ?? '0'}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      Text(
                        'Pending Clearance: \$${_wallet?.pendingClearance.toStringAsFixed(2) ?? '0'}',
                        style: TextStyle(
                          color: AppColors.cardTextSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              buildButton(
                'Withdraw Funds',
                Icon(LucideIcons.arrowUpRight, color: Colors.black),
                () {
                  _showWithdrawalModal();
                },
                (_wallet?.availableBalance ?? 0) >= 50,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.shield,
                    color: AppColors.cardTextSecondary,
                    size: 10,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'MINIMUM WITHDRAWAL: \$50',
                    style: TextStyle(
                      color: AppColors.cardTextSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Monitor your recent financial activity',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.cardTextSecondary,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: buildFilterDropdown(
                      _transactionTypesFilter,
                      [
                        'All Types',
                        'Income Only',
                        'Withdrawals',
                        'Refunds',
                        'Fees',
                      ],
                      (v) => setState(() {
                        _transactionTypesFilter = v;
                        _loadTransactions();
                      }),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: buildFilterDropdown(
                      _transactionSortFilter,
                      [
                        'Newest First',
                        'Oldest First',
                        'Highest Amount',
                        'Lowest Amount',
                      ],
                      (v) => setState(() {
                        _transactionSortFilter = v;
                        _loadTransactions();
                      }),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_isLoadingTransactions)
                Center(child: CircularProgressIndicator())
              else if (_transactions.isEmpty)
                Container(
                  padding: EdgeInsets.all(40),
                  alignment: Alignment.center,
                  child: Text(
                    'No transactions found',
                    style: TextStyle(color: AppColors.cardTextSecondary),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final t = _transactions[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                _buildTransactionIcon(t.type),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.description,
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        t.type.toUpperCase(),
                                        style: TextStyle(
                                          color: AppColors.cardTextSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(t.createdAt),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.cardTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${t.amount > 0 ? '+' : ''}${t.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: t.amount > 0
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                _buildStatusBadge(t.status),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'Income':
        icon = LucideIcons.arrowDownLeft;
        color = AppColors.primary;
        break;
      case 'Withdrawal':
        icon = LucideIcons.arrowUpRight;
        color = AppColors.orange;
        break;
      case 'Refund':
        icon = LucideIcons.refreshCcw;
        color = AppColors.red;
        break;
      default:
        icon = LucideIcons.dollarSign;
        color = AppColors.cardTextSecondary;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.025),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = AppColors.primary;
        break;
      case 'pending':
        color = AppColors.orange;
        break;
      default:
        color = AppColors.red;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPaginationControls() {
    if (_totalPages <= 1) return SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 1
              ? () {
                  setState(() {
                    _currentPage--;
                    _loadData();
                  });
                }
              : null,
          icon: Icon(Icons.chevron_left),
        ),
        Text('Page $_currentPage of $_totalPages'),
        IconButton(
          onPressed: _hasNextPage
              ? () {
                  setState(() {
                    _currentPage++;
                    _loadData();
                  });
                }
              : null,
          icon: Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  void _showUploadModal() {
    final TextEditingController programNameController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    File? selectedFile;
    File? selectedCoverImage;
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
                side: BorderSide(color: AppColors.cardBorder),
              ),
              contentPadding: EdgeInsets.all(24),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.upload,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upload Program',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Upload program for ${_selectedSub?.traineeName ?? ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.cardTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: AppColors.cardTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Program Name
                    TextField(
                      controller: programNameController,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Program Name',
                        labelStyle: TextStyle(
                          color: AppColors.cardTextSecondary,
                        ),
                        filled: true,
                        fillColor: Color(0xFF161B19),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Program Category
                    TextField(
                      controller: categoryController,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Program Category',
                        labelStyle: TextStyle(
                          color: AppColors.cardTextSecondary,
                        ),
                        hintText: 'e.g. Strength, Cardio, Nutrition',
                        hintStyle: TextStyle(
                          color: AppColors.cardTextSecondary,
                        ),
                        filled: true,
                        fillColor: Color(0xFF161B19),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Start Date
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            startDate = picked;
                            startDateController.text =
                                '${picked.day}/${picked.month}/${picked.year}';
                          });
                        }
                      },
                      child: TextField(
                        controller: startDateController,
                        enabled: false,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          labelStyle: TextStyle(
                            color: AppColors.cardTextSecondary,
                          ),
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: AppColors.cardTextSecondary,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Color(0xFF161B19),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.cardBorder),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // End Date
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: startDate ?? DateTime.now(),
                          lastDate: (startDate ?? DateTime.now()).add(
                            Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            endDate = picked;
                            endDateController.text =
                                '${picked.day}/${picked.month}/${picked.year}';
                          });
                        }
                      },
                      child: TextField(
                        controller: endDateController,
                        enabled: false,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          labelStyle: TextStyle(
                            color: AppColors.cardTextSecondary,
                          ),
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: AppColors.cardTextSecondary,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Color(0xFF161B19),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.cardBorder),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Program File
                    GestureDetector(
                      onTap: () async {
                        final result = await FilePicker.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: [
                            'pdf',
                            'doc',
                            'docx',
                            'txt',
                            'xls',
                            'xlsx',
                            'ppt',
                            'pptx',
                          ],
                        );
                        if (result != null &&
                            result.files.single.path != null) {
                          setDialogState(() {
                            selectedFile = File(result.files.single.path!);
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedFile != null
                                ? AppColors.primary
                                : AppColors.cardBorder,
                            width: selectedFile != null ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedFile != null
                                  ? Icons.file_present
                                  : Icons.upload_file,
                              color: selectedFile != null
                                  ? AppColors.primary
                                  : AppColors.cardTextSecondary,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedFile != null
                                    ? selectedFile!.path.split('/').last
                                    : 'Upload Program File (PDF, DOC, DOCX, etc.)',
                                style: TextStyle(
                                  color: selectedFile != null
                                      ? AppColors.textPrimary
                                      : AppColors.cardTextSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (selectedFile != null)
                              GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    selectedFile = null;
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.cardTextSecondary,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Cover Image
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setDialogState(() {
                            selectedCoverImage = File(image.path);
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF161B19),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedCoverImage != null
                                ? AppColors.primary
                                : AppColors.cardBorder,
                            width: selectedCoverImage != null ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedCoverImage != null
                                  ? Icons.image
                                  : Icons.image_outlined,
                              color: selectedCoverImage != null
                                  ? AppColors.primary
                                  : AppColors.cardTextSecondary,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedCoverImage != null
                                    ? selectedCoverImage!.path.split('/').last
                                    : 'Upload Cover Image',
                                style: TextStyle(
                                  color: selectedCoverImage != null
                                      ? AppColors.textPrimary
                                      : AppColors.cardTextSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (selectedCoverImage != null)
                              GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    selectedCoverImage = null;
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.cardTextSecondary,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Coach Private Note
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Coach Private Note (Optional)',
                        labelStyle: TextStyle(
                          color: AppColors.cardTextSecondary,
                        ),
                        hintText: 'Add a private note for this program...',
                        hintStyle: TextStyle(
                          color: AppColors.cardTextSecondary,
                        ),
                        filled: true,
                        fillColor: Color(0xFF161B19),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.cardBorder),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              // Validate fields
                              if (programNameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please enter program name'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (categoryController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please enter program category',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (startDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please select start date'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (endDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please select end date'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (selectedFile == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please upload program file'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (selectedCoverImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please upload cover image'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              Navigator.pop(context);

                              setState(() => _isLoading = true);

                              try {
                                final result = await ApiService.uploadProgram(
                                  subscriptionId: _selectedSub!.id,
                                  programName: programNameController.text
                                      .trim(),
                                  programCategory: categoryController.text
                                      .trim(),
                                  startDate: startDate!,
                                  endDate: endDate!,
                                  file: selectedFile!,
                                  coverImage: selectedCoverImage!,
                                  coachPrivateNote:
                                      noteController.text.trim().isNotEmpty
                                      ? noteController.text.trim()
                                      : null,
                                );

                                if (result['success']) {
                                  await _loadData();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Program uploaded successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  throw Exception(result['message']);
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to upload: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('Upload'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWithdrawalModal() {
    final TextEditingController amountController = TextEditingController();
    String selectedMethod = 'Bank';
    final TextEditingController methodDetailsController =
        TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
                side: BorderSide(color: AppColors.cardBorder),
              ),
              contentPadding: EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          LucideIcons.arrowUpRight,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Withdraw Funds',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Request a withdrawal to your account',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.cardTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: AppColors.cardTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF161B19),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Balance',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.cardTextSecondary,
                          ),
                        ),
                        Text(
                          '\$${_wallet?.availableBalance.toStringAsFixed(2) ?? '0'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Withdrawal Amount',
                      labelStyle: TextStyle(color: AppColors.cardTextSecondary),
                      prefixText: '\$ ',
                      prefixStyle: TextStyle(color: AppColors.textPrimary),
                      hintText: 'Min. \$50',
                      hintStyle: TextStyle(color: AppColors.cardTextSecondary),
                      filled: true,
                      fillColor: Color(0xFF161B19),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Payout Method',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cardTextSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: ['Bank', 'PayPal', 'Stripe'].map((method) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedMethod = method;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 8),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedMethod == method
                                  ? AppColors.primary.withOpacity(0.15)
                                  : Color(0xFF161B19),
                              border: Border.all(
                                color: selectedMethod == method
                                    ? AppColors.primary
                                    : AppColors.cardBorder,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              method,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selectedMethod == method
                                    ? AppColors.primary
                                    : AppColors.cardTextSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: methodDetailsController,
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: selectedMethod == 'Bank'
                          ? 'Account Number / IBAN'
                          : selectedMethod == 'PayPal'
                          ? 'PayPal Email'
                          : 'Stripe Account ID',
                      labelStyle: TextStyle(color: AppColors.cardTextSecondary),
                      hintText: selectedMethod == 'Bank'
                          ? 'Enter your account number'
                          : selectedMethod == 'PayPal'
                          ? 'Enter your PayPal email'
                          : 'Enter your Stripe account ID',
                      hintStyle: TextStyle(color: AppColors.cardTextSecondary),
                      filled: true,
                      fillColor: Color(0xFF161B19),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.cardBorder),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final amount = double.tryParse(
                              amountController.text,
                            );

                            if (amount == null || amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter a valid amount'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (amount < 50) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Minimum withdrawal amount is \$50',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (amount > (_wallet?.availableBalance ?? 0)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Insufficient balance'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (methodDetailsController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please enter payout method details',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            Navigator.pop(context);

                            // Show loading
                            setState(() => _isLoading = true);

                            try {
                              final response =
                                  await ApiService.requestWithdrawal(
                                    withdrawalAmount: amount,
                                    payoutMethod: selectedMethod,
                                    payoutMethodDetails: methodDetailsController
                                        .text
                                        .trim(),
                                  );

                              if (response.isSuccess) {
                                // Refresh wallet and transactions
                                await _loadData();
                                await _loadTransactions();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Withdrawal request submitted successfully!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                throw Exception(response.message);
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to process withdrawal: $e',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Request Withdrawal'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
