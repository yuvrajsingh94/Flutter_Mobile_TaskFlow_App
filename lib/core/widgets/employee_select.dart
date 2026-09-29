import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';

class EmployeeSelect extends ConsumerStatefulWidget {
  final String label;
  final bool isRequired;
  final String? error;
  final dynamic value; // String or List<String>
  final ValueChanged<dynamic>? onChanged;
  final dynamic selectedEmployee; // UserProfile or List<UserProfile>
  final ValueChanged<dynamic>? onSelectEmployee;
  final bool multiSelect;
  final String placeholder;
  final bool enabled;

  const EmployeeSelect({
    super.key,
    this.label = 'Assign To',
    this.isRequired = true,
    this.error,
    this.value,
    this.onChanged,
    this.selectedEmployee,
    this.onSelectEmployee,
    this.multiSelect = false,
    this.placeholder = 'Search active employees by name, email or employee ID',
    this.enabled = true,
  });

  @override
  ConsumerState<EmployeeSelect> createState() => _EmployeeSelectState();
}

class _EmployeeSelectState extends ConsumerState<EmployeeSelect> {
  final Map<String, UserProfile> _selectedCache = {};

  @override
  void initState() {
    super.initState();
    _initCache();
  }

  @override
  void didUpdateWidget(covariant EmployeeSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initCache();
  }

  void _initCache() {
    if (widget.selectedEmployee != null) {
      if (widget.selectedEmployee is List<UserProfile>) {
        for (final emp in widget.selectedEmployee as List<UserProfile>) {
          _selectedCache[emp.id] = emp;
        }
      } else if (widget.selectedEmployee is UserProfile) {
        final emp = widget.selectedEmployee as UserProfile;
        _selectedCache[emp.id] = emp;
      }
    }
  }

  void _removeSelection(String id) {
    if (widget.multiSelect) {
      final current = widget.value is List ? List<String>.from(widget.value) : <String>[];
      current.remove(id);
      final updatedList = current.map((cid) => _selectedCache[cid]).whereType<UserProfile>().toList();
      widget.onChanged?.call(current);
      widget.onSelectEmployee?.call(updatedList);
    } else {
      widget.onChanged?.call('');
      widget.onSelectEmployee?.call(null);
    }
    setState(() {});
  }

  void _openEmployeeModal(BuildContext context) {
    if (!widget.enabled) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EmployeeModalSheet(
        title: widget.label,
        multiSelect: widget.multiSelect,
        selectedIds: widget.multiSelect
            ? (widget.value is List ? List<String>.from(widget.value) : <String>[])
            : (widget.value != null && widget.value.toString().isNotEmpty
                ? [widget.value.toString()]
                : <String>[]),
        selectedCache: _selectedCache,
        isDark: isDark,
        onToggleEmployee: (emp) {
          _selectedCache[emp.id] = emp;
          if (widget.multiSelect) {
            final current = widget.value is List ? List<String>.from(widget.value) : <String>[];
            if (current.contains(emp.id)) {
              current.remove(emp.id);
            } else {
              current.add(emp.id);
            }
            final updatedList = current.map((cid) => _selectedCache[cid] ?? emp).toList();
            widget.onChanged?.call(current);
            widget.onSelectEmployee?.call(updatedList);
            setState(() {});
          } else {
            Navigator.of(ctx).pop();
            widget.onChanged?.call(emp.id);
            widget.onSelectEmployee?.call(emp);
            setState(() {});
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textLabelColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final bgInput = widget.enabled
        ? (isDark ? AppColors.darkBgInput : AppColors.bgInput)
        : (isDark ? AppColors.darkCard : AppColors.surface);
    final borderInput = widget.error != null
        ? AppColors.error
        : (isDark ? AppColors.darkBorderInput : AppColors.borderInput);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textPlaceholder = isDark ? AppColors.darkTextPlaceholder : AppColors.textPlaceholder;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;

    // Collect list of selected user profiles
    final List<UserProfile> selectedEmps = [];
    if (widget.multiSelect) {
      if (widget.value is List) {
        for (final id in widget.value) {
          if (id != null && id.toString().isNotEmpty) {
            final cached = _selectedCache[id.toString()];
            if (cached != null) {
              selectedEmps.add(cached);
            } else {
              selectedEmps.add(UserProfile(
                id: id.toString(),
                firstName: 'Employee',
                lastName: '',
                email: '',
                role: UserRole.employee,
                phoneNumber: '',
              ));
            }
          }
        }
      }
    } else {
      if (widget.value != null && widget.value.toString().isNotEmpty) {
        final id = widget.value.toString();
        final cached = _selectedCache[id];
        if (cached != null) {
          selectedEmps.add(cached);
        } else {
          selectedEmps.add(UserProfile(
            id: id,
            firstName: 'Employee',
            lastName: '',
            email: '',
            role: UserRole.employee,
            phoneNumber: '',
          ));
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeSm,
                    fontWeight: AppTypography.fontWeightMedium,
                    color: textLabelColor,
                  ),
                ),
                if (widget.isRequired)
                  const Text(
                    ' *',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: AppTypography.fontSizeSm,
                      fontWeight: AppTypography.fontWeightMedium,
                    ),
                  ),
              ],
            ),
          ),

          // Chips display if any selected
          if (selectedEmps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedEmps.map((emp) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkOverlayMedium : AppColors.surfaceStone,
                      borderRadius: BorderRadius.circular(AppBorderRadius.pill),
                      border: Border.all(color: borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: isDark ? AppColors.darkAccentPrimary : AppColors.accentPrimary,
                          child: Text(
                            emp.firstName.isNotEmpty ? emp.firstName[0].toUpperCase() : 'E',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkAccentFg : AppColors.accentFg,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          emp.fullName.isNotEmpty ? emp.fullName : emp.id,
                          style: TextStyle(
                            fontSize: AppTypography.fontSizeXs,
                            fontWeight: AppTypography.fontWeightMedium,
                            color: textPrimary,
                          ),
                        ),
                        if (widget.enabled) ...[
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => _removeSelection(emp.id),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(Icons.close, size: 14, color: textSecondary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Trigger Box
          if (widget.multiSelect || selectedEmps.isEmpty)
            InkWell(
              onTap: widget.enabled ? () => _openEmployeeModal(context) : null,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: bgInput,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: borderInput, width: 1.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_search_outlined,
                      size: 18,
                      color: textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.placeholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeSm,
                          color: textPlaceholder,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: textSecondary,
                    ),
                  ],
                ),
              ),
            ),

          // Error text
          if (widget.error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.tiny),
              child: Text(
                widget.error!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: AppTypography.fontSizeXs,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmployeeModalSheet extends ConsumerStatefulWidget {
  final String title;
  final bool multiSelect;
  final List<String> selectedIds;
  final Map<String, UserProfile> selectedCache;
  final bool isDark;
  final ValueChanged<UserProfile> onToggleEmployee;

  const _EmployeeModalSheet({
    required this.title,
    required this.multiSelect,
    required this.selectedIds,
    required this.selectedCache,
    required this.isDark,
    required this.onToggleEmployee,
  });

  @override
  ConsumerState<_EmployeeModalSheet> createState() => _EmployeeModalSheetState();
}

class _EmployeeModalSheetState extends ConsumerState<_EmployeeModalSheet> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  List<UserProfile> _employees = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  late Set<String> _currentSelectedIds;

  @override
  void initState() {
    super.initState();
    _currentSelectedIds = Set<String>.from(widget.selectedIds);
    _fetchEmployees('', page: 1);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 60) {
      if (!_isLoading && !_isLoadingMore && _currentPage < _totalPages) {
        _fetchEmployees(_searchController.text, page: _currentPage + 1, append: true);
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchEmployees(query, page: 1, append: false);
    });
  }

  Future<void> _fetchEmployees(String query, {int page = 1, bool append = false}) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get(
        ApiEndpoints.employees,
        queryParameters: {
          'search': query.trim(),
          'role': 'employee',
          'limit': 15,
          'page': page,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final listRaw = (data['employees'] ?? data['data'] ?? []) as List;
        final allEmps = listRaw
            .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
            .where((u) =>
                u.role == UserRole.employee &&
                !u.isBlocked &&
                u.status == UserStatus.active)
            .toList();

        setState(() {
          if (append) {
            final existing = _employees.map((e) => e.id).toSet();
            final newEmps = allEmps.where((e) => !existing.contains(e.id)).toList();
            _employees.addAll(newEmps);
          } else {
            _employees = allEmps;
          }
          _currentPage = data['currentPage'] ?? page;
          _totalPages = data['totalPages'] ?? 1;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load employees';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgCard = widget.isDark ? AppColors.darkCard : AppColors.card;
    final textPrimary = widget.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = widget.isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderSubtle = widget.isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    final bgInput = widget.isDark ? AppColors.darkBgInput : AppColors.bgInput;
    final borderInput = widget.isDark ? AppColors.darkBorderInput : AppColors.borderInput;
    final accentPrimary = widget.isDark ? AppColors.darkAccentPrimary : AppColors.accentPrimary;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: borderInput,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeBase,
                    fontWeight: AppTypography.fontWeightBold,
                    color: textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: textSecondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: bgInput,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(color: borderInput),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: AppTypography.fontSizeSm, color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search active employees...',
                  hintStyle: TextStyle(
                    fontSize: AppTypography.fontSizeSm,
                    color: widget.isDark
                        ? AppColors.darkTextPlaceholder
                        : AppColors.textPlaceholder,
                  ),
                  prefixIcon: Icon(Icons.search, color: textSecondary, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),

          Divider(color: borderSubtle, height: 1),

          // Employee List or Loading / Empty state
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      )
                    : _employees.isEmpty
                        ? Center(
                            child: Text(
                              'No active employees found',
                              style: TextStyle(
                                fontSize: AppTypography.fontSizeSm,
                                color: textSecondary,
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            itemCount: _employees.length + (_isLoadingMore ? 1 : 0),
                            separatorBuilder: (_, __) => Divider(color: borderSubtle, height: 1),
                            itemBuilder: (ctx, index) {
                              if (index == _employees.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(AppSpacing.md),
                                  child: Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              }

                              final emp = _employees[index];
                              final isSelected = _currentSelectedIds.contains(emp.id);

                              return ListTile(
                                dense: true,
                                tileColor: isSelected
                                    ? (widget.isDark
                                        ? AppColors.darkOverlayMedium
                                        : AppColors.overlayMedium)
                                    : Colors.transparent,
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: widget.isDark
                                      ? AppColors.darkAccentPrimary
                                      : AppColors.accentPrimary,
                                  backgroundImage: emp.profilePicture != null &&
                                          emp.profilePicture!.isNotEmpty
                                      ? NetworkImage(emp.profilePicture!)
                                      : null,
                                  child: emp.profilePicture == null || emp.profilePicture!.isEmpty
                                      ? Text(
                                          emp.firstName.isNotEmpty
                                              ? emp.firstName[0].toUpperCase()
                                              : 'E',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: widget.isDark
                                                ? AppColors.darkAccentFg
                                                : AppColors.accentFg,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  emp.fullName,
                                  style: TextStyle(
                                    fontSize: AppTypography.fontSizeSm,
                                    fontWeight: isSelected
                                        ? AppTypography.fontWeightBold
                                        : AppTypography.fontWeightMedium,
                                    color: textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  emp.department != null && emp.department!.isNotEmpty
                                      ? '${emp.department} • ${emp.email}'
                                      : emp.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: AppTypography.fontSizeXs,
                                    color: textSecondary,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_circle_rounded,
                                        color: accentPrimary,
                                        size: 20,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    if (widget.multiSelect) {
                                      if (_currentSelectedIds.contains(emp.id)) {
                                        _currentSelectedIds.remove(emp.id);
                                      } else {
                                        _currentSelectedIds.add(emp.id);
                                      }
                                    } else {
                                      _currentSelectedIds
                                        ..clear()
                                        ..add(emp.id);
                                    }
                                  });
                                  widget.onToggleEmployee(emp);
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
