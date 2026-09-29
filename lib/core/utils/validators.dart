/// lib/core/utils/validators.dart
/// Centralized Form Validators, Input Filters, and Formatters
/// Extracted directly from TaskFlow-Mobile / PROJECT 2.
library;

import 'package:phone_numbers_parser/phone_numbers_parser.dart';
// ignore: implementation_imports
import 'package:phone_numbers_parser/src/metadata/metadata_finder.dart';

class Validators {
  // ─── Real-time Input Filters ────────────────────────────────────────────────

  /// First Name filter: Allows only letters (A-Z, a-z).
  /// Strips numbers, symbols, spaces, emojis in real-time.
  static String filterFirstName(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }

  /// Last Name filter: Allows letters, spaces, hyphens, apostrophes.
  static String filterLastName(String value) {
    var filtered = value.replaceAll(RegExp(r"[^a-zA-Z\s'-]"), '');
    filtered = filtered.replaceFirst(RegExp(r'^\s+'), '');
    filtered = filtered.replaceAll(RegExp(r'\s{2,}'), ' ');
    return filtered;
  }

  /// Phone filter: Strips non-digits.
  static String filterPhoneNumber(String value, {String countryCode = '+91'}) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    final cleanCountry = countryCode.trim();
    final isIndia = cleanCountry == '+91' || cleanCountry == '91';

    if (isIndia) {
      if (digits.length > 10 && digits.startsWith('91')) {
        digits = digits.substring(2);
      } else if (digits.length > 10 && digits.startsWith('0')) {
        digits = digits.replaceFirst(RegExp(r'^0+'), '');
      }
      return digits.length > 10 ? digits.substring(0, 10) : digits;
    }

    return digits.length > 15 ? digits.substring(0, 15) : digits;
  }

  // ─── Auth & Profile Validators ──────────────────────────────────────────────

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName.';
    }
    return null;
  }

  static String? validateFirstName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Please enter your first name.';
    if (trimmed.length < 2) return 'First name must be at least 2 characters.';
    if (trimmed.length > 30) return 'First name cannot exceed 30 characters.';
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(trimmed)) {
      return 'First name can only contain letters.';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Please enter your last name.';
    if (trimmed.length < 2) return 'Last name must be at least 2 characters.';
    if (trimmed.length > 50) return 'Last name cannot exceed 50 characters.';
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value ?? '')) {
      return "Last name can only contain letters, spaces, hyphens, and apostrophes.";
    }
    if ((value ?? '').startsWith(' ')) {
      return 'Last name cannot start with a space.';
    }
    if (RegExp(r'\s{2,}').hasMatch(value ?? '')) {
      return 'Last name cannot contain consecutive spaces.';
    }
    return null;
  }

  static const Map<String, String> _strictDomainProviders = {
    'gmail': 'gmail.com',
    'googlemail': 'googlemail.com',
    'hotmail': 'hotmail.com',
    'live': 'live.com',
    'icloud': 'icloud.com',
    'me': 'me.com',
    'mac': 'mac.com',
  };

  static final RegExp _emailFormatRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?\.[a-zA-Z]{2,}$');

  static String? validateEmail(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return 'Please enter your email address.';
    if (normalized.length > 254) return 'Email address is too long.';

    // 1. Basic structural check
    if (!_emailFormatRegex.hasMatch(normalized)) {
      return 'Please enter a valid email address (e.g. name@example.com)';
    }

    // 2. Reject consecutive dots anywhere
    if (normalized.contains('..')) {
      return 'Oops! Your email address cannot contain consecutive dots. Please fix that and try again.';
    }

    // 3. Extract domain
    final atIndex = normalized.lastIndexOf('@');
    final domain = normalized.substring(atIndex + 1);

    // 4. Domain must not start or end with a hyphen
    if (domain.startsWith('-') || domain.endsWith('-')) {
      return 'Please check your email — the domain part cannot start or end with a hyphen.';
    }

    // 5. Each label in domain must not start or end with a hyphen
    final labels = domain.split('.');
    for (final label in labels) {
      if (label.startsWith('-') || label.endsWith('-') || label.isEmpty) {
        return 'Please enter a valid email address (e.g. name@example.com)';
      }
    }

    // 6. Provider-specific rules (reject @gmail.co, @gmail.co.in, etc.)
    final providerName = labels.first;
    final strictDomain = _strictDomainProviders[providerName];
    if (strictDomain != null && domain != strictDomain) {
      final providerDisplay =
          providerName[0].toUpperCase() + providerName.substring(1);
      return 'Please use @$strictDomain for your $providerDisplay address. Variations like @$providerName.co or @$providerName.co.in are not accepted.';
    }

    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }
    return null;
  }

  static String? validateRegisterPassword(
    String? value, {
    String? firstName,
    String? lastName,
    String? email,
  }) {
    if (value == null || value.isEmpty) {
      return 'Please choose a password with at least 8 characters.';
    }
    if (value.length < 8) {
      return 'Please choose a password with at least 8 characters.';
    }
    if (value.length > 64) {
      return 'Please keep your password under 64 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Please include at least one uppercase letter in your password.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Please include at least one lowercase letter in your password.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Please include at least one number in your password.';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      return 'Please include at least one special character (e.g. !, @, #) in your password.';
    }
    if (value.contains(' ')) {
      return 'Please make sure your password does not contain spaces.';
    }

    // Contextual checks
    final valLower = value.toLowerCase();
    if (firstName != null && firstName.trim().length >= 2) {
      if (valLower.contains(firstName.trim().toLowerCase())) {
        return 'Please choose a stronger password — it should not contain your first name.';
      }
    }

    if (lastName != null && lastName.trim().length >= 2) {
      if (valLower.contains(lastName.trim().toLowerCase())) {
        return 'Please choose a stronger password — it should not contain your last name.';
      }
    }

    if (email != null && email.contains('@')) {
      final handle = email.split('@')[0].toLowerCase();
      if (handle.length > 3 && valLower.contains(handle)) {
        return 'Please choose a stronger password — it should not contain part of your email address.';
      }
    }

    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirm) {
    if (confirm == null || confirm.isEmpty) {
      return 'Please confirm your password.';
    }
    if (password != confirm) {
      return 'Oops! Your passwords do not match. Please make sure both fields are identical.';
    }
    return null;
  }

  /// Retrieves dynamic min, max, and allowed national phone number lengths from ITU metadata
  static ({int min, int max, Set<int> allowed}) getCountryPhoneLengths(String? isoCode) {
    if (isoCode == null || isoCode.trim().isEmpty) {
      return (min: 7, max: 15, allowed: const <int>{});
    }
    try {
      final iso = IsoCode.values.byName(isoCode.trim().toUpperCase());
      final meta = MetadataFinder.findMetadataLengthForIsoCode(iso);
      final allowed = <int>{
        ...meta.mobile,
        ...meta.fixedLine,
        ...meta.general,
      };
      if (allowed.isNotEmpty) {
        final min = allowed.reduce((a, b) => a < b ? a : b);
        final max = allowed.reduce((a, b) => a > b ? a : b);
        return (min: min, max: max, allowed: allowed);
      }
    } catch (_) {}
    return (min: 7, max: 15, allowed: const <int>{});
  }

  static String? validatePhoneNumber(
    String? phone, {
    bool? required,
    bool? isRequired,
    String countryCode = '+91',
    String? isoCode,
  }) {
    final bool isReq = isRequired ?? required ?? true;
    if (phone == null || phone.trim().isEmpty) {
      return isReq ? 'Please enter your phone number.' : null;
    }

    final trimmed = phone.trim();
    var digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return 'Please enter a valid phone number.';
    }

    final cleanCountry = countryCode.trim();
    final isIndia = cleanCountry == '+91' ||
        cleanCountry == '91' ||
        isoCode?.toUpperCase() == 'IN' ||
        (!cleanCountry.startsWith('+') && cleanCountry.isEmpty && trimmed.startsWith('+91'));

    if (isIndia) {
      if (digits.length == 12 && digits.startsWith('91')) {
        digits = digits.substring(2);
      } else if (digits.length == 11 && digits.startsWith('0')) {
        digits = digits.substring(1);
      }

      if (digits.length != 10) {
        return 'Please enter a valid 10-digit mobile number.';
      }

      // Reject all-identical digits (e.g. 1111111111)
      if (RegExp(r'^(\d)\1{9}$').hasMatch(digits)) {
        return 'Please enter a valid mobile number.';
      }

      // Reject obviously sequential patterns
      const sequential = ['1234567890', '0123456789', '9876543210', '8765432109'];
      if (sequential.contains(digits)) {
        return 'Please enter a valid mobile number.';
      }

      // TRAI standard starts with 6, 7, 8, or 9
      if (!RegExp(r'^[6-9]').hasMatch(digits)) {
        return 'Indian mobile numbers must start with 6, 7, 8, or 9.';
      }

      try {
        final parsed = PhoneNumber.parse('+91$digits');
        if (!parsed.isValid()) {
          return 'Please enter a valid Indian mobile number.';
        }
      } catch (_) {}

      return null;
    }

    IsoCode? callerIso;
    if (isoCode != null && isoCode.isNotEmpty) {
      try {
        callerIso = IsoCode.values.byName(isoCode.toUpperCase());
      } catch (_) {}
    }

    if (callerIso != null) {
      final lengthInfo = getCountryPhoneLengths(isoCode);
      if (lengthInfo.allowed.isNotEmpty && !lengthInfo.allowed.contains(digits.length)) {
        return 'Please enter a valid phone number.';
      }
    } else {
      if (digits.length < 7 || digits.length > 15) {
        return 'Please enter a valid phone number.';
      }
    }

    if (RegExp(r'^(\d)\1+$').hasMatch(digits)) {
      return 'Please enter a valid mobile number.';
    }

    final dialCode = cleanCountry.startsWith('+') ? cleanCountry : '+$cleanCountry';
    final fullNumber = trimmed.startsWith('+') ? trimmed : '$dialCode$digits';

    try {
      final parsed = callerIso != null
          ? PhoneNumber.parse(digits, destinationCountry: callerIso)
          : PhoneNumber.parse(fullNumber);
      if (!parsed.isValid()) {
        return 'Please enter a valid phone number.';
      }
      return null;
    } catch (_) {
      return 'Please enter a valid phone number.';
    }
  }

  static String? validateDob(String? dobStr) {
    if (dobStr == null || dobStr.trim().isEmpty) {
      return 'Please enter your date of birth.';
    }

    final parts = dobStr.trim().split('-');
    if (parts.length != 3) {
      return 'Please enter a valid date of birth (YYYY-MM-DD).';
    }

    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);

    if (y == null || m == null || d == null) {
      return 'Please enter a valid date of birth.';
    }

    final birthDate = DateTime(y, m, d);
    if (birthDate.year != y || birthDate.month != m || birthDate.day != d) {
      return 'Please enter a valid date of birth.';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (birthDate.isAfter(today)) {
      return 'Date of birth cannot be in the future.';
    }

    // Minimum age 13 years (COPPA)
    final minAgeDate = DateTime(now.year - 13, now.month, now.day);
    if (birthDate.isAfter(minAgeDate)) {
      return 'You must be at least 13 years old to register.';
    }

    return null;
  }

  // ─── Task Validators ────────────────────────────────────────────────────────

  static String? validateTaskTitle(String? title) {
    if (title == null || title.trim().isEmpty) return 'Please enter task title.';
    if (title.trim() != title) {
      return 'Task title cannot have leading or trailing spaces.';
    }
    if (RegExp(r'\s{2,}').hasMatch(title)) {
      return 'Task title cannot contain consecutive spaces.';
    }
    if (title.length < 5) return 'Task title must be at least 5 characters.';
    if (title.length > 100) return 'Task title cannot exceed 100 characters.';
    return null;
  }

  static String? validateTaskDesc(String? desc) {
    if (desc == null || desc.trim().isEmpty) return 'Please enter task description.';
    if (desc.trim() != desc) {
      return 'Task description cannot have leading or trailing spaces.';
    }
    if (desc.length < 10) return 'Task description must be at least 10 characters.';
    if (desc.length > 500) return 'Task description cannot exceed 500 characters.';
    return null;
  }

  static String? validateTaskDueDate(String? dueDate) {
    if (dueDate == null || dueDate.trim().isEmpty) return 'Please select a due date.';

    final due = DateTime.tryParse(dueDate);
    if (due == null) return 'Please select a valid due date.';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(due.year, due.month, due.day);

    if (dueDay.isBefore(today)) {
      return 'Due date cannot be in the past.';
    }

    return null;
  }

  static String? validateDepartment(String? dept, {bool required = false}) {
    if (dept == null || dept.trim().isEmpty) {
      return required ? 'Please enter department.' : null;
    }
    if (dept.trim() != dept) {
      return 'Department cannot have leading or trailing spaces.';
    }
    if (RegExp(r'\s{2,}').hasMatch(dept)) {
      return 'Department cannot contain consecutive spaces.';
    }
    if (dept.length < 2) return 'Department must be at least 2 characters.';
    if (dept.length > 50) return 'Department cannot exceed 50 characters.';
    return null;
  }

  static String? validateDesignation(String? desig, {bool required = false}) {
    if (desig == null || desig.trim().isEmpty) {
      return required ? 'Please enter designation.' : null;
    }
    if (desig.trim() != desig) {
      return 'Designation cannot have leading or trailing spaces.';
    }
    if (RegExp(r'\s{2,}').hasMatch(desig)) {
      return 'Designation cannot contain consecutive spaces.';
    }
    if (desig.length < 2) return 'Designation must be at least 2 characters.';
    if (desig.length > 50) return 'Designation cannot exceed 50 characters.';
    return null;
  }

  // ─── Leave Validators ───────────────────────────────────────────────────────

  static ({String? startError, String? endError}) validateLeaveDates(
    String? startDate,
    String? endDate,
  ) {
    String? startError;
    String? endError;

    if (startDate == null || startDate.isEmpty) {
      startError = 'Please select start date.';
    }
    if (endDate == null || endDate.isEmpty) {
      endError = 'Please select end date.';
    }

    if (startDate != null &&
        startDate.isNotEmpty &&
        endDate != null &&
        endDate.isNotEmpty) {
      final s = DateTime.tryParse(startDate);
      final e = DateTime.tryParse(endDate);

      if (s == null) startError = 'Invalid start date.';
      if (e == null) endError = 'Invalid end date.';

      if (s != null && e != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final startDay = DateTime(s.year, s.month, s.day);
        final endDay = DateTime(e.year, e.month, e.day);

        if (startDay.isBefore(today)) {
          startError = 'Start date cannot be in the past.';
        }
        if (startDay.isAfter(endDay)) {
          endError = 'Start date cannot be after end date.';
        }
      }
    }

    return (startError: startError, endError: endError);
  }

  static String? validateLeaveReason(String? reason) {
    if (reason == null || reason.trim().isEmpty) return 'Please enter a reason.';
    if (reason.trim().length < 10) return 'Reason must be at least 10 characters.';
    if (reason.trim().length > 500) return 'Reason must not exceed 500 characters.';
    return null;
  }

  static String? validateRejectionReason(String? reason, {bool required = false}) {
    if (reason == null || reason.trim().isEmpty) {
      return required ? 'Please enter a rejection reason.' : null;
    }
    if (reason.length > 300) return 'Rejection reason must not exceed 300 characters.';
    return null;
  }

  static int? calcLeaveDays(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return null;
    final s = DateTime.tryParse(startDate);
    final e = DateTime.tryParse(endDate);
    if (s == null || e == null || s.isAfter(e)) return null;
    return e.difference(s).inDays + 1;
  }

  static String? validateBio(String? bio) {
    if (bio == null || bio.isEmpty) return null;
    if (bio.length > 500) {
      return 'Bio cannot exceed 500 characters.';
    }
    return null;
  }

  // ─── Formatters & Capitalization ────────────────────────────────────────────

  static String capitalizeFirst(String val) {
    final t = val.trim();
    if (t.isEmpty) return '';
    return t[0].toUpperCase() + t.substring(1).toLowerCase();
  }

  static String capitalizeWords(String val) {
    return val
        .trim()
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
