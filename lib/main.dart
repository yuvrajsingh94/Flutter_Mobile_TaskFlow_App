import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/app.dart';
import 'package:taskflow_flutter/core/config/api_config.dart';
import 'package:taskflow_flutter/core/storage/storage_service.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize runtime API URL override from persistent storage
  await ApiConfig.init();

  // Initialize secure & key-value storage
  final storageService = await StorageService.init();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const TaskFlowApp(),
    ),
  );
}
