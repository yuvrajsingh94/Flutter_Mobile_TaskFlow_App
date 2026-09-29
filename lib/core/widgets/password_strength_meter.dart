import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

class PasswordChecks {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecial;

  const PasswordChecks({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecial,
  });

  factory PasswordChecks.fromPassword(String password) {
    return PasswordChecks(
      hasMinLength: password.length >= 8,
      hasUppercase: RegExp(r'[A-Z]').hasMatch(password),
      hasLowercase: RegExp(r'[a-z]').hasMatch(password),
      hasNumber: RegExp(r'[0-9]').hasMatch(password),
      hasSpecial: RegExp(r'[^A-Za-z0-9]').hasMatch(password),
    );
  }

  int get score {
    int s = 0;
    if (hasMinLength) s++;
    if (hasUppercase) s++;
    if (hasLowercase) s++;
    if (hasNumber) s++;
    if (hasSpecial) s++;
    return s;
  }

  bool get isAllMet => score == 5;
}

class PasswordStrengthMeter extends StatelessWidget {
  final String password;
  final bool showChecklist;

  const PasswordStrengthMeter({
    super.key,
    required this.password,
    this.showChecklist = true,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final checks = PasswordChecks.fromPassword(password);
    final score = checks.score;

    final config = [
      const _StrengthConfig('Very weak', Color(0xFFEF4444)),
      const _StrengthConfig('Weak', Color(0xFFF97316)),
      const _StrengthConfig('Fair', Color(0xFFEAB308)),
      const _StrengthConfig('Good', Color(0xFF84CC16)),
      const _StrengthConfig('Strong', Color(0xFF22C55E)),
    ];

    final currentLevel = score == 0 ? 0 : (score - 1).clamp(0, 4);
    final strengthConfig = config[currentLevel];

    final bgBox = isDark ? AppColors.darkCard : AppColors.card;
    final borderCol = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    final barBg = isDark ? Colors.white12 : Colors.black12;

    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgBox,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Strength bar + Label
          Row(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(5, (index) {
                    final isFilled = index < score;
                    return Expanded(
                      child: Container(
                        height: 5,
                        margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: isFilled ? strengthConfig.color : barBg,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                strengthConfig.label,
                style: TextStyle(
                  color: strengthConfig.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          if (showChecklist) ...[
            const SizedBox(height: 8),
            // 2-column checklist
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CheckItem(label: '8+ characters', isMet: checks.hasMinLength),
                      const SizedBox(height: 4),
                      _CheckItem(label: 'Uppercase letter', isMet: checks.hasUppercase),
                      const SizedBox(height: 4),
                      _CheckItem(label: 'Special character', isMet: checks.hasSpecial),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CheckItem(label: 'Lowercase letter', isMet: checks.hasLowercase),
                      const SizedBox(height: 4),
                      _CheckItem(label: 'Number', isMet: checks.hasNumber),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool isMet;

  const _CheckItem({required this.label, required this.isMet});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isMet
        ? const Color(0xFF22C55E)
        : (isDark ? AppColors.darkTextPlaceholder : AppColors.textSecondary);

    return Row(
      children: [
        if (isMet)
          const Icon(Icons.check_rounded, size: 14, color: Color(0xFF22C55E))
        else
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 4.5),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StrengthConfig {
  final String label;
  final Color color;
  const _StrengthConfig(this.label, this.color);
}
