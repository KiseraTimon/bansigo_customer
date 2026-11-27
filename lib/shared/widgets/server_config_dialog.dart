// lib/shared/widgets/server_config_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'app_text_field.dart';
import 'app_toast.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ServerConfigDialog(),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late final TextEditingController _urlController;
  bool _isTesting = false;
  bool? _testSuccess;
  String? _testMessage;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _urlController = TextEditingController(text: auth.currentApiUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testSuccess = null;
      _testMessage = null;
    });

    final success = await auth.testServerConnection(url);

    if (!mounted) return;
    setState(() {
      _isTesting = false;
      _testSuccess = success;
      _testMessage = success
          ? 'Connected! Server is reachable.'
          : 'Could not reach server. Verify host IP & Wi-Fi.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.dns_rounded, color: AppColors.primaryDark, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Server Endpoint',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure the FastAPI server address. External mobile phones connect using the host PC Wi-Fi IP address:',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _urlController,
              label: 'Base API URL',
              hint: AppConfig.defaultWifiUrl,
              prefix: const Icon(Icons.link, size: 20, color: AppColors.textSecondary),
              onChanged: (_) {
                if (_testSuccess != null) {
                  setState(() {
                    _testSuccess = null;
                    _testMessage = null;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Quick Presets:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.wifi, size: 14, color: AppColors.primaryDark),
                  backgroundColor: AppColors.primarySubtle,
                  label: const Text('192.168.100.54 (Wi-Fi)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  onPressed: () {
                    setState(() {
                      _urlController.text = AppConfig.defaultWifiUrl;
                      _testSuccess = null;
                      _testMessage = null;
                    });
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.phone_android, size: 14),
                  label: const Text('10.0.2.2 (Emulator)', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    setState(() {
                      _urlController.text = AppConfig.emulatorUrl;
                      _testSuccess = null;
                      _testMessage = null;
                    });
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.computer, size: 14),
                  label: const Text('localhost', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    setState(() {
                      _urlController.text = AppConfig.localhostUrl;
                      _testSuccess = null;
                      _testMessage = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Connection Test Status
            if (_testMessage != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _testSuccess == true
                      ? AppColors.primarySubtle
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testSuccess == true
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess == true ? Icons.check_circle : Icons.error_outline,
                      size: 16,
                      color: _testSuccess == true ? AppColors.primaryDark : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _testSuccess == true ? AppColors.primaryDark : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Test Connection Action
            OutlinedButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(38),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              icon: _isTesting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.network_check_rounded, size: 16),
              label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            final nav = Navigator.of(context);
            final url = _urlController.text.trim();
            await auth.setCustomServerUrl(url);
            if (!context.mounted) return;
            AppToast.success(context, 'Server endpoint saved: $url');
            nav.pop();
          },
          child: const Text('Apply & Save'),
        ),
      ],
    );
  }
}
