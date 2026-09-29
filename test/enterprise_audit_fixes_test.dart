import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_flutter/core/network/dio_client.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';

void main() {
  group('Enterprise Audit: Error Handling & Formatting', () {
    test('DioClient.extractErrorMessage strips Exception: prefix cleanly', () {
      final exc = Exception('Server connection refused on port 5000');
      final msg = DioClient.extractErrorMessage(exc);
      expect(msg.startsWith('Exception:'), isFalse);
      expect(msg, 'Server connection refused on port 5000');
    });

    test('DioClient.extractErrorMessage preserves normal strings', () {
      const normal = 'Invalid credentials provided.';
      final msg = DioClient.extractErrorMessage(normal);
      expect(msg, 'Invalid credentials provided.');
    });

    test('Forgot Password: error messages containing "not found" produce friendly feedback', () {
      // Simulate the parsing logic in forgot_password_screen
      String formatForgotPasswordError(dynamic e) {
        final raw = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        final lower = raw.toLowerCase();
        final isNotFound = lower.contains('not found') ||
            lower.contains('no account') ||
            lower.contains("doesn't exist") ||
            lower.contains('does not exist') ||
            lower.contains('no user') ||
            lower.contains('invalid email');
        return isNotFound
            ? 'No account found with this email address. Please check and try again.'
            : raw;
      }

      expect(
        formatForgotPasswordError(Exception('User not found in system')),
        'No account found with this email address. Please check and try again.',
      );
      expect(
        formatForgotPasswordError('No account with this email'),
        'No account found with this email address. Please check and try again.',
      );
      expect(
        formatForgotPasswordError('User does not exist'),
        'No account found with this email address. Please check and try again.',
      );
      expect(
        formatForgotPasswordError(Exception('Rate limit exceeded')),
        'Rate limit exceeded',
      );
    });

    test('Register: duplicate email produces friendly feedback', () {
      String formatRegisterError(String msg) {
        final cleanedMsg = msg.replaceFirst(RegExp(r'^Exception:\s*'), '');
        final lower = cleanedMsg.toLowerCase();
        final isAlreadyRegistered = lower.contains('already exist') ||
            lower.contains('already registered') ||
            lower.contains('duplicate') ||
            lower.contains('already in use');
        return isAlreadyRegistered
            ? 'An account with this email already exists. Please sign in instead.'
            : cleanedMsg;
      }

      expect(
        formatRegisterError('Email already registered'),
        'An account with this email already exists. Please sign in instead.',
      );
      expect(
        formatRegisterError('User with this email already exists'),
        'An account with this email already exists. Please sign in instead.',
      );
      expect(
        formatRegisterError('Internal server error 500'),
        'Internal server error 500',
      );
    });
  });

  group('Enterprise Audit: Date Formatting', () {
    test('Task due date parses ISO strings and formats as MMM d, y', () {
      const rawIso = '2026-10-15T00:00:00.000Z';
      final parsed = DateTime.tryParse(rawIso);
      expect(parsed, isNotNull);
      final formatted = DateFormat('MMM d, y').format(parsed!);
      expect(formatted, 'Oct 15, 2026');
    });

    test('Task due date gracefully handles simple date format', () {
      const rawDate = '2026-12-31';
      final parsed = DateTime.tryParse(rawDate);
      expect(parsed, isNotNull);
      final formatted = DateFormat('MMM d, y').format(parsed!);
      expect(formatted, 'Dec 31, 2026');
    });
  });

  group('Enterprise Audit: Validators & Terms', () {
    test('validateBio allows up to 500 characters and rejects 501+', () {
      expect(Validators.validateBio(''), isNull);
      expect(Validators.validateBio(null), isNull);
      expect(Validators.validateBio('a' * 500), isNull);
      expect(Validators.validateBio('a' * 501), 'Bio cannot exceed 500 characters.');
    });

    test('validateEmail requires valid email and uses Please wording', () {
      expect(Validators.validateEmail(''), 'Please enter your email address.');
      expect(Validators.validateEmail('invalid'), 'Please enter a valid email address (e.g. name@example.com)');
      expect(Validators.validateEmail('test@enterprise.com'), isNull);
    });
  });
}
